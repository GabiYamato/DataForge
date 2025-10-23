import argparse
import os
from datetime import datetime, timedelta

from pyspark.sql import SparkSession
from pyspark.sql.functions import col, countDistinct, sum as spark_sum, to_date, lit


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Daily gold table aggregator")
    parser.add_argument("--silver", default=os.getenv("SILVER_PATH", "s3://dataforge-silver-dev"))
    parser.add_argument("--gold", default=os.getenv("GOLD_PATH", "s3://dataforge-gold-dev"))
    parser.add_argument("--processing-date", dest="processing_date", default=datetime.utcnow().strftime("%Y-%m-%d"))
    parser.add_argument("--env", default=os.getenv("DATAFORGE_ENV", "dev"))
    return parser.parse_args()


def create_spark(env: str) -> SparkSession:
    builder = SparkSession.builder.appName("DataForgeDailyAggregator")
    if env == "local":
        builder = builder.master("local[2]")
    spark = builder.getOrCreate()
    spark.conf.set("spark.sql.shuffle.partitions", "200" if env != "local" else "4")
    return spark


def main() -> None:
    args = parse_args()
    spark = create_spark(args.env)

    process_date = datetime.strptime(args.processing_date, "%Y-%m-%d").date()
    previous_day = process_date - timedelta(days=1)
    df = spark.read.parquet(args.silver)

    filtered = df.filter(to_date(col("occurred_at")) == lit(previous_day.isoformat()))

    metrics = (
        filtered.groupBy("currency")
        .agg(
            spark_sum(col("amount")).alias("total_amount"),
            countDistinct("event_id").alias("unique_transactions"),
        )
        .withColumn("report_date", lit(previous_day.isoformat()))
    )

    metrics.write.mode("overwrite").partitionBy("report_date").parquet(args.gold)


if __name__ == "__main__":
    main()
