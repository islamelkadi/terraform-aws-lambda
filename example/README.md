# Complete Lambda Function Example

This example demonstrates a full-featured Lambda function deployment with VPC integration, custom IAM policies, KMS encryption, and all available configuration options.

## Features

- VPC deployment in private subnets
- Custom IAM policies for DynamoDB and KMS access
- KMS encryption for environment variables
- Reserved concurrency configuration
- X-Ray tracing enabled
- CloudWatch Logs with 30-day retention
- S3-based deployment package
- Custom security group configuration

## Architecture

```
┌───────────────────────────────────────┐
│ VPC (10.0.0.0/16)                     │
│                                       │
│  ┌─────────────────────────────────┐  │
│  │ Private Subnets                 │  │
│  │ - 10.0.10.0/24 (AZ1)            │  │
│  │ - 10.0.11.0/24 (AZ2)            │  │
│  │                                 │  │
│  │  ┌────────────────────────────┐ │  │
│  │  │ Lambda Function            │ │  │
│  │  │ - X-Ray Tracing            │ │  │
│  │  │ - CloudWatch Logs          │ │  │
│  │  │ - KMS Encrypted Env Vars   │ │  │
│  │  └────────────────────────────┘ │  │
│  └─────────────────────────────────┘  │
└───────────────────────────────────────┘
         │
         ├─→ DynamoDB Table (encrypted)
         └─→ KMS Key (for encryption)
```

## Prerequisites

1. AWS credentials configured
2. S3 bucket for Lambda deployment packages
3. Lambda deployment package uploaded to S3

## Usage

1. Create and upload Lambda deployment package:

```bash
# Create a sample handler
mkdir -p lambda-src
cat > lambda-src/handlers.py << 'EOF'
import json
import os

def event_processor(event, context):
    table_name = os.environ.get('EVENTS_TABLE_NAME')
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Event processed',
            'table': table_name
        })
    }
EOF

# Package it
cd lambda-src
zip -r ../lambda-package.zip .
cd ..

# Upload to S3
aws s3 cp lambda-package.zip s3://my-lambda-deployments/lambda/event-processor/v1.0.0.zip
```

2. Update variables:

```bash
# Edit variables.tf or create terraform.tfvars
cat > terraform.tfvars << EOF
deployment_bucket = "my-lambda-deployments"
namespace         = "example"
environment       = "dev"
EOF
```

3. Deploy:

```bash
terraform init
terraform plan
terraform apply
```

4. Test the function:

```bash
aws lambda invoke \
  --function-name example-dev-event-processor-corporate-actions \
  --region ca-central-1 \
  --payload '{"test": "event"}' \
  response.json

cat response.json
```

## Cleanup

```bash
terraform destroy
```

## Cost Estimate

For this example configuration:
- Lambda: ~$0.20/million requests + $0.0000166667/GB-second
- CloudWatch Logs: ~$0.50/GB ingested
- VPC: NAT Gateway not included (would add ~$32/month)
- KMS: $1/month for key + $0.03/10,000 requests

Estimated monthly cost for low usage: ~$2-5
