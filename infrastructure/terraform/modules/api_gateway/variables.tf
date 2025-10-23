variable "name_prefix" {
  description = "Prefix for API resources"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Invoke ARN for the integrated Lambda"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the integrated Lambda"
  type        = string
}
