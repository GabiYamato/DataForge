variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets"
  type        = list(string)
}

variable "management_cidrs" {
  description = "CIDR blocks allowed to manage Kafka"
  type        = list(string)
  default     = []
}
