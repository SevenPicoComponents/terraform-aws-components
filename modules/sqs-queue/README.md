# terraform-aws-sqs-queue

A Terraform module for creating and managing AWS SQS queues with comprehensive configuration options including Dead Letter Queues, FIFO queues, encryption, and IAM policies.

## Features

- **Standard and FIFO Queues**: Support for both standard and FIFO queue types
- **Dead Letter Queue (DLQ)**: Automatic DLQ creation with configurable settings
- **Encryption**: Support for both SQS-managed and KMS customer-managed encryption
- **IAM Policies**: Flexible IAM policy configuration with account-limited access
- **Long Polling**: Configurable long polling to reduce costs
- **Message Configuration**: Customizable message retention, visibility timeout, and size limits
- **Comprehensive Tagging**: Integration with SevenPico context module for consistent tagging

## Usage

### Basic Example

```hcl
module "basic_sqs_queue" {
  source = "SevenPico/sqs-queue/aws"

  context = module.context.self
  name    = "my-queue"

  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600 # 4 days
}
```

### FIFO Queue Example

```hcl
module "fifo_queue" {
  source = "SevenPico/sqs-queue/aws"

  context = module.context.self
  name    = "my-fifo-queue"

  fifo_queue                  = true
  content_based_deduplication = true
  fifo_throughput_limit       = "perQueue"
}
```

### Queue with Dead Letter Queue

```hcl
module "queue_with_dlq" {
  source = "SevenPico/sqs-queue/aws"

  context = module.context.self
  name    = "my-queue-with-dlq"

  dlq_enabled           = true
  dlq_max_receive_count = 3
  dlq_message_retention_seconds = 1209600 # 14 days
}
```

### Encrypted Queue with KMS

```hcl
module "encrypted_queue" {
  source = "SevenPico/sqs-queue/aws"

  context = module.context.self
  name    = "my-encrypted-queue"

  kms_master_key_id                 = aws_kms_key.my_key.arn
  kms_data_key_reuse_period_seconds = 300
  sqs_managed_sse_enabled           = false
}
```

### Queue with IAM Policy

```hcl
module "queue_with_policy" {
  source = "SevenPico/sqs-queue/aws"

  context = module.context.self
  name    = "my-queue-with-policy"

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
              identifiers = ["arn:aws:iam::123456789012:user/MyUser"]
            }
          ]
        }
      ]
    }
  ]
}
```

## Examples

The `examples/complete` directory contains comprehensive examples demonstrating various configurations:

1. **Basic SQS Queue** - Simple standard queue with minimal configuration
2. **SQS Queue with Dead Letter Queue** - Queue with DLQ for handling failed messages
3. **FIFO Queue** - First-In-First-Out queue with content-based deduplication
4. **Encrypted SQS Queue with KMS** - Queue with customer-managed KMS encryption
5. **Queue with IAM Policy** - Queue with custom access control policies
6. **Complete Queue with All Features** - Production-ready configuration with all features

To run the complete example:

```bash
cd examples/complete
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1.5 |
| aws | >= 4.12.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.12.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| context | SevenPico/context/null | 2.0.0 |
| sqs | terraform-aws-modules/sqs/aws | 4.2.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.queue_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_sqs_queue_policy.sqs_queue_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| context | Single object for setting entire context at once | `any` | `{}` | no |
| name | ID element. Usually the component or solution name | `string` | `null` | no |
| visibility_timeout_seconds | The visibility timeout for the queue | `number` | `30` | no |
| message_retention_seconds | The number of seconds Amazon SQS retains a message | `number` | `345600` | no |
| max_message_size | The limit of how many bytes a message can contain | `number` | `262144` | no |
| delay_seconds | The time in seconds that the delivery of all messages will be delayed | `number` | `0` | no |
| receive_wait_time_seconds | The time for which a ReceiveMessage call will wait for a message | `number` | `0` | no |
| dlq_enabled | Boolean designating whether the Dead Letter Queue should be created | `bool` | `false` | no |
| dlq_name_suffix | The suffix of the Dead Letter Queue | `string` | `"dlq"` | no |
| dlq_max_receive_count | The number of times a message can be unsuccessfully dequeued | `number` | `5` | no |
| fifo_queue | Boolean designating a FIFO queue | `bool` | `false` | no |
| content_based_deduplication | Enables content-based deduplication for FIFO queues | `bool` | `false` | no |
| fifo_throughput_limit | Specifies whether the FIFO queue throughput quota applies to the entire queue or per message group | `string` | `null` | no |
| deduplication_scope | Specifies whether message deduplication occurs at the message group or queue level | `string` | `null` | no |
| kms_master_key_id | The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK | `string` | `null` | no |
| kms_data_key_reuse_period_seconds | The length of time, in seconds, for which Amazon SQS can reuse a data key | `number` | `300` | no |
| sqs_managed_sse_enabled | Boolean to enable server-side encryption (SSE) of message content with SQS-owned encryption keys | `bool` | `true` | no |
| iam_policy | IAM policy as list of Terraform objects | `list(object)` | `[]` | no |
| iam_policy_limit_to_current_account | Boolean designating whether the IAM policy should be limited to the current account | `bool` | `true` | no |

For a complete list of all available variables, see [_variables.tf](_variables.tf).

## Outputs

| Name | Description |
|------|-------------|
| sqs_queue | The SQS queue object containing all queue attributes |

The `sqs_queue` output includes:
- `queue_arn` - The ARN of the SQS queue
- `queue_url` - The URL of the SQS queue
- `queue_name` - The name of the SQS queue
- `queue_id` - The ID of the SQS queue
- `dead_letter_queue_arn` - The ARN of the dead letter queue (if enabled)
- `dead_letter_queue_url` - The URL of the dead letter queue (if enabled)
- And many more attributes from the underlying terraform-aws-modules/sqs/aws module

## Queue Types

### Standard Queues
- **High Throughput**: Nearly unlimited number of API calls per second
- **At-Least-Once Delivery**: Messages are delivered at least once, but occasionally more than one copy
- **Best-Effort Ordering**: Messages are generally delivered in the order they are sent

### FIFO Queues
- **Exactly-Once Processing**: Messages are delivered exactly once and remain available until processed
- **First-In-First-Out Delivery**: The order in which messages are sent and received is strictly preserved
- **Limited Throughput**: Up to 300 API calls per second (or 3,000 with batching)

## Dead Letter Queues

Dead Letter Queues (DLQ) help handle message processing failures by automatically moving messages that can't be processed successfully to a separate queue for analysis and reprocessing.

### Benefits:
- **Fault Isolation**: Prevents problematic messages from blocking queue processing
- **Debugging**: Allows examination of failed messages
- **Monitoring**: Enables alerting on processing failures

### Configuration:
- `dlq_enabled`: Enable/disable DLQ creation
- `dlq_max_receive_count`: Number of processing attempts before moving to DLQ
- `dlq_message_retention_seconds`: How long messages are retained in the DLQ

## Encryption

### SQS-Managed Encryption (Default)
- Enabled by default with `sqs_managed_sse_enabled = true`
- Uses SQS-owned encryption keys
- No additional charges
- Automatic key rotation

### Customer-Managed KMS Encryption
- Set `sqs_managed_sse_enabled = false` and provide `kms_master_key_id`
- Uses your own KMS keys for encryption
- Additional KMS charges apply
- Full control over key policies and rotation

## IAM Policies

The module supports flexible IAM policy configuration:

```hcl
iam_policy = [
  {
    policy_id = "MyQueuePolicy"
    statements = [
      {
        sid    = "AllowSendReceive"
        effect = "Allow"
        actions = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        principals = [
          {
            type        = "AWS"
            identifiers = ["arn:aws:iam::123456789012:role/MyRole"]
          }
        ]
        conditions = [
          {
            test     = "StringEquals"
            variable = "aws:SourceAccount"
            values   = ["123456789012"]
          }
        ]
      }
    ]
  }
]
```

## Cost Optimization

### Long Polling
- Set `receive_wait_time_seconds` to 1-20 seconds
- Reduces the number of empty ReceiveMessage responses
- Can significantly reduce costs for low-traffic queues

### Message Batching
- Use batch operations when possible (SendMessageBatch, ReceiveMessage with MaxNumberOfMessages)
- Reduces the number of API calls
- More cost-effective for high-volume applications

### Right-sizing Retention
- Set appropriate `message_retention_seconds` based on your use case
- Default is 4 days, maximum is 14 days
- Shorter retention periods can reduce storage costs

## Security Best Practices

1. **Use IAM Policies**: Always configure appropriate IAM policies to control access
2. **Enable Encryption**: Use encryption for sensitive data
3. **Limit Account Access**: Use `iam_policy_limit_to_current_account = true`
4. **Principle of Least Privilege**: Grant only necessary permissions
5. **Monitor Access**: Use CloudTrail to monitor queue access
6. **VPC Endpoints**: Consider using VPC endpoints for private access

## Monitoring and Alerting

Key CloudWatch metrics to monitor:
- `ApproximateNumberOfMessages`: Messages available for retrieval
- `ApproximateNumberOfMessagesNotVisible`: Messages in flight
- `NumberOfMessagesSent`: Messages added to queue
- `NumberOfMessagesReceived`: Messages retrieved from queue
- `NumberOfMessagesDeleted`: Messages deleted from queue

For Dead Letter Queues:
- `ApproximateNumberOfMessages`: Failed messages in DLQ
- Set up CloudWatch alarms for DLQ message count

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full license text.

## Support

For questions, issues, or contributions, please use the GitHub repository's issue tracker.
