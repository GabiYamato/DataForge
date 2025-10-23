resource "aws_iam_role" "crawler" {
  name = "${var.name_prefix}-glue-crawler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "crawler_service" {
  role       = aws_iam_role.crawler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_glue_catalog_database" "bronze" {
  name = "${var.name_prefix}_bronze"
}

resource "aws_glue_catalog_database" "silver" {
  name = "${var.name_prefix}_silver"
}

resource "aws_glue_catalog_database" "gold" {
  name = "${var.name_prefix}_gold"
}

resource "aws_glue_crawler" "bronze" {
  name          = "${var.name_prefix}-bronze-crawler"
  role          = aws_iam_role.crawler.arn
  database_name = aws_glue_catalog_database.bronze.name
  s3_target {
    path = "s3://${var.s3_bronze_bucket}/"
  }
  schedule = "cron(0 */6 * * ? *)"
}

resource "aws_glue_crawler" "silver" {
  name          = "${var.name_prefix}-silver-crawler"
  role          = aws_iam_role.crawler.arn
  database_name = aws_glue_catalog_database.silver.name
  s3_target {
    path = "s3://${var.s3_silver_bucket}/"
  }
  schedule = "cron(0 2 * * ? *)"
}

resource "aws_glue_crawler" "gold" {
  name          = "${var.name_prefix}-gold-crawler"
  role          = aws_iam_role.crawler.arn
  database_name = aws_glue_catalog_database.gold.name
  s3_target {
    path = "s3://${var.s3_gold_bucket}/"
  }
  schedule = "cron(0 * * * ? *)"
}
