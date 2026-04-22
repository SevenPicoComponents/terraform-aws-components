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
##  ./examples/complete/main.tf
##  This file contains code written only by SevenPico, Inc.
## ----------------------------------------------------------------------------

# Example 1: Basic SQS Queue
module "basic_queue" {
  source = "../.."

  context = module.context.self
  name    = "basic-queue"

  # Basic queue configuration
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600 # 4 days
  max_message_size          = 262144  # 256 KiB
  delay_seconds             = 0
  receive_wait_time_seconds = 0

  tags = {
    Example = "basic-queue"
    Purpose = "demonstration"
  }
}

# Example 2: SQS Queue with Dead Letter Queue
module "queue_with_dlq" {
  source = "../.."

  context = module.context.self
  name    = "queue-with-dlq"

  # Enable Dead Letter Queue
  dlq_enabled           = true
  dlq_name_suffix       = "dlq"
  dlq_max_receive_count = 3

  # DLQ specific configuration
  dlq_message_retention_seconds = 1209600 # 14 days
  dlq_visibility_timeout_seconds = 60

  # Main queue configuration
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 20 # Enable long polling

  tags = {
    Example = "queue-with-dlq"
    Purpose = "demonstration"
  }
}

# Example 3: FIFO Queue
module "fifo_queue" {
  source = "../.."

  context = module.context.self
  name    = "fifo-queue"

  # FIFO configuration
  fifo_queue                  = true
  content_based_deduplication = true
  fifo_throughput_limit       = "perQueue"
  deduplication_scope         = "queue"

  # FIFO queue configuration
  visibility_timeout_seconds = 60
  message_retention_seconds  = 345600

  tags = {
    Example = "fifo-queue"
    Purpose = "demonstration"
  }
}

# Example 4: Encrypted SQS Queue with KMS
module "encrypted_queue" {
  source = "../.."

  context = module.context.self
  name    = "encrypted-queue"

  # KMS encryption
  kms_master_key_id                 = aws_kms_key.sqs_key.arn
  kms_data_key_reuse_period_seconds = 300
  sqs_managed_sse_enabled           = false

  # Queue configuration
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600

  tags = {
    Example = "encrypted-queue"
    Purpose = "demonstration"
  }
}

# Example 5: Queue with IAM Policy
module "queue_with_policy" {
  source = "../.."

  context = module.context.self
  name    = "queue-with-policy"

  # Queue configuration
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600

  # IAM policy configuration
  iam_policy_limit_to_current_account = true
  iam_policy = [
    {
      policy_id = "AllowSendMessage"
      statements = [
        {
          sid    = "AllowSendMessage"
          effect = "Allow"
          actions = [
            "sqs:SendMessage",
            "sqs:GetQueueAttributes"
          ]
          principals = [
            {
              type        = "AWS"
              identifiers = [data.aws_caller_identity.current.arn]
            }
          ]
          conditions = [
            {
              test     = "StringEquals"
              variable = "aws:SourceAccount"
              values   = [data.aws_caller_identity.current.account_id]
            }
          ]
        }
      ]
    }
  ]

  tags = {
    Example = "queue-with-policy"
    Purpose = "demonstration"
  }
}

# Example 6: Complete Queue with All Features
module "complete_queue" {
  source = "../.."

  context = module.context.self
  name    = "complete-queue"

  # Enable Dead Letter Queue
  dlq_enabled                       = true
  dlq_name_suffix                   = "dlq"
  dlq_max_receive_count             = 5
  dlq_message_retention_seconds     = 1209600 # 14 days
  dlq_visibility_timeout_seconds    = 60
  dlq_sqs_managed_sse_enabled       = true
  create_dlq_redrive_allow_policy   = true

  # Main queue configuration
  visibility_timeout_seconds = 300 # 5 minutes
  message_retention_seconds  = 604800 # 7 days
  max_message_size          = 262144  # 256 KiB
  delay_seconds             = 0
  receive_wait_time_seconds = 20 # Enable long polling

  # Encryption
  sqs_managed_sse_enabled = true

  # IAM policy
  iam_policy_limit_to_current_account = true
  iam_policy = [
    {
      policy_id = "CompleteQueuePolicy"
      statements = [
        {
          sid    = "AllowBasicOperations"
          effect = "Allow"
          actions = [
            "sqs:SendMessage",
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes",
            "sqs:GetQueueUrl"
          ]
          principals = [
            {
              type        = "AWS"
              identifiers = [data.aws_caller_identity.current.arn]
            }
          ]
        }
      ]
    }
  ]

  tags = {
    Example     = "complete-queue"
    Purpose     = "demonstration"
    Environment = "dev"
    Owner       = "platform-team"
  }
}

# Supporting resources for examples
resource "aws_kms_key" "sqs_key" {
  description             = "KMS key for SQS encryption example"
  deletion_window_in_days = 7

  tags = merge(module.context.tags, {
    Name    = "${module.context.id}-sqs-key"
    Purpose = "sqs-encryption"
  })
}

resource "aws_kms_alias" "sqs_key" {
  name          = "alias/${module.context.id}-sqs-key"
  target_key_id = aws_kms_key.sqs_key.key_id
}

data "aws_caller_identity" "current" {}
