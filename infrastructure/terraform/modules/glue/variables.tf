variable "name_prefix" {
  description = "Prefix for Glue resources"
  type        = string
}

variable "s3_bronze_bucket" {
  description = "Bronze zone bucket name"
  type        = string
}

variable "s3_silver_bucket" {
  description = "Silver zone bucket name"
  type        = string
}

variable "s3_gold_bucket" {
  description = "Gold zone bucket name"
  type        = string
}
