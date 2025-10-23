import argparse
import os
from datetime import datetime

from pyspark.sql import SparkSession
from pyspark.sql.functions import col


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="DataForge backfill job")
    parser.add_argument("--bronze", default=os.getenv("BRONZE_PATH", "s3://dataforge-bronze-dev"))
    parser.add_argument("--silver", default=os.getenv("SILVER_PATH", "s3://dataforge-silver-dev"))
    parser.add_argument("--start", required=True, help="Inclusive start timestamp (YYYY-MM-DD)")
    parser.add_argument("--end", required=True, help="Exclusive end timestamp (YYYY-MM-DD)")
    parser.add_argument("--env", default=os.getenv("DATAFORGE_ENV", "dev"))
    return parser.parse_args()


def create_spark(env: str) -> SparkSession:
    builder = SparkSession.builder.appName("DataForgeBackfill")
    if env == "local":
        builder = builder.master("local[2]")
    spark = builder.getOrCreate()
    spark.conf.set("spark.sql.shuffle.partitions", "200" if env != "local" else "4")
    return spark


def main() -> None:
    args = parse_args()
    start_ts = datetime.strptime(args.start, "%Y-%m-%d")
    end_ts = datetime.strptime(args.end, "%Y-%m-%d")

    spark = create_spark(args.env)

    bronze_df = spark.read.parquet(args.bronze)

    filtered = bronze_df.filter(
        (col("occurred_at") >= start_ts) & (col("occurred_at") < end_ts)
    )

    filtered.write.mode("overwrite").partitionBy("event_type").parquet(args.silver)


if __name__ == "__main__":
    main()
