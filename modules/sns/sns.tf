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
locals {
  sub_principals                = { for k, p in var.sub_principals : k => p if try(p.condition.test, null) == null }
  sub_principals_with_condition = { for k, p in var.sub_principals : k => p if try(p.condition.test, null) != null }

  pub_principals                = { for k, p in var.pub_principals : k => p if try(p.condition.test, null) == null }
  pub_principals_with_condition = { for k, p in var.pub_principals : k => p if try(p.condition.test, null) != null }
}


## ----------------------------------------------------------------------------
##  ./sns.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

resource "aws_sns_topic" "this" {
  count = module.context.enabled ? 1 : 0

  name              = module.context.id
  name_prefix       = null # don't use
  display_name      = module.context.id
  tags              = module.context.tags
  kms_master_key_id = var.kms_master_key_id

  # TODO
  fifo_topic                               = null
  content_based_deduplication              = null
  policy                                   = null
  delivery_policy                          = null
  application_success_feedback_role_arn    = null
  application_success_feedback_sample_rate = null
  application_failure_feedback_role_arn    = null
  http_success_feedback_role_arn           = null
  http_success_feedback_sample_rate        = null
  http_failure_feedback_role_arn           = null
  lambda_success_feedback_role_arn         = null
  lambda_success_feedback_sample_rate      = null
  lambda_failure_feedback_role_arn         = null
  sqs_success_feedback_role_arn            = null
  sqs_success_feedback_sample_rate         = null
  sqs_failure_feedback_role_arn            = null
  firehose_success_feedback_role_arn       = null
  firehose_success_feedback_sample_rate    = null
  firehose_failure_feedback_role_arn       = null
}

resource "aws_sns_topic_policy" "this" {
  count = module.context.enabled ? 1 : 0

  arn    = one(aws_sns_topic.this[*].arn)
  policy = one(data.aws_iam_policy_document.this[*].json)
}

data "aws_iam_policy_document" "this" {
  count = module.context.enabled ? 1 : 0

  policy_id = module.context.id

  statement {
    sid       = "AllowPub"
    effect    = "Allow"
    actions   = ["SNS:Publish"]
    resources = [one(aws_sns_topic.this[*].arn)]

    principals {
      type = "Service"
      identifiers = [
        "cloudwatch.amazonaws.com",
        "events.amazonaws.com"
      ]
    }

    dynamic "principals" {
      for_each = local.pub_principals
      content {
        type        = principals.value.type
        identifiers = principals.value.identifiers
      }
    }
  }

  dynamic "statement" {
    for_each = local.pub_principals_with_condition
    content {
      sid       = statement.key
      effect    = "Allow"
      actions   = ["SNS:Publish"]
      resources = [one(aws_sns_topic.this[*].arn)]

      principals {
        type        = statement.value.type
        identifiers = statement.value.identifiers
      }
      condition {
        test     = statement.value.condition.test
        values   = statement.value.condition.values
        variable = statement.value.condition.variable
      }
    }
  }

  dynamic "statement" {
    for_each = local.sub_principals
    content {
      sid       = statement.key
      effect    = "Allow"
      actions   = ["SNS:Subscribe"]
      resources = [one(aws_sns_topic.this[*].arn)]

      principals {
        type        = statement.value.type
        identifiers = statement.value.identifiers
      }
    }
  }

  dynamic "statement" {
    for_each = local.sub_principals_with_condition
    content {
      sid       = statement.key
      effect    = "Allow"
      actions   = ["SNS:Subscribe"]
      resources = [one(aws_sns_topic.this[*].arn)]

      principals {
        type        = statement.value.type
        identifiers = statement.value.identifiers
      }
      condition {
        test     = statement.value.condition.test
        values   = statement.value.condition.values
        variable = statement.value.condition.variable
      }
    }
  }
}
