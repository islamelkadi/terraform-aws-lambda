# Primary Module Example - This demonstrates the terraform-aws-lambda module
# Supporting infrastructure (VPC, KMS, DLQ) is defined in separate files
# to keep this example focused on the module's core functionality.
#
# Lambda Function Examples
# Demonstrates various Lambda configurations with security control overrides

# ============================================================================
# Example 1: Basic Lambda Function
# Minimal configuration with fictitious deployment package
# Override: VPC and KMS not required for simple functions
# ============================================================================

module "basic_lambda" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = "basic-function"
  region      = var.region

  handler = "index.handler"
  runtime = "python3.13"

  # Fictitious deployment package - replace with your actual Lambda code
  # Create a simple Lambda: zip index.py -r lambda.zip
  filename = "${path.module}/lambda-packages/basic.zip"

  description = "Basic Lambda function for simple tasks"
  memory_size = 512
  timeout     = 60

  # Security Control Overrides: Relaxed for basic function
  security_control_overrides = {
    disable_vpc_requirement = true
    disable_kms_requirement = true
    justification           = "Basic Lambda function with no sensitive data or private resource access. VPC and KMS encryption not required."
  }

  # Basic monitoring
  enable_tracing     = true
  log_retention_days = 90

  tags = {
    Example = "basic"
  }
}

# ============================================================================
# Example 2: Production Lambda with Full Compliance
# All security controls enforced (VPC, KMS, DLQ, Reserved Concurrency)
# ============================================================================

module "production_lambda" {
  source = "../"

  namespace   = var.namespace
  environment = "prod"
  name        = "data-processor"
  region      = var.region

  handler  = "index.handler"
  runtime  = "python3.13"
  filename = "${path.module}/lambda-packages/processor.zip"

  description = "Production Lambda with full security compliance"
  memory_size = 2048
  timeout     = 300

  # Direct reference to vpc.tf module outputs
  vpc_config = {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [module.security_group.security_group_id]
  }

  # Direct reference to kms.tf module output
  kms_key_arn = module.kms_key.key_arn

  # Direct reference to dlq.tf module output
  dead_letter_config = {
    target_arn = module.dead_letter_queue.queue_arn
  }

  # Reserved Concurrency - prevent resource exhaustion
  reserved_concurrent_executions = 50

  # X-Ray Tracing - observability
  enable_tracing = true
  tracing_mode   = "Active"

  # CloudWatch Logs - 365-day retention for compliance
  log_retention_days = 365
  create_log_group   = true

  # Environment Variables
  environment_variables = {
    LOG_LEVEL = "INFO"
    STAGE     = "production"
  }

  tags = {
    Environment = "Production"
    Compliance  = "FullyCompliant"
    Example     = "production"
  }
}

# ============================================================================
# Example 3: API Lambda (API Gateway Integration)
# Override: VPC not required for public-facing functions
# ============================================================================

module "api_lambda" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = "public-api"
  region      = var.region

  handler  = "index.handler"
  runtime  = "python3.13"
  filename = "${path.module}/lambda-packages/api.zip"

  description = "Public-facing Lambda invoked by API Gateway"
  memory_size = 1024
  timeout     = 30

  # Security Control Override: VPC not required
  security_control_overrides = {
    disable_vpc_requirement = true
    justification           = "Public-facing Lambda invoked by API Gateway. VPC integration would add cold start latency without security benefit."
  }

  # Direct reference to kms.tf module output
  kms_key_arn = module.kms_key.key_arn

  # Direct reference to dlq.tf module output
  dead_letter_config = {
    target_arn = module.dead_letter_queue.queue_arn
  }

  reserved_concurrent_executions = 10
  enable_tracing                 = true
  log_retention_days             = 90

  environment_variables = {
    API_VERSION = "v1"
  }

  tags = {
    UseCase = "PublicAPI"
    Example = "api-gateway"
  }
}

