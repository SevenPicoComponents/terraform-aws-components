# terraform-aws-elasticache-redis

Terraform module to provision an [ElastiCache](https://aws.amazon.com/elasticache/) Redis Cluster or Serverless instance.

Adapted from the original CloudPosse module and migrated to the **SevenPico context system** (`SevenPico/context/null`).

---

## Usage

> **Note:** This module uses secure defaults. `transit_encryption_enabled` is `true` by default. With this enabled, you cannot simply `redis-cli` in without setting up an `stunnel`. See [Amazon's documentation](https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/in-transit-encryption.html#connect-tls) for how to connect with it enabled. If this is not desired, set `transit_encryption_enabled = false`.

> **Disruptive changes introduced at version 0.41.0.** If upgrading from an earlier version, see [migration notes](docs/migration-notes-0.41.0.md) for details.

```hcl
module "redis_context" {
  source  = "SevenPico/context/null"
  version = "2.0.0"
  context = module.context.self
  name    = "redis"
}

module "redis" {
  source  = "SevenPico/elasticache-redis/aws"
  version = "x.x.x"
  context = module.redis_context.self

  alarm_actions                        = []
  alarm_cpu_threshold_percent          = 75
  alarm_memory_threshold_bytes         = 10000000
  apply_immediately                    = true
  at_rest_encryption_enabled           = false
  auto_minor_version_upgrade           = null
  auth_token                           = null
  auth_token_update_strategy           = "ROTATE"
  automatic_failover_enabled           = false
  availability_zones                   = var.availability_zones
  cloudwatch_metric_alarms_enabled     = false
  cluster_mode_enabled                 = false
  cluster_mode_num_node_groups         = 0
  cluster_mode_replicas_per_node_group = 0
  cluster_size                         = 1
  create_parameter_group               = true
  data_tiering_enabled                 = false
  description                          = null
  dns_subdomain                        = ""
  elasticache_subnet_group_name        = ""
  engine                               = "redis"
  engine_version                       = "7.1"
  family                               = "redis7"
  final_snapshot_identifier            = null
  global_replication_group_id          = null
  instance_type                        = "cache.t3.micro"
  kms_key_id                           = null
  log_delivery_configuration           = []
  maintenance_window                   = "wed:03:00-wed:04:00"
  multi_az_enabled                     = false
  network_type                         = "ipv4"
  notification_topic_arn               = ""
  ok_actions                           = []
  parameter                            = []
  parameter_group_description          = null
  parameter_group_name                 = null
  port                                 = 6379
  replication_group_id                 = ""
  snapshot_arns                        = []
  snapshot_name                        = null
  snapshot_retention_limit             = 0
  snapshot_window                      = "06:30-07:30"
  subnets                              = var.subnet_ids
  transit_encryption_enabled           = true
  transit_encryption_mode              = null
  user_group_ids                       = null
  vpc_id                               = var.vpc_id
  zone_id                              = []
}
```

For a complete example, see [examples/complete](examples/complete) or [examples/serverless](examples/serverless).

---

## Context System

This module uses the **SevenPico context system** (`SevenPico/context/null v2.0.0`). The context module is always named `context` — never `this`.

Pass context to this module via:
```hcl
context = module.context.self
```

The `_context.tf` file is always downloaded fresh from source:
```bash
curl -sL https://raw.githubusercontent.com/SevenPico/terraform-null-context/master/exports/_context.tf -o _context.tf
```

---

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| aws | >= 5.73.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| `context` | `SevenPico/context/null` | `2.0.0` |
| `aws_security_group` | `SevenPicoForks/security-group/aws` | `3.0.0` |
| `dns` | `SevenPico/route53-alias/aws` | `1.0.1` |

## Resources

| Name | Type |
|------|------|
| `aws_cloudwatch_metric_alarm.cache_cpu` | resource |
| `aws_cloudwatch_metric_alarm.cache_memory` | resource |
| `aws_elasticache_parameter_group.default` | resource |
| `aws_elasticache_replication_group.default` | resource |
| `aws_elasticache_serverless_cache.default` | resource |
| `aws_elasticache_subnet_group.default` | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `vpc_id` | VPC ID | `string` | — | yes |
| `subnets` | Subnet IDs | `list(string)` | `[]` | no |
| `instance_type` | Elastic cache instance type | `string` | `"cache.t2.micro"` | no |
| `engine` | Name of the cache engine | `string` | `"redis"` | no |
| `engine_version` | Version number of the cache engine | `string` | `"7.1"` | no |
| `family` | The family of the ElastiCache parameter group | `string` | `"redis7"` | no |
| `cluster_size` | Number of nodes in cluster | `number` | `1` | no |
| `port` | Port number on which the cache nodes will accept connections | `number` | `6379` | no |
| `at_rest_encryption_enabled` | Enable encryption at rest | `bool` | `false` | no |
| `transit_encryption_enabled` | Enable encryption in transit | `bool` | `true` | no |
| `kms_key_id` | ARN of the KMS key for at-rest encryption | `string` | `null` | no |
| `auth_token` | Auth token for password protecting redis | `string` | `null` | no |
| `serverless_enabled` | Flag to enable/disable creation of a serverless redis cluster | `bool` | `false` | no |
| `cloudwatch_metric_alarms_enabled` | Boolean flag to enable/disable CloudWatch metrics alarms | `bool` | `false` | no |
| `zone_id` | Route53 DNS Zone ID (list of 0 or 1 items) | `any` | `[]` | no |
| `context` | SevenPico context object | `any` | — | no |

See [variables.tf](variables.tf) and [security_group_inputs.tf](security_group_inputs.tf) for the full list of inputs.

## Outputs

| Name | Description |
|------|-------------|
| `id` | Redis cluster ID |
| `arn` | Elasticache Replication Group ARN |
| `endpoint` | Redis primary, configuration or serverless endpoint |
| `reader_endpoint_address` | Reader endpoint address |
| `host` | Redis hostname |
| `port` | Redis port |
| `security_group_id` | The ID of the created security group |
| `security_group_name` | The name of the created security group |
| `member_clusters` | Redis cluster members |
| `engine_version_actual` | The running version of the cache engine |
| `cluster_enabled` | Indicates if cluster mode is enabled |
| `serverless_enabled` | Indicates if serverless mode is enabled |
| `transit_encryption_mode` | The transit encryption mode of the replication group |

---

## Related Projects

- [SevenPicoForks/security-group/aws](https://registry.terraform.io/modules/SevenPicoForks/security-group/aws/latest) — Security group module used by this module
- [SevenPico/context/null](https://registry.terraform.io/modules/SevenPico/context/null/latest) — SevenPico context label system
- [SevenPico/route53-alias/aws](https://registry.terraform.io/modules/SevenPico/route53-alias/aws/latest) — Route53 alias record module

---

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.

```
Copyright © 2023 SevenPico, Inc.
Copyright © 2017-2023 Cloud Posse, LLC
```
