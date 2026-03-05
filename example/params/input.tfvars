# Example input variables
# Copy this file and customize for your environment

environment = "dev"
namespace   = "example"
region      = "us-east-1"

# Production Lambda Configuration
# Replace these fictitious values with your actual AWS resources

# KMS key for Lambda encryption
kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

# VPC configuration for production Lambda
vpc_subnet_ids = [
  "subnet-12345678",
  "subnet-87654321"
]

vpc_security_group_ids = [
  "sg-12345678"
]

# Dead letter queue for error handling
dlq_arn = "arn:aws:sqs:us-east-1:123456789012:lambda-dlq"

