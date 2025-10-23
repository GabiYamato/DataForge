output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "lambda_security_group_id" {
  description = "Security group ID for Lambda functions"
  value       = aws_security_group.lambda.id
}

output "kafka_security_group_id" {
  description = "Security group ID for Kafka cluster"
  value       = aws_security_group.kafka.id
}
