# Terraform AWS Lambda Module

A reusable Terraform module for creating AWS Lambda functions with AWS Security Hub compliance (FSBP, CIS, NIST 800-53, NIST 800-171, PCI DSS), VPC integration, KMS encryption, and flexible security control overrides.

## Prerequisites

This module is designed for macOS. The following must already be installed on your machine:
- Python 3 and pip
- [Kiro](https://kiro.dev) and Kiro CLI
- [Homebrew](https://brew.sh)

To install the remaining development tools, run:

```bash
make bootstrap
```

This will install/upgrade: tfenv, Terraform (via tfenv), tflint, terraform-docs, checkov, and pre-commit.


## Security

### Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles){:target="_blank"} module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| KMS customer-managed keys | Optional | Required | Required |
| VPC integration | Optional | Required | Required |
| Reserved concurrency | Optional | Required | Required |
| Dead letter queue | Optional | Required | Required |
| X-Ray tracing | Optional | Required | Required |
| Log retention | 7 days | 90 days | 365 days |

For full details on security profiles and how controls vary by environment, see the <a href="https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles" target="_blank">Security Profiles</a> documentation.
## Examples Included

### 1. Basic Lambda Function
Minimal configuration for simple tasks with fictitious deployment package.

**Features:**
- No VPC integration (public Lambda)
- No KMS encryption (no sensitive data)
- X-Ray tracing enabled
- 7-day log retention
- Security control overrides for simplicity

**Use Cases:**
- Simple data transformations
- Scheduled tasks
- Event-driven processing without sensitive data

### 2. Production Lambda with Full Compliance
Full security compliance configuration with all controls enforced.

**Features:**
- VPC integration (private subnets)
- KMS encryption for environment variables
- Dead letter queue for error handling
- Reserved concurrency (50)
- X-Ray tracing (Active mode)
- 365-day log retention
- Custom IAM policies

**Use Cases:**
- Production workloads
- Processing sensitive data
- Database access from private subnets
- High-availability requirements

### 3. API Lambda (API Gateway Integration)
Public-facing Lambda optimized for API Gateway.

**Features:**
- No VPC integration (reduces cold start)
- KMS encryption enabled
- Dead letter queue
- Reserved concurrency (10)
- X-Ray tracing
- 90-day log retention

**Use Cases:**
- REST API endpoints
- GraphQL resolvers
- Webhook handlers
- Public-facing services

## Before You Start

Before using these examples, you need:

1. **Lambda Deployment Packages** - Create ZIP files with your Lambda code
2. **KMS Key** - For encrypting environment variables (production/API examples)
3. **VPC Resources** - Private subnets and security groups (production example)
4. **Dead Letter Queue** - SQS queue for error handling (production/API examples)

## Usage

### Step 1: Create Lambda Deployment Packages

Create simple Lambda functions for testing:

```bash
# Create lambda-packages directory
mkdir -p lambda-packages

# Basic Lambda
cat > index.py << 'EOF'
def handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from Basic Lambda!'
    }
EOF
zip lambda-packages/basic.zip index.py

# Production Lambda
cat > index.py << 'EOF'
import os
def handler(event, context):
    log_level = os.environ.get('LOG_LEVEL', 'INFO')
    return {
        'statusCode': 200,
        'body': f'Production Lambda - Log Level: {log_level}'
    }
EOF
zip lambda-packages/processor.zip index.py

# API Lambda
cat > index.py << 'EOF'
import json
def handler(event, context):
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps({'message': 'API Lambda response'})
    }
EOF
zip lambda-packages/api.zip index.py

# Clean up
rm index.py
```

### Step 2: Update Variables

Edit `params/input.tfvars` and replace fictitious values with your actual AWS resources:

```hcl
namespace   = "your-org"
environment = "dev"
region      = "us-east-1"

# Replace with your actual KMS key ARN
kms_key_arn = "arn:aws:kms:us-east-1:YOUR_ACCOUNT:key/YOUR_KEY_ID"

# Replace with your actual VPC subnet IDs
vpc_subnet_ids = [
  "subnet-YOUR_SUBNET_1",
  "subnet-YOUR_SUBNET_2"
]

# Replace with your actual security group IDs
vpc_security_group_ids = [
  "sg-YOUR_SECURITY_GROUP"
]

# Replace with your actual SQS DLQ ARN
dlq_arn = "arn:aws:sqs:us-east-1:YOUR_ACCOUNT:YOUR_DLQ_NAME"
```

### Step 3: Deploy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan -var-file=params/input.tfvars

# Apply the configuration
terraform apply -var-file=params/input.tfvars
```

### Step 4: Test Lambda Functions

```bash
# Test basic Lambda
aws lambda invoke \
  --function-name example-dev-basic-function \
  --region us-east-1 \
  response.json && cat response.json

# Test production Lambda
aws lambda invoke \
  --function-name example-prod-data-processor \
  --region us-east-1 \
  response.json && cat response.json

# Test API Lambda
aws lambda invoke \
  --function-name example-dev-public-api \
  --region us-east-1 \
  response.json && cat response.json
```

## Security Control Overrides

These examples demonstrate the security control override system:

### Basic Example
```hcl
security_control_overrides = {
  disable_vpc_requirement = true
  disable_kms_requirement = true
  justification           = "Basic Lambda function with no sensitive data or private resource access."
}
```

### Production Example
No overrides - all security controls enforced (VPC, KMS, DLQ, reserved concurrency)

### API Example
```hcl
security_control_overrides = {
  disable_vpc_requirement = true
  justification           = "Public-facing Lambda invoked by API Gateway. VPC would add cold start latency."
}
```

## Cost Estimate

**Lambda Pricing (US East):**
- Requests: $0.20 per 1M requests
- Duration: $0.0000166667 per GB-second
- Free tier: 1M requests + 400,000 GB-seconds per month

**Example Monthly Costs:**
- Basic Lambda (100K requests, 512MB, 1s avg): ~$0.10
- Production Lambda (1M requests, 2GB, 5s avg): ~$18.00
- API Lambda (500K requests, 1GB, 0.5s avg): ~$4.50

**Additional Costs:**
- CloudWatch Logs: $0.50 per GB ingested
- X-Ray: $5 per 1M traces recorded
- KMS: $1/month per key + $0.03 per 10,000 requests
- VPC: No additional cost (NAT Gateway separate)

## Common Issues

### Cold Start Latency

**Problem:** First invocation is slow

**Solutions:**
- Use provisioned concurrency (adds cost)
- Avoid VPC for public-facing functions
- Reduce deployment package size
- Use ARM64 architecture (Graviton2)

### VPC Connectivity Issues

**Problem:** Lambda can't access internet or AWS services

**Solutions:**
- Ensure NAT Gateway in public subnet
- Add VPC endpoints for AWS services (S3, DynamoDB, etc.)
- Check security group egress rules
- Verify route table configuration

### Permission Errors

**Problem:** Lambda can't access AWS resources

**Solutions:**
- Check IAM role has required permissions
- Verify resource-based policies (S3, SQS, etc.)
- Check KMS key policy for encryption access
- Review CloudWatch Logs for specific errors

### Deployment Package Too Large

**Problem:** Deployment package exceeds 50MB (direct upload) or 250MB (unzipped)

**Solutions:**
- Use Lambda layers for dependencies
- Deploy via S3 (supports up to 250MB zipped)
- Use container images (up to 10GB)
- Remove unnecessary files from package

## Clean Up

```bash
# Destroy all resources
terraform destroy -var-file=params/input.tfvars
```

**Note:** CloudWatch Log Groups may be retained based on retention settings.

## Advanced Configuration

### Adding Custom IAM Policies

```hcl
module "custom_lambda" {
  source = "../"
  
  # ... other configuration ...
  
  inline_policies = {
    s3_access = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject"]
        Resource = "arn:aws:s3:::my-bucket/*"
      }]
    })
  }
}
```

### Using Lambda Layers

```hcl
module "lambda_with_layers" {
  source = "../"
  
  # ... other configuration ...
  
  layers = [
    "arn:aws:lambda:us-east-1:123456789012:layer:my-layer:1"
  ]
}
```

### Container Image Deployment

```hcl
module "container_lambda" {
  source = "../"
  
  # ... other configuration ...
  
  package_type = "Image"
  image_uri    = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-lambda:latest"
}
```

## References

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
- [Lambda Pricing](https://aws.amazon.com/lambda/pricing/)
- [VPC Integration](https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html)
- [X-Ray Tracing](https://docs.aws.amazon.com/lambda/latest/dg/services-xray.html)

- Terraform validation checks for compliance

## Usage Examples

### Basic Example

```hcl
module "lambda" {
  source = "github.com/islamelkadi/terraform-aws-lambda?ref=v1.0.0"
  
  namespace   = "example"
  environment = "prod"
  name        = "event-processor"
  region      = "us-east-1"
  
  runtime = "python3.13"
  handler = "index.handler"
  filename = "lambda.zip"
  
  memory_size = 512
  timeout     = 30
  
  environment_variables = {
    LOG_LEVEL = "INFO"
  }
  
  tags = {
    Project = "CorporateActions"
  }
}
```

### Production Function with Security Controls

```hcl
module "lambda" {
  source = "github.com/islamelkadi/terraform-aws-lambda?ref=v1.0.0"
  
  # Pass security controls from metadata module
  security_controls = module.metadata.security_controls
  
  namespace   = "example"
  environment = "prod"
  name        = "event-processor"
  region      = "us-east-1"
  
  runtime = "python3.13"
  handler = "index.handler"
  filename = "lambda.zip"
  
  # VPC configuration (required by security controls)
  vpc_config = {
    subnet_ids         = module.vpc.private_subnet_ids
    security_group_ids = [module.lambda_sg.id]
  }
  
  # KMS encryption (required by security controls)
  kms_key_arn = module.kms.key_arn
  
  # Reserved concurrency (required by security controls)
  reserved_concurrent_executions = 10
  
  # Dead letter queue (required by security controls)
  dead_letter_config = {
    target_arn = module.dlq.arn
  }
  
  # CloudWatch Logs with compliance retention
  log_retention_days = 365
  
  # X-Ray tracing enabled
  enable_tracing = true
  
  memory_size = 1024
  timeout     = 300
  
  environment_variables = {
    DB_ENDPOINT = module.rds.endpoint
    S3_BUCKET   = module.s3.bucket_name
  }
}
```

### Development Function with Overrides

```hcl
module "lambda" {
  source = "github.com/islamelkadi/terraform-aws-lambda?ref=v1.0.0"
  
  security_controls = module.metadata.security_controls
  
  # Override security controls for development
  security_control_overrides = {
    disable_vpc_requirement      = true
    disable_reserved_concurrency = true
    disable_dead_letter_queue    = true
    justification = "Development function for testing. No VPC access needed. Unpredictable load pattern. Non-critical failures acceptable."
  }
  
  namespace   = "example"
  environment = "dev"
  name        = "test-function"
  region      = "us-east-1"
  
  runtime = "python3.13"
  handler = "index.handler"
  filename = "lambda.zip"
  
  memory_size = 256
  timeout     = 60
  
  log_retention_days = 7
}
```

### Public API Function

```hcl
module "api_lambda" {
  source = "github.com/islamelkadi/terraform-aws-lambda?ref=v1.0.0"
  
  security_controls = module.metadata.security_controls
  
  # Override VPC requirement for public API
  security_control_overrides = {
    disable_vpc_requirement = true
    justification = "Public API function invoked by API Gateway. No private resource access required. Reviewed and approved by security team."
  }
  
  namespace   = "example"
  environment = "prod"
  name        = "api-handler"
  region      = "us-east-1"
  
  runtime = "nodejs20.x"
  handler = "index.handler"
  filename = "api-lambda.zip"
  
  # Still use KMS encryption for environment variables
  kms_key_arn = module.kms.key_arn
  
  # Reserved concurrency for API stability
  reserved_concurrent_executions = 100
  
  memory_size = 512
  timeout     = 30
  
  environment_variables = {
    API_KEY_SECRET = "arn:aws:secretsmanager:..."
  }
}
```


## MCP Servers

This module includes two [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) servers configured in `.kiro/settings/mcp.json` for use with Kiro:

| Server | Package | Description |
|--------|---------|-------------|
| `aws-docs` | `awslabs.aws-documentation-mcp-server@latest` | Provides access to AWS documentation for contextual lookups of service features, API references, and best practices. |
| `terraform` | `awslabs.terraform-mcp-server@latest` | Enables Terraform operations (init, validate, plan, fmt, tflint) directly from the IDE with auto-approved commands for common workflows. |

Both servers run via `uvx` and require no additional installation beyond the [bootstrap](#prerequisites) step.

<!-- BEGIN_TF_DOCS -->


## Usage

```hcl
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

  # VPC Configuration - replace with your actual VPC resources
  vpc_config = {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = var.vpc_security_group_ids
  }

  # KMS Encryption - replace with your actual KMS key ARN
  kms_key_arn = var.kms_key_arn

  # Dead Letter Queue - replace with your actual SQS queue ARN
  dead_letter_config = {
    target_arn = var.dlq_arn
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

  # KMS encryption for environment variables
  kms_key_arn = var.kms_key_arn

  # Dead letter queue
  dead_letter_config = {
    target_arn = var.dlq_arn
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

```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.34 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.34 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metadata"></a> [metadata](#module\_metadata) | github.com/islamelkadi/terraform-aws-metadata | v1.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.inline_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.managed_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_architectures"></a> [architectures](#input\_architectures) | Instruction set architecture for the Lambda function (x86\_64 or arm64) | `list(string)` | <pre>[<br/>  "x86_64"<br/>]</pre> | no |
| <a name="input_assume_role_policy"></a> [assume\_role\_policy](#input\_assume\_role\_policy) | Custom assume role policy JSON. If not provided, a default Lambda assume role policy is used | `string` | `null` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes for naming | `list(string)` | `[]` | no |
| <a name="input_create_log_group"></a> [create\_log\_group](#input\_create\_log\_group) | Whether to create a CloudWatch Log Group for the Lambda function | `bool` | `true` | no |
| <a name="input_create_role"></a> [create\_role](#input\_create\_role) | Whether to create an IAM role for the Lambda function | `bool` | `true` | no |
| <a name="input_dead_letter_config"></a> [dead\_letter\_config](#input\_dead\_letter\_config) | Dead letter queue configuration for failed invocations | <pre>object({<br/>    target_arn = string<br/>  })</pre> | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to use between name components | `string` | `"-"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the Lambda function | `string` | `""` | no |
| <a name="input_enable_tracing"></a> [enable\_tracing](#input\_enable\_tracing) | Enable X-Ray tracing for the Lambda function | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Map of environment variables for the Lambda function | `map(string)` | `{}` | no |
| <a name="input_ephemeral_storage_size"></a> [ephemeral\_storage\_size](#input\_ephemeral\_storage\_size) | Size of the /tmp directory in MB | `number` | `512` | no |
| <a name="input_filename"></a> [filename](#input\_filename) | Path to the Lambda deployment package (Zip) | `string` | `null` | no |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entrypoint in the code | `string` | `null` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | ECR image URI for container-based Lambda (Image package type) | `string` | `null` | no |
| <a name="input_inline_policies"></a> [inline\_policies](#input\_inline\_policies) | Map of inline IAM policies to attach to the Lambda role (name => policy JSON) | `map(string)` | `{}` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of KMS key for encrypting environment variables and log group | `string` | `null` | no |
| <a name="input_layers"></a> [layers](#input\_layers) | List of Lambda layer ARNs to attach | `list(string)` | `[]` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch Logs retention period in days | `number` | `365` | no |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns) | List of IAM managed policy ARNs to attach to the Lambda role | `list(string)` | `[]` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory in MB allocated to the Lambda function | `number` | `128` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Lambda function | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_package_type"></a> [package\_type](#input\_package\_type) | Lambda deployment package type (Zip or Image) | `string` | `"Zip"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | Number of reserved concurrent executions. Set to -1 for unreserved | `number` | `-1` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | ARN of an existing IAM role to use. Required if create\_role is false | `string` | `null` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | Runtime environment for the Lambda function | `string` | `null` | no |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | S3 bucket containing the Lambda deployment package | `string` | `null` | no |
| <a name="input_s3_key"></a> [s3\_key](#input\_s3\_key) | S3 key of the Lambda deployment package | `string` | `null` | no |
| <a name="input_s3_object_version"></a> [s3\_object\_version](#input\_s3\_object\_version) | S3 object version of the Lambda deployment package | `string` | `null` | no |
| <a name="input_security_control_overrides"></a> [security\_control\_overrides](#input\_security\_control\_overrides) | Override specific security controls for this Lambda function.<br/>Only use when there's a documented business justification.<br/><br/>Example use cases:<br/>- disable\_vpc\_requirement: Public API functions (API Gateway integration, no private resource access)<br/>- disable\_kms\_requirement: No environment variables or only public configuration<br/>- disable\_reserved\_concurrency: Development/testing functions with variable load<br/>- disable\_dead\_letter\_queue: Synchronous-only invocations with caller-side error handling<br/><br/>IMPORTANT: Document the reason in the 'justification' field for audit purposes. | <pre>object({<br/>    disable_vpc_requirement          = optional(bool, false)<br/>    disable_kms_requirement          = optional(bool, false)<br/>    disable_cloudwatch_logs          = optional(bool, false)<br/>    disable_xray_tracing             = optional(bool, false)<br/>    disable_reserved_concurrency     = optional(bool, false)<br/>    disable_dead_letter_queue        = optional(bool, false)<br/>    disable_log_retention_validation = optional(bool, false)<br/><br/>    # Audit trail - document why controls are disabled<br/>    justification = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "disable_cloudwatch_logs": false,<br/>  "disable_dead_letter_queue": false,<br/>  "disable_kms_requirement": false,<br/>  "disable_log_retention_validation": false,<br/>  "disable_reserved_concurrency": false,<br/>  "disable_vpc_requirement": false,<br/>  "disable_xray_tracing": false,<br/>  "justification": ""<br/>}</pre> | no |
| <a name="input_security_controls"></a> [security\_controls](#input\_security\_controls) | Security controls configuration from metadata module. Used to enforce security standards | <pre>object({<br/>    encryption = object({<br/>      require_kms_customer_managed  = bool<br/>      require_encryption_at_rest    = bool<br/>      require_encryption_in_transit = bool<br/>      enable_kms_key_rotation       = bool<br/>    })<br/>    logging = object({<br/>      require_cloudwatch_logs = bool<br/>      min_log_retention_days  = number<br/>      require_access_logging  = bool<br/>      require_flow_logs       = bool<br/>    })<br/>    monitoring = object({<br/>      enable_xray_tracing         = bool<br/>      enable_enhanced_monitoring  = bool<br/>      enable_performance_insights = bool<br/>      require_cloudtrail          = bool<br/>    })<br/>    network = object({<br/>      require_private_subnets = bool<br/>      require_vpc_endpoints   = bool<br/>      block_public_ingress    = bool<br/>      require_imdsv2          = bool<br/>    })<br/>    compliance = object({<br/>      enable_point_in_time_recovery = bool<br/>      require_reserved_concurrency  = bool<br/>      enable_deletion_protection    = bool<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Maximum execution time in seconds | `number` | `3` | no |
| <a name="input_tracing_mode"></a> [tracing\_mode](#input\_tracing\_mode) | X-Ray tracing mode (Active or PassThrough) | `string` | `"Active"` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | VPC configuration for Lambda (subnet\_ids and security\_group\_ids) | <pre>object({<br/>    subnet_ids         = list(string)<br/>    security_group_ids = list(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | ARN of the Lambda function |
| <a name="output_function_invoke_arn"></a> [function\_invoke\_arn](#output\_function\_invoke\_arn) | ARN to be used for invoking Lambda function from API Gateway |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name of the Lambda function |
| <a name="output_function_qualified_arn"></a> [function\_qualified\_arn](#output\_function\_qualified\_arn) | Qualified ARN of the Lambda function (includes version) |
| <a name="output_function_version"></a> [function\_version](#output\_function\_version) | Latest published version of the Lambda function |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | ARN of the CloudWatch Log Group |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name of the CloudWatch Log Group |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the IAM role used by the Lambda function |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the IAM role used by the Lambda function |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the Lambda function |


## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
<!-- END_TF_DOCS -->

## Examples

See [example/](example/) for a complete working example with all features.

