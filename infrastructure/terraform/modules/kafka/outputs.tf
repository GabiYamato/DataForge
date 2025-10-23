output "bootstrap_brokers" {
  description = "IAM-authenticated bootstrap brokers"
  value       = aws_msk_cluster.this.bootstrap_brokers_sasl_iam
}

output "cluster_arn" {
  description = "ARN of the MSK cluster"
  value       = aws_msk_cluster.this.arn
}
