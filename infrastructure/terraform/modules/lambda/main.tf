locals {
  landing_bucket_name = replace(var.ingestion_bucket_arn, "arn:aws:s3:::", "")
  bronze_bucket_name  = replace(var.bronze_bucket_arn, "arn:aws:s3:::", "")
}

data "aws_iam_policy_document" "assume_lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ingestion" {
  name               = "${var.name_prefix}-ingestion-role"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
}

resource "aws_iam_role" "api" {
  name               = "${var.name_prefix}-api-role"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
}

resource "aws_iam_role_policy_attachment" "ingestion_vpc" {
  role       = aws_iam_role.ingestion.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "api_basic" {
  role       = aws_iam_role.api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "ingestion_data" {
  name = "${var.name_prefix}-ingestion-data"
  role = aws_iam_role.ingestion.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:PutObjectAcl", "s3:AbortMultipartUpload"]
        Resource = [
          "${var.ingestion_bucket_arn}/*",
          "${var.bronze_bucket_arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["glue:GetTable", "glue:GetTableVersion", "glue:GetDatabase"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "ingestion" {
  function_name = "${var.name_prefix}-ingestion"
  role          = aws_iam_role.ingestion.arn
  handler       = "app.handler"
  runtime       = "python3.11"
  filename      = var.ingestion_package_path
  source_code_hash = filebase64sha256(var.ingestion_package_path)

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.security_group_id]
  }

  environment {
    variables = {
      LANDING_BUCKET = local.landing_bucket_name
      BRONZE_BUCKET  = local.bronze_bucket_name
      GLUE_DATABASE  = var.glue_catalog_database_name
      KAFKA_BROKERS  = var.kafka_bootstrap_brokers
    }
  }
}

resource "aws_lambda_function" "api" {
  function_name = "${var.name_prefix}-analytics-api"
  role          = aws_iam_role.api.arn
  handler       = "dist/handler.handler"
  runtime       = "nodejs20.x"
  filename      = var.api_package_path
  source_code_hash = filebase64sha256(var.api_package_path)

  environment {
    variables = {
      GLUE_DATABASE = var.glue_catalog_database_name
    }
  }
}

resource "aws_lambda_event_source_mapping" "kafka" {
  event_source_arn  = var.kafka_cluster_arn
  function_name     = aws_lambda_function.ingestion.arn
  starting_position = "LATEST"
  topics            = var.kafka_topics
  batch_size        = 100

  dynamic "source_access_configuration" {
    for_each = slice(var.subnet_ids, 0, length(var.subnet_ids) >= 2 ? 2 : length(var.subnet_ids))
    content {
      type = "VPC_SUBNET"
      uri  = "subnet:${source_access_configuration.value}"
    }
  }

  source_access_configuration {
    type = "VPC_SECURITY_GROUP"
    uri  = "security_group:${var.security_group_id}"
  }
}

resource "aws_cloudwatch_log_group" "ingestion" {
  name              = "/aws/lambda/${aws_lambda_function.ingestion.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/lambda/${aws_lambda_function.api.function_name}"
  retention_in_days = 30
}
