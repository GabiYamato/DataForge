output "catalog_database_name" {
  description = "Primary Glue catalog database"
  value       = aws_glue_catalog_database.gold.name
}

output "crawler_role_arn" {
  description = "IAM role used by Glue crawlers"
  value       = aws_iam_role.crawler.arn
}
