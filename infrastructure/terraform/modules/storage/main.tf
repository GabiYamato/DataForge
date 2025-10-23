locals {
  landing_bucket_name = "${var.name_prefix}-landing-${var.deployment_suffix}"
  bronze_bucket_name  = "${var.name_prefix}-bronze-${var.deployment_suffix}"
  silver_bucket_name  = "${var.name_prefix}-silver-${var.deployment_suffix}"
  gold_bucket_name    = "${var.name_prefix}-gold-${var.deployment_suffix}"
}

resource "aws_s3_bucket" "landing" {
  bucket = local.landing_bucket_name

  tags = {
    Name = "${var.name_prefix}-landing"
    Zone = "landing"
  }
}

resource "aws_s3_bucket_versioning" "landing" {
  bucket = aws_s3_bucket.landing.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "landing" {
  bucket = aws_s3_bucket.landing.id

  target_bucket = regex("^arn:aws:s3:::(.+)$", var.logging_bucket_arn)[0]
  target_prefix = "s3-access-logs/${aws_s3_bucket.landing.id}/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "landing" {
  bucket = aws_s3_bucket.landing.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket" "bronze" {
  bucket = local.bronze_bucket_name

  tags = {
    Name = "${var.name_prefix}-bronze"
    Zone = "bronze"
  }
}

resource "aws_s3_bucket" "silver" {
  bucket = local.silver_bucket_name

  tags = {
    Name = "${var.name_prefix}-silver"
    Zone = "silver"
  }
}

resource "aws_s3_bucket" "gold" {
  bucket = local.gold_bucket_name

  tags = {
    Name = "${var.name_prefix}-gold"
    Zone = "gold"
  }
}

# Apply uniform security policies
resource "aws_s3_bucket_public_access_block" "all" {
  for_each = {
    landing = aws_s3_bucket.landing.id
    bronze  = aws_s3_bucket.bronze.id
    silver  = aws_s3_bucket.silver.id
    gold    = aws_s3_bucket.gold.id
  }

  bucket = each.value

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "bronze" {
  bucket = aws_s3_bucket.bronze.id

  rule {
    id     = "transition-old"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}
