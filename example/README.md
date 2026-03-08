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
<!-- END_TF_DOCS -->