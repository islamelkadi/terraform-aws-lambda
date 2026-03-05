# Lambda Function Module Outputs

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "function_qualified_arn" {
  description = "Qualified ARN of the Lambda function (includes version)"
  value       = aws_lambda_function.this.qualified_arn
}

output "function_version" {
  description = "Latest published version of the Lambda function"
  value       = aws_lambda_function.this.version
}

output "function_invoke_arn" {
  description = "ARN to be used for invoking Lambda function from API Gateway"
  value       = aws_lambda_function.this.invoke_arn
}

output "role_arn" {
  description = "ARN of the IAM role used by the Lambda function"
  value       = var.create_role ? aws_iam_role.this[0].arn : var.role_arn
}

output "role_name" {
  description = "Name of the IAM role used by the Lambda function"
  value       = var.create_role ? aws_iam_role.this[0].name : null
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = var.create_log_group ? aws_cloudwatch_log_group.this[0].name : null
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  value       = var.create_log_group ? aws_cloudwatch_log_group.this[0].arn : null
}

output "tags" {
  description = "Tags applied to the Lambda function"
  value       = aws_lambda_function.this.tags
}
