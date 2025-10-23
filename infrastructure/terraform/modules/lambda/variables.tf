variable "name_prefix" {
  description = "Prefix for Lambda resources"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs for VPC access"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for Lambda"
  type        = string
}

variable "ingestion_bucket_arn" {
  description = "ARN of landing bucket"
  type        = string
}

variable "bronze_bucket_arn" {
  description = "ARN of bronze bucket"
  type        = string
}

variable "kafka_bootstrap_brokers" {
  description = "Bootstrap brokers string"
  type        = string
}

variable "kafka_cluster_arn" {
  description = "MSK cluster ARN"
  type        = string
}

variable "kafka_topics" {
  description = "Kafka topics for ingestion"
  type        = list(string)
}

variable "glue_catalog_database_name" {
  description = "Glue catalog database name"
  type        = string
}

variable "ingestion_package_path" {
  description = "Path to zipped ingestion Lambda artifact"
  type        = string
}

variable "api_package_path" {
  description = "Path to zipped API Lambda artifact"
  type        = string
}
