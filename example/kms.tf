# Supporting Infrastructure - Real KMS resources for testing
# This infrastructure is created from remote GitHub modules to provide
# realistic encryption key dependencies for the primary module example.
# 
# Available module outputs (reference directly in main.tf):
# - module.kms_key.key_arn
# - module.kms_key.key_id
#
# Example usage in main.tf:
#   kms_key_arn = module.kms_key.key_arn

module "kms_key" {
  source = "git::https://github.com/islamelkadi/terraform-aws-kms.git?ref=v1.0.0"

  namespace   = var.namespace
  environment = var.environment
  name        = "example-key"
  region      = var.region

  description             = "KMS key for example infrastructure"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Purpose = "example-supporting-infrastructure"
  }
}
