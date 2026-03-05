# Local values for naming and tagging

locals {
  # Use metadata module for standardized naming
  function_name_base = module.metadata.resource_prefix

  # Construct function name from components (with optional attributes)
  function_name = length(var.attributes) > 0 ? "${local.function_name_base}-${join(var.delimiter, var.attributes)}" : local.function_name_base

  # Merge tags with defaults
  tags = merge(
    var.tags,
    module.metadata.security_tags,
    {
      Name   = local.function_name
      Module = "terraform-aws-lambda"
    }
  )
}
