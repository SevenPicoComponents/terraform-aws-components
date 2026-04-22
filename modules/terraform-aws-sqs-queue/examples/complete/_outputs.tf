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
##  ./examples/complete/outputs.tf
##  This file contains code written only by SevenPico, Inc.
## ----------------------------------------------------------------------------

# Basic Queue Outputs
output "basic_queue" {
  description = "Basic SQS queue details"
  value = {
    queue_arn  = module.basic_queue.sqs_queue.queue_arn
    queue_url  = module.basic_queue.sqs_queue.queue_url
    queue_name = module.basic_queue.sqs_queue.queue_name
    queue_id   = module.basic_queue.sqs_queue.queue_id
  }
}

# Queue with DLQ Outputs
output "queue_with_dlq" {
  description = "SQS queue with Dead Letter Queue details"
  value = {
    queue_arn     = module.queue_with_dlq.sqs_queue.queue_arn
    queue_url     = module.queue_with_dlq.sqs_queue.queue_url
    queue_name    = module.queue_with_dlq.sqs_queue.queue_name
    queue_id      = module.queue_with_dlq.sqs_queue.queue_id
    dlq_arn       = module.queue_with_dlq.sqs_queue.dead_letter_queue_arn
    dlq_url       = module.queue_with_dlq.sqs_queue.dead_letter_queue_url
    dlq_name      = module.queue_with_dlq.sqs_queue.dead_letter_queue_name
    dlq_id        = module.queue_with_dlq.sqs_queue.dead_letter_queue_id
  }
}

# FIFO Queue Outputs
output "fifo_queue" {
  description = "FIFO SQS queue details"
  value = {
    queue_arn  = module.fifo_queue.sqs_queue.queue_arn
    queue_url  = module.fifo_queue.sqs_queue.queue_url
    queue_name = module.fifo_queue.sqs_queue.queue_name
    queue_id   = module.fifo_queue.sqs_queue.queue_id
  }
}

# Encrypted Queue Outputs
output "encrypted_queue" {
  description = "Encrypted SQS queue details"
  value = {
    queue_arn     = module.encrypted_queue.sqs_queue.queue_arn
    queue_url     = module.encrypted_queue.sqs_queue.queue_url
    queue_name    = module.encrypted_queue.sqs_queue.queue_name
    queue_id      = module.encrypted_queue.sqs_queue.queue_id
    kms_key_arn   = aws_kms_key.sqs_key.arn
    kms_key_alias = aws_kms_alias.sqs_key.name
  }
}

# Queue with Policy Outputs
output "queue_with_policy" {
  description = "SQS queue with IAM policy details"
  value = {
    queue_arn  = module.queue_with_policy.sqs_queue.queue_arn
    queue_url  = module.queue_with_policy.sqs_queue.queue_url
    queue_name = module.queue_with_policy.sqs_queue.queue_name
    queue_id   = module.queue_with_policy.sqs_queue.queue_id
  }
}

# Complete Queue Outputs
output "complete_queue" {
  description = "Complete SQS queue with all features"
  value = {
    queue_arn     = module.complete_queue.sqs_queue.queue_arn
    queue_url     = module.complete_queue.sqs_queue.queue_url
    queue_name    = module.complete_queue.sqs_queue.queue_name
    queue_id      = module.complete_queue.sqs_queue.queue_id
    dlq_arn       = module.complete_queue.sqs_queue.dead_letter_queue_arn
    dlq_url       = module.complete_queue.sqs_queue.dead_letter_queue_url
    dlq_name      = module.complete_queue.sqs_queue.dead_letter_queue_name
    dlq_id        = module.complete_queue.sqs_queue.dead_letter_queue_id
  }
}

# Summary of all queues
output "all_queues_summary" {
  description = "Summary of all created SQS queues"
  value = {
    basic_queue = {
      name = module.basic_queue.sqs_queue.queue_name
      arn  = module.basic_queue.sqs_queue.queue_arn
      type = "Standard"
    }
    queue_with_dlq = {
      name     = module.queue_with_dlq.sqs_queue.queue_name
      arn      = module.queue_with_dlq.sqs_queue.queue_arn
      type     = "Standard with DLQ"
      dlq_name = module.queue_with_dlq.sqs_queue.dead_letter_queue_name
    }
    fifo_queue = {
      name = module.fifo_queue.sqs_queue.queue_name
      arn  = module.fifo_queue.sqs_queue.queue_arn
      type = "FIFO"
    }
    encrypted_queue = {
      name = module.encrypted_queue.sqs_queue.queue_name
      arn  = module.encrypted_queue.sqs_queue.queue_arn
      type = "Standard with KMS encryption"
    }
    queue_with_policy = {
      name = module.queue_with_policy.sqs_queue.queue_name
      arn  = module.queue_with_policy.sqs_queue.queue_arn
      type = "Standard with IAM policy"
    }
    complete_queue = {
      name     = module.complete_queue.sqs_queue.queue_name
      arn      = module.complete_queue.sqs_queue.queue_arn
      type     = "Complete with all features"
      dlq_name = module.complete_queue.sqs_queue.dead_letter_queue_name
    }
  }
}
