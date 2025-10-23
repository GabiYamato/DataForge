output "landing_bucket_id" {
  description = "Landing zone bucket name"
  value       = aws_s3_bucket.landing.id
}

output "landing_bucket_arn" {
  description = "Landing zone bucket ARN"
  value       = aws_s3_bucket.landing.arn
}

output "bronze_bucket_id" {
  description = "Bronze zone bucket name"
  value       = aws_s3_bucket.bronze.id
}

output "bronze_bucket_arn" {
  description = "Bronze zone bucket ARN"
  value       = aws_s3_bucket.bronze.arn
}

output "silver_bucket_id" {
  description = "Silver zone bucket name"
  value       = aws_s3_bucket.silver.id
}

output "gold_bucket_id" {
  description = "Gold zone bucket name"
  value       = aws_s3_bucket.gold.id
}
