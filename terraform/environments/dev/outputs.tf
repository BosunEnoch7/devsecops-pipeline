output "environment" {
  description = "Current Terraform environment."
  value       = var.environment
}

output "aws_region" {
  description = "Target AWS region."
  value       = var.aws_region
}

output "common_tags" {
  description = "Common tags that will be applied to AWS resources."
  value       = local.common_tags
}
