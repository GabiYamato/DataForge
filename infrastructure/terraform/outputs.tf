output "vpc_id" {
  description = "ID of the DataForge VPC"
  value       = module.networking.vpc_id
}

output "landing_bucket" {
  description = "Name of the landing zone S3 bucket"
  value       = module.storage.landing_bucket_id
}

output "kafka_bootstrap_brokers" {
  description = "Bootstrap brokers string for MSK"
  value       = module.kafka.bootstrap_brokers
}

output "api_gateway_endpoint" {
  description = "URL of the REST API Gateway"
  value       = module.api_gateway.invoke_url
}
