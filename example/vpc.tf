# Supporting Infrastructure - Real VPC resources for testing
# This infrastructure is created from remote GitHub modules to provide
# realistic networking dependencies for the primary module example.
# 
# Available module outputs (reference directly in main.tf):
# - module.vpc.vpc_id
# - module.vpc.private_subnet_ids
# - module.vpc.public_subnet_ids
# - module.vpc.default_security_group_id
#
# Example usage in main.tf:
#   subnet_ids = module.vpc.private_subnet_ids

module "vpc" {
  source = "git::https://github.com/islamelkadi/terraform-aws-vpc.git//modules/vpc?ref=v1.0.0"

  namespace   = var.namespace
  environment = var.environment
  name        = "example-vpc"
  region      = var.region

  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  availability_zones = ["${var.region}a", "${var.region}b"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

  tags = {
    Purpose = "example-supporting-infrastructure"
  }
}

module "security_group" {
  source = "git::https://github.com/islamelkadi/terraform-aws-vpc.git//modules/security-group?ref=v1.0.0"

  namespace   = var.namespace
  environment = var.environment
  name        = "lambda-sg"
  region      = var.region

  vpc_id      = module.vpc.vpc_id
  description = "Security group for Lambda functions"

  ingress_rules = []

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]

  tags = {
    Purpose = "example-supporting-infrastructure"
  }
}
