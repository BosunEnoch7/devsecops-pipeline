# Terraform Bootstrap

This folder is reserved for remote-state bootstrap resources.

Later phases will define:

- S3 bucket for Terraform state
- DynamoDB table for state locking
- KMS encryption option
- IAM access model for Jenkins/Terraform

Bootstrap is intentionally separate from application infrastructure because remote state must exist before normal Terraform environments can use it.
