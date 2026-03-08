# Lambda Function Examples

This example demonstrates various Lambda function configurations with security control overrides.

## Structure

This example includes:
- **main.tf**: Primary module examples (3 Lambda configurations)
- **kms.tf**: Supporting KMS key infrastructure
- **vpc.tf**: Supporting VPC and security group infrastructure
- **dlq.tf**: Supporting SQS dead letter queue infrastructure

## Examples Included

### 1. Basic Lambda Function
Minimal configuration without VPC or KMS requirements. Suitable for simple, stateless functions.

### 2. Production Lambda with Full Compliance
Complete security configuration with VPC integration, KMS encryption, DLQ, reserved concurrency, and extended log retention.

### 3. API Lambda (API Gateway Integration)
Public-facing Lambda optimized for API Gateway with KMS encryption and DLQ, but without VPC to reduce cold start latency.

## Supporting Infrastructure

The supporting infrastructure files create real AWS resources from remote GitHub modules:
- **KMS Key**: Provides encryption for environment variables
- **VPC & Security Group**: Provides network isolation for production Lambda
- **Dead Letter Queue**: SQS queue for failed invocations

## Prerequisites

Lambda deployment packages are required in `lambda-packages/` directory:
- `basic.zip`
- `processor.zip`
- `api.zip`

## Usage

```bash
terraform init
terraform plan
terraform apply
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.34 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api_lambda"></a> [api\_lambda](#module\_api\_lambda) | ../ | n/a |
| <a name="module_basic_lambda"></a> [basic\_lambda](#module\_basic\_lambda) | ../ | n/a |
| <a name="module_dead_letter_queue"></a> [dead\_letter\_queue](#module\_dead\_letter\_queue) | git::https://github.com/islamelkadi/terraform-aws-sqs.git | v1.0.0 |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | git::https://github.com/islamelkadi/terraform-aws-kms.git | v1.0.0 |
| <a name="module_production_lambda"></a> [production\_lambda](#module\_production\_lambda) | ../ | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | git::https://github.com/islamelkadi/terraform-aws-vpc.git//modules/security-group | v1.0.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git::https://github.com/islamelkadi/terraform-aws-vpc.git//modules/vpc | v1.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for deployment | `string` | `"us-east-1"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"dev"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | `"example"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region for resources | `string` | `"us-east-1"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->