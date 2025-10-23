variable "name_prefix" {
  description = "Prefix applied to bucket names"
  type        = string
}

variable "deployment_suffix" {
  description = "Globally unique suffix to avoid bucket name collisions"
  type        = string
}

variable "logging_bucket_arn" {
  description = "Destination bucket ARN for access logs"
  type        = string
}
