## ----------------------------------------------------------------------------
##  Copyright 2023 SevenPico, Inc.
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##  ./main.tf
##  This file contains code written only by SevenPico, Inc.
## ----------------------------------------------------------------------------
locals {
  enabled        = module.context.enabled
  policy_enabled = local.enabled && length(var.iam_policy) > 0
}

module "sqs" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.2.0"

  name = module.context.id

  create_dlq                            = var.dlq_enabled
  dlq_name                              = "${module.context.id}-${var.dlq_name_suffix}"
  dlq_content_based_deduplication       = var.dlq_content_based_deduplication
  dlq_deduplication_scope               = var.dlq_deduplication_scope
  dlq_kms_master_key_id                 = var.dlq_kms_master_key_id
  dlq_delay_seconds                     = var.dlq_delay_seconds
  dlq_kms_data_key_reuse_period_seconds = var.dlq_kms_data_key_reuse_period_seconds
  dlq_message_retention_seconds         = var.dlq_message_retention_seconds
  dlq_receive_wait_time_seconds         = var.dlq_receive_wait_time_seconds
  create_dlq_redrive_allow_policy       = var.create_dlq_redrive_allow_policy
  dlq_redrive_allow_policy              = var.dlq_redrive_allow_policy
  dlq_sqs_managed_sse_enabled           = var.dlq_sqs_managed_sse_enabled
  dlq_visibility_timeout_seconds        = var.dlq_visibility_timeout_seconds
  dlq_tags                              = merge(module.context.tags, var.dlq_tags)
  redrive_policy = var.dlq_enabled ? {
    maxReceiveCount = var.dlq_max_receive_count
  } : {}

  visibility_timeout_seconds        = var.visibility_timeout_seconds
  message_retention_seconds         = var.message_retention_seconds
  delay_seconds                     = var.delay_seconds
  receive_wait_time_seconds         = var.receive_wait_time_seconds
  max_message_size                  = var.max_message_size
  fifo_queue                        = var.fifo_queue
  content_based_deduplication       = var.content_based_deduplication
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  sqs_managed_sse_enabled           = var.sqs_managed_sse_enabled
  fifo_throughput_limit             = var.fifo_throughput_limit
  deduplication_scope               = var.deduplication_scope

  tags = module.context.tags
}


data "aws_iam_policy_document" "queue_policy" {
  count = local.policy_enabled ? 1 : 0

  dynamic "statement" {
    for_each = flatten([
      for policy in var.iam_policy : [
        for statement in policy.statements : merge(
          statement,
          {
            resources = [module.sqs.queue_arn]
          },
          var.iam_policy_limit_to_current_account ? {
            condition = concat(
              lookup(statement, "conditions", []),
              [{
                test     = "StringEquals"
                variable = "aws:SourceAccount"
                values   = [local.account_id]
              }]
            )
            } : {
            condition = lookup(statement, "conditions", [])
          }
        )
      ]
    ])

    content {
      sid           = lookup(statement.value, "sid", null)
      effect        = lookup(statement.value, "effect", null)
      actions       = lookup(statement.value, "actions", null)
      not_actions   = lookup(statement.value, "not_actions", null)
      resources     = lookup(statement.value, "resources", null)
      not_resources = lookup(statement.value, "not_resources", null)

      dynamic "principals" {
        for_each = lookup(statement.value, "principals", [])
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = lookup(statement.value, "not_principals", [])
        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = lookup(statement.value, "condition", [])
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_sqs_queue_policy" "sqs_queue_policy" {
  count = local.policy_enabled ? 1 : 0

  queue_url = module.sqs.queue_url
  policy    = one(data.aws_iam_policy_document.queue_policy[*].json)
}
