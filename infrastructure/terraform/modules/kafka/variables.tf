variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "kafka_version" {
  description = "Kafka version"
  type        = string
}

variable "num_broker_nodes" {
  description = "Number of broker nodes"
  type        = number
}

variable "broker_instance_type" {
  description = "Instance type for brokers"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group for MSK"
  type        = string
}
