# Lambda Example Variables

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
  default     = "example"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# Production Lambda Configuration (replace with your actual values)

variable "kms_key_arn" {
  description = "ARN of KMS key for Lambda encryption (replace with your actual KMS key)"
  type        = string
}

variable "vpc_subnet_ids" {
  description = "List of VPC subnet IDs for Lambda (replace with your actual private subnets)"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs for Lambda (replace with your actual security groups)"
  type        = list(string)
}

variable "dlq_arn" {
  description = "ARN of SQS dead letter queue (replace with your actual DLQ)"
  type        = string
}

