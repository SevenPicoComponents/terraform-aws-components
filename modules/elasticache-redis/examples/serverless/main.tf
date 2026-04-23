## ----------------------------------------------------------------------------
##  examples/serverless/main.tf
##
##  Serverless example: VPC, subnets, and a serverless ElastiCache Redis /
##  Valkey cache.
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


## Serverless Redis
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
  instance_type                        = "cache.t2.micro"
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
  security_group_create_before_destroy = true
  security_group_name                  = length(var.sg_name) > 0 ? [var.sg_name] : []
  security_group_delete_timeout        = "5m"
  serverless_cache_usage_limits        = var.serverless_cache_usage_limits
  serverless_enabled                   = var.serverless_enabled
  serverless_major_engine_version      = var.serverless_major_engine_version
  serverless_snapshot_arns_to_restore  = var.serverless_snapshot_arns_to_restore
  serverless_snapshot_time             = "06:00"
  serverless_user_group_id             = null
  snapshot_arns                        = []
  snapshot_name                        = null
  snapshot_retention_limit             = 0
  snapshot_window                      = "06:30-07:30"
  subnets                              = module.subnets.private_subnet_ids
  transit_encryption_enabled           = true
  transit_encryption_mode              = null
  user_group_ids                       = null
  vpc_id                               = module.vpc.vpc_id
  zone_id                              = [aws_route53_zone.private.id]
}
