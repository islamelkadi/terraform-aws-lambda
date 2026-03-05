# Lambda Function Module Variables

# Metadata variables for consistent naming
variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "attributes" {
  description = "Additional attributes for naming"
  type        = list(string)
  default     = []
}

variable "delimiter" {
  description = "Delimiter to use between name components"
  type        = string
  default     = "-"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

# Lambda function configuration
variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

variable "handler" {
  description = "Function entrypoint in the code"
  type        = string
  default     = null
}

variable "runtime" {
  description = "Runtime environment for the Lambda function"
  type        = string
  default     = null
}

variable "memory_size" {
  description = "Amount of memory in MB allocated to the Lambda function"
  type        = number
  default     = 128

  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "Memory size must be between 128 MB and 10240 MB"
  }
}

variable "timeout" {
  description = "Maximum execution time in seconds"
  type        = number
  default     = 3

  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "Timeout must be between 1 and 900 seconds"
  }
}

variable "architectures" {
  description = "Instruction set architecture for the Lambda function (x86_64 or arm64)"
  type        = list(string)
  default     = ["x86_64"]

  validation {
    condition     = length(var.architectures) == 1 && contains(["x86_64", "arm64"], var.architectures[0])
    error_message = "Architecture must be x86_64 or arm64"
  }
}

variable "package_type" {
  description = "Lambda deployment package type (Zip or Image)"
  type        = string
  default     = "Zip"

  validation {
    condition     = contains(["Zip", "Image"], var.package_type)
    error_message = "Package type must be Zip or Image"
  }
}

# Code deployment - Zip package
variable "filename" {
  description = "Path to the Lambda deployment package (Zip)"
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket containing the Lambda deployment package"
  type        = string
  default     = null
}

variable "s3_key" {
  description = "S3 key of the Lambda deployment package"
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "S3 object version of the Lambda deployment package"
  type        = string
  default     = null
}

# Code deployment - Image package
variable "image_uri" {
  description = "ECR image URI for container-based Lambda (Image package type)"
  type        = string
  default     = null
}

# Environment and runtime configuration
variable "environment_variables" {
  description = "Map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "vpc_config" {
  description = "VPC configuration for Lambda (subnet_ids and security_group_ids)"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "layers" {
  description = "List of Lambda layer ARNs to attach"
  type        = list(string)
  default     = []
}

variable "ephemeral_storage_size" {
  description = "Size of the /tmp directory in MB"
  type        = number
  default     = 512

  validation {
    condition     = var.ephemeral_storage_size >= 512 && var.ephemeral_storage_size <= 10240
    error_message = "Ephemeral storage size must be between 512 MB and 10240 MB"
  }
}

variable "reserved_concurrent_executions" {
  description = "Number of reserved concurrent executions. Set to -1 for unreserved"
  type        = number
  default     = -1

  validation {
    condition     = var.reserved_concurrent_executions >= -1
    error_message = "Reserved concurrent executions must be -1 or greater"
  }
}

variable "dead_letter_config" {
  description = "Dead letter queue configuration for failed invocations"
  type = object({
    target_arn = string
  })
  default = null
}

# Observability
variable "enable_tracing" {
  description = "Enable X-Ray tracing for the Lambda function"
  type        = bool
  default     = true
}

variable "tracing_mode" {
  description = "X-Ray tracing mode (Active or PassThrough)"
  type        = string
  default     = "Active"

  validation {
    condition     = contains(["Active", "PassThrough"], var.tracing_mode)
    error_message = "Tracing mode must be Active or PassThrough"
  }
}

variable "create_log_group" {
  description = "Whether to create a CloudWatch Log Group for the Lambda function"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention period in days"
  type        = number
  default     = 365

  validation {
    condition     = var.log_retention_days >= 90
    error_message = "Log retention must be at least 90 days for NIST compliance"
  }
}

# Encryption
variable "kms_key_arn" {
  description = "ARN of KMS key for encrypting environment variables and log group"
  type        = string
  default     = null
}

# IAM configuration
variable "create_role" {
  description = "Whether to create an IAM role for the Lambda function"
  type        = bool
  default     = true
}

variable "role_arn" {
  description = "ARN of an existing IAM role to use. Required if create_role is false"
  type        = string
  default     = null
}

variable "assume_role_policy" {
  description = "Custom assume role policy JSON. If not provided, a default Lambda assume role policy is used"
  type        = string
  default     = null
}

variable "managed_policy_arns" {
  description = "List of IAM managed policy ARNs to attach to the Lambda role"
  type        = list(string)
  default     = []
}

variable "inline_policies" {
  description = "Map of inline IAM policies to attach to the Lambda role (name => policy JSON)"
  type        = map(string)
  default     = {}
}

# Security Controls
variable "security_controls" {
  description = "Security controls configuration from metadata module. Used to enforce security standards"
  type = object({
    encryption = object({
      require_kms_customer_managed  = bool
      require_encryption_at_rest    = bool
      require_encryption_in_transit = bool
      enable_kms_key_rotation       = bool
    })
    logging = object({
      require_cloudwatch_logs = bool
      min_log_retention_days  = number
      require_access_logging  = bool
      require_flow_logs       = bool
    })
    monitoring = object({
      enable_xray_tracing         = bool
      enable_enhanced_monitoring  = bool
      enable_performance_insights = bool
      require_cloudtrail          = bool
    })
    network = object({
      require_private_subnets = bool
      require_vpc_endpoints   = bool
      block_public_ingress    = bool
      require_imdsv2          = bool
    })
    compliance = object({
      enable_point_in_time_recovery = bool
      require_reserved_concurrency  = bool
      enable_deletion_protection    = bool
    })
  })
  default = null
}

# Security Control Overrides
variable "security_control_overrides" {
  description = <<-EOT
    Override specific security controls for this Lambda function.
    Only use when there's a documented business justification.
    
    Example use cases:
    - disable_vpc_requirement: Public API functions (API Gateway integration, no private resource access)
    - disable_kms_requirement: No environment variables or only public configuration
    - disable_reserved_concurrency: Development/testing functions with variable load
    - disable_dead_letter_queue: Synchronous-only invocations with caller-side error handling
    
    IMPORTANT: Document the reason in the 'justification' field for audit purposes.
  EOT

  type = object({
    disable_vpc_requirement          = optional(bool, false)
    disable_kms_requirement          = optional(bool, false)
    disable_cloudwatch_logs          = optional(bool, false)
    disable_xray_tracing             = optional(bool, false)
    disable_reserved_concurrency     = optional(bool, false)
    disable_dead_letter_queue        = optional(bool, false)
    disable_log_retention_validation = optional(bool, false)

    # Audit trail - document why controls are disabled
    justification = optional(string, "")
  })

  default = {
    disable_vpc_requirement          = false
    disable_kms_requirement          = false
    disable_cloudwatch_logs          = false
    disable_xray_tracing             = false
    disable_reserved_concurrency     = false
    disable_dead_letter_queue        = false
    disable_log_retention_validation = false
    justification                    = ""
  }
}
