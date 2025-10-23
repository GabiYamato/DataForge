variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket" {
  description = "S3 bucket storing Terraform remote state"
  type        = string
}

variable "state_lock_table" {
  description = "DynamoDB table for Terraform state locking"
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to resource names"
  type        = string
  default     = "dataforge"
}

variable "deployment_suffix" {
  description = "Unique suffix appended to globally scoped resources"
  type        = string
  default     = "dev"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the core VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDRs for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "logging_bucket_arn" {
  description = "S3 bucket ARN used for access logs"
  type        = string
}

variable "kafka_version" {
  description = "Kafka version for MSK cluster"
  type        = string
  default     = "3.6.0"
}

variable "kafka_broker_instance_type" {
  description = "Instance type for MSK brokers"
  type        = string
  default     = "kafka.m5.large"
}

variable "kafka_broker_count" {
  description = "Number of MSK broker nodes"
  type        = number
  default     = 3
}

variable "kafka_topics" {
  description = "List of Kafka topics to subscribe to"
  type        = list(string)
  default     = [
    "events.telemetry",
    "events.transactions"
  ]
}

variable "ingestion_lambda_package" {
  description = "Path to the zipped ingestion Lambda artifact"
  type        = string
  default     = "../services/ingestion/lambdas/dist/ingestion.zip"
}

variable "api_lambda_package" {
  description = "Path to the zipped analytics API Lambda artifact"
  type        = string
  default     = "../services/api/server/dist/api.zip"
}
