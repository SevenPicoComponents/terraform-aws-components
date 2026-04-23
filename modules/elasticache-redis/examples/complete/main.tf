## ----------------------------------------------------------------------------
##  examples/complete/main.tf
##
##  Complete example: VPC, subnets, CloudWatch log group, and a standard
##  (non-serverless) ElastiCache Redis replication group.
## ----------------------------------------------------------------------------

provider "aws" {
  region = var.region
}


## VPC
module "vpc" {
  source  = "SevenPico/vpc/aws"
  version = "3.0.2"
  context = module.context.self

  ipv4_primary_cidr_block = "172.16.0.0/16"
}


## Subnets
module "subnets" {
  source  = "SevenPico/dynamic-subnets/aws"
  version = "3.1.3"
  context = module.context.self

  availability_zones   = var.availability_zones
  igw_id               = [module.vpc.igw_id]
  ipv4_cidr_block      = [module.vpc.vpc_cidr_block]
  nat_gateway_enabled  = false
  nat_instance_enabled = false
  vpc_id               = module.vpc.vpc_id
}

resource "aws_route53_zone" "private" {
  name = format("elasticache-redis-terratest-%s.testing.sevenpico.io", try(module.context.attributes[0], "default"))

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

resource "aws_cloudwatch_log_group" "redis" {
  count = module.context.enabled ? 1 : 0

  name              = "/aws/elasticache/${module.context.id}"
  retention_in_days = 7
  tags              = module.context.tags
}


## Redis
module "redis" {
  source  = "../../"
  context = module.context.self

  alarm_actions                        = []
  alarm_cpu_threshold_percent          = 75
  alarm_memory_threshold_bytes         = 10000000
  apply_immediately                    = true
  at_rest_encryption_enabled           = var.at_rest_encryption_enabled
  auto_minor_version_upgrade           = null
  auth_token                           = null
  auth_token_update_strategy           = "ROTATE"
  automatic_failover_enabled           = false
  availability_zones                   = var.availability_zones
  cloudwatch_metric_alarms_enabled     = var.cloudwatch_metric_alarms_enabled
  cluster_mode_enabled                 = false
  cluster_mode_num_node_groups         = 0
  cluster_mode_replicas_per_node_group = 0
  cluster_size                         = var.cluster_size
  create_parameter_group               = true
  data_tiering_enabled                 = false
  description                          = null
  dns_subdomain                        = ""
  elasticache_subnet_group_name        = ""
  engine                               = "redis"
  engine_version                       = var.engine_version
  family                               = var.family
  final_snapshot_identifier            = null
  global_replication_group_id          = null
  instance_type                        = var.instance_type
  kms_key_id                           = null
  log_delivery_configuration = [
    {
      destination      = try(aws_cloudwatch_log_group.redis[0].name, "")
      destination_type = "cloudwatch-logs"
      log_format       = "json"
      log_type         = "engine-log"
    }
  ]
  maintenance_window                   = "wed:03:00-wed:04:00"
  multi_az_enabled                     = false
  network_type                         = "ipv4"
  notification_topic_arn               = ""
  ok_actions                           = []
  parameter                            = [{ name = "notify-keyspace-events", value = "lK" }]
  parameter_group_description          = null
  parameter_group_name                 = null
  port                                 = 6379
  replication_group_id                 = ""
  security_group_create_before_destroy = true
  security_group_name                  = length(var.sg_name) > 0 ? [var.sg_name] : []
  security_group_delete_timeout        = "5m"
  serverless_cache_usage_limits        = {}
  serverless_enabled                   = false
  serverless_major_engine_version      = "7"
  serverless_snapshot_arns_to_restore  = []
  serverless_snapshot_time             = "06:00"
  serverless_user_group_id             = null
  snapshot_arns                        = []
  snapshot_name                        = null
  snapshot_retention_limit             = 0
  snapshot_window                      = "06:30-07:30"
  subnets                              = module.subnets.private_subnet_ids
  transit_encryption_enabled           = var.transit_encryption_enabled
  transit_encryption_mode              = null
  user_group_ids                       = null
  vpc_id                               = module.vpc.vpc_id
  zone_id                              = [aws_route53_zone.private.id]
}
