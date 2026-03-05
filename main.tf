# Lambda Function Module
# Creates AWS Lambda function with security best practices

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  count = var.create_log_group ? 1 : 0

  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = local.tags
}

# IAM Role for Lambda (if create_role is true)
data "aws_iam_policy_document" "assume_role" {
  count = var.create_role ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  count = var.create_role ? 1 : 0

  name               = local.function_name
  assume_role_policy = var.assume_role_policy != null ? var.assume_role_policy : data.aws_iam_policy_document.assume_role[0].json
  description        = "IAM role for Lambda function ${local.function_name}"

  tags = local.tags
}

# Attach managed policies to Lambda role
resource "aws_iam_role_policy_attachment" "managed_policies" {
  for_each = var.create_role ? toset(concat(
    var.managed_policy_arns,
    var.vpc_config == null ? ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"] : [],
    var.vpc_config != null ? ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"] : []
  )) : toset([])

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

# Attach inline policies to Lambda role
resource "aws_iam_role_policy" "inline_policies" {
  for_each = var.create_role ? var.inline_policies : {}

  name   = each.key
  role   = aws_iam_role.this[0].name
  policy = each.value
}

# Lambda Function
resource "aws_lambda_function" "this" {
  function_name = local.function_name
  description   = var.description != "" ? var.description : "Lambda function ${local.function_name}"
  role          = var.create_role ? aws_iam_role.this[0].arn : var.role_arn
  handler       = var.handler
  runtime       = var.runtime
  memory_size   = var.memory_size
  timeout       = var.timeout
  architectures = var.architectures
  package_type  = var.package_type

  # Code deployment
  filename          = var.package_type == "Zip" ? var.filename : null
  s3_bucket         = var.package_type == "Zip" ? var.s3_bucket : null
  s3_key            = var.package_type == "Zip" ? var.s3_key : null
  s3_object_version = var.package_type == "Zip" ? var.s3_object_version : null
  image_uri         = var.package_type == "Image" ? var.image_uri : null

  # Environment variables
  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  # VPC configuration
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  # X-Ray tracing (enabled by default for observability)
  tracing_config {
    mode = var.enable_tracing ? var.tracing_mode : "PassThrough"
  }

  # Encryption for environment variables
  kms_key_arn = var.kms_key_arn

  # Reserved concurrency
  reserved_concurrent_executions = var.reserved_concurrent_executions >= 0 ? var.reserved_concurrent_executions : null

  # Layers
  layers = var.layers

  # Dead letter configuration
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_config != null ? [var.dead_letter_config] : []
    content {
      target_arn = dead_letter_config.value.target_arn
    }
  }

  # Ephemeral storage
  ephemeral_storage {
    size = var.ephemeral_storage_size
  }

  tags = local.tags

  # Ensure log group is created before Lambda function
  depends_on = [
    aws_cloudwatch_log_group.this,
    aws_iam_role.this,
    aws_iam_role_policy_attachment.managed_policies,
    aws_iam_role_policy.inline_policies
  ]
}

