# Security Controls Validations
# Enforces security standards based on metadata module security controls
# Supports selective overrides with documented justification

locals {
  # Use security controls if provided, otherwise use permissive defaults
  security_controls = var.security_controls != null ? var.security_controls : {
    encryption = {
      require_kms_customer_managed  = false
      require_encryption_at_rest    = false
      require_encryption_in_transit = false
      enable_kms_key_rotation       = false
    }
    logging = {
      require_cloudwatch_logs = false
      min_log_retention_days  = 1
      require_access_logging  = false
      require_flow_logs       = false
    }
    monitoring = {
      enable_xray_tracing         = false
      enable_enhanced_monitoring  = false
      enable_performance_insights = false
      require_cloudtrail          = false
    }
    network = {
      require_private_subnets = false
      require_vpc_endpoints   = false
      block_public_ingress    = false
      require_imdsv2          = false
    }
    compliance = {
      enable_point_in_time_recovery = false
      require_reserved_concurrency  = false
      enable_deletion_protection    = false
    }
  }

  # Apply overrides to security controls
  # Controls are enforced UNLESS explicitly overridden with justification
  kms_encryption_required       = local.security_controls.encryption.require_kms_customer_managed && !var.security_control_overrides.disable_kms_requirement
  cloudwatch_logs_required      = local.security_controls.logging.require_cloudwatch_logs && !var.security_control_overrides.disable_cloudwatch_logs
  min_log_retention             = local.security_controls.logging.min_log_retention_days
  log_retention_enforced        = !var.security_control_overrides.disable_log_retention_validation
  xray_tracing_required         = local.security_controls.monitoring.enable_xray_tracing && !var.security_control_overrides.disable_xray_tracing
  vpc_required                  = local.security_controls.network.require_private_subnets && !var.security_control_overrides.disable_vpc_requirement
  reserved_concurrency_required = local.security_controls.compliance.require_reserved_concurrency && !var.security_control_overrides.disable_reserved_concurrency
  dead_letter_queue_required    = !var.security_control_overrides.disable_dead_letter_queue

  # Validation results
  kms_validation_passed                  = !local.kms_encryption_required || var.kms_key_arn != null
  logs_validation_passed                 = !local.cloudwatch_logs_required || var.create_log_group
  retention_validation_passed            = !local.log_retention_enforced || var.log_retention_days >= local.min_log_retention
  xray_validation_passed                 = !local.xray_tracing_required || var.enable_tracing
  vpc_validation_passed                  = !local.vpc_required || var.vpc_config != null
  reserved_concurrency_validation_passed = !local.reserved_concurrency_required || var.reserved_concurrent_executions >= 0
  dead_letter_queue_validation_passed    = !local.dead_letter_queue_required || var.dead_letter_config != null

  # Audit trail for overrides
  has_overrides = (
    var.security_control_overrides.disable_vpc_requirement ||
    var.security_control_overrides.disable_kms_requirement ||
    var.security_control_overrides.disable_cloudwatch_logs ||
    var.security_control_overrides.disable_xray_tracing ||
    var.security_control_overrides.disable_reserved_concurrency ||
    var.security_control_overrides.disable_dead_letter_queue ||
    var.security_control_overrides.disable_log_retention_validation
  )

  justification_provided = var.security_control_overrides.justification != ""
  override_audit_passed  = !local.has_overrides || local.justification_provided
}

# Security Controls Check Block
check "security_controls_compliance" {
  assert {
    condition     = local.kms_validation_passed
    error_message = "Security control violation: KMS customer-managed key is required but kms_key_arn is not provided. Set security_control_overrides.disable_kms_requirement=true with justification if this is intentional."
  }

  assert {
    condition     = local.logs_validation_passed
    error_message = "Security control violation: CloudWatch Logs are required but create_log_group is false. Set security_control_overrides.disable_cloudwatch_logs=true with justification if this is intentional."
  }

  assert {
    condition     = local.retention_validation_passed
    error_message = "Security control violation: Log retention (${var.log_retention_days} days) is less than required minimum (${local.min_log_retention} days). Set security_control_overrides.disable_log_retention_validation=true with justification if this is intentional."
  }

  assert {
    condition     = local.xray_validation_passed
    error_message = "Security control violation: X-Ray tracing is required but enable_tracing is false. Set security_control_overrides.disable_xray_tracing=true with justification if this is intentional."
  }

  assert {
    condition     = local.vpc_validation_passed
    error_message = "Security control violation: VPC configuration is required but vpc_config is not provided. Set security_control_overrides.disable_vpc_requirement=true with justification if this is a public-facing Lambda (API Gateway, CloudFront, etc)."
  }

  assert {
    condition     = local.reserved_concurrency_validation_passed
    error_message = "Security control violation: Reserved concurrency is required but not configured. Set reserved_concurrent_executions >= 0 or set security_control_overrides.disable_reserved_concurrency=true with justification."
  }

  assert {
    condition     = local.dead_letter_queue_validation_passed
    error_message = "Security control violation: Dead letter queue is required but not configured. Set dead_letter_config or set security_control_overrides.disable_dead_letter_queue=true with justification."
  }

  assert {
    condition     = local.override_audit_passed
    error_message = "Security control overrides detected but no justification provided. Please document the business reason in security_control_overrides.justification for audit compliance."
  }
}
