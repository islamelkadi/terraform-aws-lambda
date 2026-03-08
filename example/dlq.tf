# Supporting Infrastructure - Real DLQ resources for testing
# This infrastructure is created from remote GitHub modules to provide
# realistic dead letter queue dependencies for the primary module example.
# 
# Available module outputs (reference directly in main.tf):
# - module.dead_letter_queue.queue_arn
# - module.dead_letter_queue.queue_url
#
# Example usage in main.tf:
#   dead_letter_queue_arn = module.dead_letter_queue.queue_arn

module "dead_letter_queue" {
  source = "git::https://github.com/islamelkadi/terraform-aws-sqs.git"

  namespace   = var.namespace
  environment = var.environment
  name        = "example-dlq"
  region      = var.region

  # Direct reference to kms.tf module output
  kms_master_key_id = module.kms_key.key_id

  # DLQ-specific settings
  message_retention_seconds = 1209600  # 14 days

  tags = {
    Purpose = "example-supporting-infrastructure"
  }
}
