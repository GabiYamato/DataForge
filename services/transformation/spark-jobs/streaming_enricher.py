import argparse
import os

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, current_timestamp, from_json, lit
from pyspark.sql.types import MapType, StringType, StructField, StructType, TimestampType

EVENT_SCHEMA = StructType(
    [
        StructField("event_id", StringType(), False),
        StructField("event_type", StringType(), False),
        StructField("occurred_at", TimestampType(), False),
        StructField("payload", MapType(StringType(), StringType()), True),
        StructField("source", StringType(), True),
    ]
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="DataForge streaming enricher")
    parser.add_argument("--env", default=os.getenv("DATAFORGE_ENV", "dev"))
    parser.add_argument("--bootstrap", default=os.getenv("KAFKA_BOOTSTRAP_SERVERS", ""))
    parser.add_argument("--topic", default=os.getenv("KAFKA_TOPIC", "events.telemetry"))
    parser.add_argument("--bronze", default=os.getenv("BRONZE_PATH", "s3://dataforge-bronze-dev"))
    parser.add_argument("--silver", default=os.getenv("SILVER_PATH", "s3://dataforge-silver-dev"))
    parser.add_argument("--checkpoint", default=os.getenv("CHECKPOINT_PATH", "s3://dataforge-checkpoints/streaming"))
    return parser.parse_args()


def create_spark(env: str) -> SparkSession:
    builder = SparkSession.builder.appName("DataForgeStreamingEnricher")
    if env == "local":
        builder = builder.master("local[2]")
    spark = builder.getOrCreate()
    spark.conf.set("spark.sql.shuffle.partitions", "200" if env != "local" else "4")
    return spark


def main() -> None:
    args = parse_args()
    if not args.bootstrap:
        raise ValueError("Kafka bootstrap servers must be provided")

    spark = create_spark(args.env)

    raw = (
        spark.readStream.format("kafka")
        .option("kafka.bootstrap.servers", args.bootstrap)
        .option("subscribe", args.topic)
        .option("kafka.security.protocol", "SASL_SSL")
        .option("kafka.sasl.mechanism", "AWS_MSK_IAM")
        .option("kafka.sasl.jaas.config", "software.amazon.msk.auth.iam.IAMLoginModule required;")
        .load()
    )

    json_df = (
        raw.selectExpr("CAST(value AS STRING) as json_payload", "topic", "partition", "offset")
        .withColumn("event", from_json(col("json_payload"), EVENT_SCHEMA))
        .filter(col("event").isNotNull())
        .withColumn("ingested_at", current_timestamp())
    )

    bronze = (
        json_df.select(
            col("event.event_id").alias("event_id"),
            col("event.event_type").alias("event_type"),
            col("event.occurred_at").alias("occurred_at"),
            col("event.payload").alias("payload"),
            col("event.source").alias("source"),
            col("topic"),
            col("partition"),
            col("offset"),
            col("ingested_at"),
        )
    )

    bronze_query = (
        bronze.writeStream.partitionBy("event_type")
        .format("parquet")
        .option("path", args.bronze)
        .option("checkpointLocation", os.path.join(args.checkpoint, "bronze"))
        .outputMode("append")
        .start()
    )

    silver = (
        bronze.filter(col("event_type") == lit("transaction"))
        .select(
            "event_id",
            "event_type",
            "occurred_at",
            col("payload").getItem("amount").cast("double").alias("amount"),
            col("payload").getItem("currency").alias("currency"),
            col("ingested_at"),
        )
        .filter(col("amount").isNotNull())
    )

    silver_query = (
        silver.writeStream.partitionBy("currency")
        .format("parquet")
        .option("path", args.silver)
        .option("checkpointLocation", os.path.join(args.checkpoint, "silver"))
        .outputMode("append")
        .start()
    )

    spark.streams.awaitAnyTermination()

    bronze_query.stop()
    silver_query.stop()


if __name__ == "__main__":
    main()
