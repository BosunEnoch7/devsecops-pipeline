locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "Olatubosun Enoch David"
  }
}

# AWS runtime resources are intentionally deferred until the ECS deployment enhancement.
# This environment is intentionally minimal while the validation and security
# gates are introduced.
