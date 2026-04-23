## ----------------------------------------------------------------------------
##  main.tf
##
##  ElastiCache Redis / Valkey replication group, serverless cache, security
##  group, subnet group, parameter group, and CloudWatch alarms.
## ----------------------------------------------------------------------------

locals {
  enabled                    = module.context.enabled
  create_normal_instance     = local.enabled && !var.serverless_enabled
  create_serverless_instance = local.enabled && var.serverless_enabled
  create_parameter_group     = var.global_replication_group_id == null ? var.create_parameter_group : false
  engine                     = var.global_replication_group_id == null ? var.engine : null
  engine_version             = var.global_replication_group_id == null ? var.engine_version : null
  instance_type              = var.global_replication_group_id == null ? var.instance_type : null
  num_node_groups            = (var.global_replication_group_id == null && var.cluster_mode_enabled) ? var.cluster_mode_num_node_groups : null
  transit_encryption_enabled = var.global_replication_group_id == null ? var.transit_encryption_enabled : null
  at_rest_encryption_enabled = var.global_replication_group_id == null ? var.at_rest_encryption_enabled : null
  snapshot_arns              = var.global_replication_group_id == null ? var.snapshot_arns : null

  legacy_egress_rule = local.use_legacy_egress ? {
    key         = "legacy-egress"
    type        = "egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.egress_cidr_blocks
    description = "Allow outbound traffic to existing CIDR blocks"
  } : null

  legacy_cidr_ingress_rule = length(var.allowed_cidr_blocks) == 0 ? null : {
    key         = "legacy-cidr-ingress"
    type        = "ingress"
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Allow inbound traffic from CIDR blocks"
  }

  sg_rules = {
    legacy = merge(local.legacy_egress_rule, local.legacy_cidr_ingress_rule),
    extra  = var.additional_security_group_rules
  }
}


## Security Group
module "aws_security_group" {
  source  = "SevenPicoForks/security-group/aws"
  version = "3.0.0"
  context = module.context.self

  enabled = local.create_security_group

  target_security_group_id = var.target_security_group_id

  allow_all_egress    = local.allow_all_egress
  security_group_name = var.security_group_name
  rules_map           = local.sg_rules
  rule_matrix = [{
    key                       = "in"
    source_security_group_ids = local.allowed_security_group_ids
    cidr_blocks               = var.allowed_cidr_blocks
    rules = [{
      key         = "in"
      type        = "ingress"
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      description = "Selectively allow inbound traffic"
    }]
  }]

  vpc_id = var.vpc_id

  security_group_description = local.security_group_description

  create_before_destroy      = var.security_group_create_before_destroy
  preserve_security_group_id = var.preserve_security_group_id
  inline_rules_enabled       = var.inline_rules_enabled
  revoke_rules_on_delete     = var.revoke_rules_on_delete

  security_group_create_timeout = var.security_group_create_timeout
  security_group_delete_timeout = var.security_group_delete_timeout
}

locals {
  elasticache_subnet_group_name = var.elasticache_subnet_group_name != "" ? var.elasticache_subnet_group_name : join("", aws_elasticache_subnet_group.default[*].name)

  # if !cluster, then node_count = replica cluster_size, if cluster then node_count = shard*(replica + 1)
  # Why doing this 'The "count" value depends on resource attributes that cannot be determined until apply'. So pre-calculating
  member_clusters_count = (var.cluster_mode_enabled
    ?
    (var.cluster_mode_num_node_groups * (var.cluster_mode_replicas_per_node_group + 1))
    :
    var.cluster_size
  )

  elasticache_member_clusters = local.create_normal_instance ? tolist(aws_elasticache_replication_group.default[0].member_clusters) : []

  # The name of the parameter group can't include "."
  safe_family = replace(var.family, ".", "-")

  parameter_group_name = var.global_replication_group_id != null ? null : coalesce(
    var.parameter_group_name,
    var.create_parameter_group ?
    "${module.context.id}-${local.safe_family}" # The name of the new parameter group to be created
    : "default.${var.family}"                   # Default parameter group name created by AWS
  )

  arn = (
    local.create_normal_instance ? join("", aws_elasticache_replication_group.default[*].arn) :
    join("", aws_elasticache_serverless_cache.default[*].arn)
  )

  endpoint_serverless = try(aws_elasticache_serverless_cache.default[0].endpoint[0].address, null)
  endpoint_cluster    = try(aws_elasticache_replication_group.default[0].configuration_endpoint_address, null)
  endpoint_instance   = try(aws_elasticache_replication_group.default[0].primary_endpoint_address, null)
  endpoint_address    = local.enabled ? coalesce(local.endpoint_serverless, local.endpoint_cluster, local.endpoint_instance) : null

  reader_endpoint_serverless = try(aws_elasticache_serverless_cache.default[0].reader_endpoint[0].address, null)
  reader_endpoint_cluster    = try(aws_elasticache_replication_group.default[0].reader_endpoint_address, null)
  reader_endpoint_instance   = try(aws_elasticache_replication_group.default[0].reader_endpoint_address, null)
  reader_endpoint_address    = local.enabled ? coalesce(local.reader_endpoint_serverless, local.reader_endpoint_cluster, local.reader_endpoint_instance, local.endpoint_address) : null
}


## ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "default" {
  count       = local.enabled && var.elasticache_subnet_group_name == "" && length(var.subnets) > 0 ? 1 : 0
  name        = module.context.id
  description = "Elasticache subnet group for ${module.context.id}"
  subnet_ids  = var.subnets
  tags        = module.context.tags
}


## ElastiCache Parameter Group
resource "aws_elasticache_parameter_group" "default" {
  count       = local.enabled && local.create_parameter_group ? 1 : 0
  name        = local.parameter_group_name
  description = var.parameter_group_description != null ? var.parameter_group_description : "Elasticache parameter group ${local.parameter_group_name}"
  family      = var.family

  dynamic "parameter" {
    for_each = var.cluster_mode_enabled ? concat([{ name = "cluster-enabled", value = "yes" }], var.parameter) : var.parameter
    content {
      name  = parameter.value.name
      value = tostring(parameter.value.value)
    }
  }

  tags = module.context.tags

  lifecycle {
    create_before_destroy = true

    ignore_changes = [
      description,
    ]
  }
}


## ElastiCache Replication Group (normal instance — single node or cluster)
resource "aws_elasticache_replication_group" "default" {
  count = local.create_normal_instance ? 1 : 0

  auth_token                  = var.transit_encryption_enabled ? var.auth_token : null
  auth_token_update_strategy  = var.auth_token != null ? var.auth_token_update_strategy : null
  replication_group_id        = var.replication_group_id == "" ? module.context.id : var.replication_group_id
  description                 = coalesce(var.description, module.context.id)
  node_type                   = local.instance_type
  num_cache_clusters          = var.cluster_mode_enabled ? null : var.cluster_size
  port                        = var.port
  parameter_group_name        = local.parameter_group_name
  preferred_cache_cluster_azs = length(var.availability_zones) == 0 ? null : [for n in range(0, var.cluster_size) : element(var.availability_zones, n)]
  automatic_failover_enabled  = var.cluster_mode_enabled ? true : var.automatic_failover_enabled
  multi_az_enabled            = var.multi_az_enabled
  subnet_group_name           = local.elasticache_subnet_group_name
  network_type                = var.network_type
  security_group_ids          = local.create_security_group ? concat(local.associated_security_group_ids, [module.aws_security_group.id]) : local.associated_security_group_ids
  maintenance_window          = var.maintenance_window
  notification_topic_arn      = var.notification_topic_arn
  engine                      = local.engine
  engine_version              = local.engine_version
  at_rest_encryption_enabled  = local.at_rest_encryption_enabled
  transit_encryption_enabled  = local.transit_encryption_enabled
  transit_encryption_mode     = var.transit_encryption_mode
  kms_key_id                  = var.at_rest_encryption_enabled ? var.kms_key_id : null
  snapshot_name               = var.snapshot_name
  snapshot_arns               = local.snapshot_arns
  snapshot_window             = var.snapshot_window
  snapshot_retention_limit    = var.snapshot_retention_limit
  final_snapshot_identifier   = var.final_snapshot_identifier
  apply_immediately           = var.apply_immediately
  data_tiering_enabled        = var.data_tiering_enabled
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  global_replication_group_id = var.global_replication_group_id

  dynamic "log_delivery_configuration" {
    for_each = var.log_delivery_configuration

    content {
      destination      = lookup(log_delivery_configuration.value, "destination", null)
      destination_type = lookup(log_delivery_configuration.value, "destination_type", null)
      log_format       = lookup(log_delivery_configuration.value, "log_format", null)
      log_type         = lookup(log_delivery_configuration.value, "log_type", null)
    }
  }

  tags = module.context.tags

  num_node_groups         = local.num_node_groups
  replicas_per_node_group = var.cluster_mode_enabled ? var.cluster_mode_replicas_per_node_group : null
  user_group_ids          = var.user_group_ids

  lifecycle {
    ignore_changes = [
      security_group_names,
    ]
  }

  depends_on = [
    aws_elasticache_parameter_group.default
  ]
}


## ElastiCache Serverless Cache (Redis/Valkey)
resource "aws_elasticache_serverless_cache" "default" {
  count = local.create_serverless_instance ? 1 : 0

  name   = var.replication_group_id == "" ? module.context.id : var.replication_group_id
  engine = var.engine

  kms_key_id         = var.at_rest_encryption_enabled ? var.kms_key_id : null
  subnet_ids         = var.subnets
  security_group_ids = local.create_security_group ? concat(local.associated_security_group_ids, [module.aws_security_group.id]) : local.associated_security_group_ids

  daily_snapshot_time      = var.serverless_snapshot_time
  snapshot_arns_to_restore = var.serverless_snapshot_arns_to_restore
  description              = coalesce(var.description, module.context.id)
  major_engine_version     = var.serverless_major_engine_version
  snapshot_retention_limit = var.snapshot_retention_limit
  user_group_id            = var.serverless_user_group_id

  dynamic "cache_usage_limits" {
    # Only emit the block when the map is non-empty AND contains at least one of the
    # recognised sub-keys (data_storage / ecpu_per_second).  An empty map ({}) means
    # "no limits" and must produce zero blocks — otherwise the AWS provider returns
    # "block count changed from 1 to 0" on the next plan/apply cycle.
    for_each = (
      var.serverless_cache_usage_limits != null &&
      length(var.serverless_cache_usage_limits) > 0 &&
      (
        lookup(var.serverless_cache_usage_limits, "data_storage", null) != null ||
        lookup(var.serverless_cache_usage_limits, "ecpu_per_second", null) != null
      )
    ) ? [var.serverless_cache_usage_limits] : []

    content {
      dynamic "data_storage" {
        for_each = lookup(cache_usage_limits.value, "data_storage", null) != null ? [cache_usage_limits.value.data_storage] : []
        content {
          maximum = try(data_storage.value.maximum, null)
          minimum = try(data_storage.value.minimum, null)
          unit    = try(data_storage.value.unit, "GB")
        }
      }

      dynamic "ecpu_per_second" {
        for_each = lookup(cache_usage_limits.value, "ecpu_per_second", null) != null ? [cache_usage_limits.value.ecpu_per_second] : []
        content {
          maximum = try(ecpu_per_second.value.maximum, null)
          minimum = try(ecpu_per_second.value.minimum, null)
        }
      }
    }
  }

  tags = module.context.tags

  depends_on = [
    aws_elasticache_parameter_group.default
  ]
}


## CloudWatch CPU Alarm
resource "aws_cloudwatch_metric_alarm" "cache_cpu" {
  count               = local.create_normal_instance && var.cloudwatch_metric_alarms_enabled ? local.member_clusters_count : 0
  alarm_name          = "${element(local.elasticache_member_clusters, count.index)}-cpu-utilization"
  alarm_description   = "Redis cluster CPU utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"

  threshold = var.alarm_cpu_threshold_percent

  dimensions = {
    CacheClusterId = element(local.elasticache_member_clusters, count.index)
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  depends_on    = [aws_elasticache_replication_group.default]

  tags = module.context.tags
}


## CloudWatch Memory Alarm
resource "aws_cloudwatch_metric_alarm" "cache_memory" {
  count               = local.create_normal_instance && var.cloudwatch_metric_alarms_enabled ? local.member_clusters_count : 0
  alarm_name          = "${element(local.elasticache_member_clusters, count.index)}-freeable-memory"
  alarm_description   = "Redis cluster freeable memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  period              = "60"
  statistic           = "Average"

  threshold = var.alarm_memory_threshold_bytes

  dimensions = {
    CacheClusterId = element(local.elasticache_member_clusters, count.index)
  }

  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  depends_on    = [aws_elasticache_replication_group.default]

  tags = module.context.tags
}


## DNS Hostname
module "dns" {
  source  = "cloudposse/route53-cluster-hostname/aws"
  version = "0.13.0"
  context = module.context.self

  enabled  = local.enabled && length(var.zone_id) > 0 ? true : false
  dns_name = var.dns_subdomain != "" ? var.dns_subdomain : module.context.id
  ttl      = 60
  zone_id  = try(var.zone_id[0], tostring(var.zone_id), "")
  records  = [local.endpoint_address]
}
