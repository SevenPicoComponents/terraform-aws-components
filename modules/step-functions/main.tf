locals {
  step_function_name = var.step_function_name != null && var.step_function_name != "" ? var.step_function_name : module.context.id
}

## ------------------------------------------------------------------------------
## Step function
## ------------------------------------------------------------------------------
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine
resource "aws_sfn_state_machine" "default" {
  count = module.context.enabled ? 1 : 0

  name       = local.step_function_name
  type       = upper(var.type)
  role_arn   = module.iam_role.arn
  definition = jsonencode(var.definition)

  dynamic "logging_configuration" {
    for_each = local.logging_enabled ? [true] : []

    content {
      log_destination        = lookup(var.logging_configuration, "log_destination", null) != null ? lookup(var.logging_configuration, "log_destination") : "${local.cloudwatch_log_group_arn}:*"
      include_execution_data = lookup(var.logging_configuration, "include_execution_data", null)
      level                  = lookup(var.logging_configuration, "level", null)
    }
  }

  dynamic "tracing_configuration" {
    for_each = module.context.enabled && var.tracing_enabled ? [true] : []
    content {
      enabled = true
    }
  }

  tags = module.context.tags
}
