output "api_lambda_invoke_arn" {
  description = "Invoke ARN for analytics API Lambda"
  value       = aws_lambda_function.api.invoke_arn
}

output "api_lambda_function_name" {
  description = "Name of the analytics API Lambda"
  value       = aws_lambda_function.api.function_name
}

output "ingestion_lambda_arn" {
  description = "ARN of ingestion Lambda"
  value       = aws_lambda_function.ingestion.arn
}
