## ----------------------------------------------------------------------------
##  outputs.tf
##
##  Output values for the ElastiCache Redis / Valkey module.
## ----------------------------------------------------------------------------

output "id" {
  value       = try(aws_elasticache_replication_group.default[0].id, null)
  description = "Redis cluster ID"
}

output "security_group_id" {
  value       = try(module.aws_security_group.id, null)
  description = "The ID of the created security group"
}

output "security_group_name" {
  value       = try(module.aws_security_group.name, null)
  description = "The name of the created security group"
}

output "port" {
  value       = var.port
  description = "Redis port"
}

output "endpoint" {
  value       = local.endpoint_address
  description = "Redis primary, configuration or serverless endpoint, whichever is appropriate for the given configuration"
}

output "reader_endpoint_address" {
  value       = local.reader_endpoint_address
  description = "The address of the endpoint for the reader node in the replication group, if the cluster mode is disabled or serverless is being used."
}

output "member_clusters" {
  value       = try(aws_elasticache_replication_group.default[0].member_clusters, null)
  description = "Redis cluster members"
}

output "host" {
  value       = try(module.dns.hostname, null)
  description = "Redis hostname"
}

output "arn" {
  value       = local.arn
  description = "Elasticache Replication Group ARN"
}

output "engine_version_actual" {
  value       = try(aws_elasticache_replication_group.default[0].engine_version_actual, null)
  description = "The running version of the cache engine"
}

output "cluster_enabled" {
  value       = try(aws_elasticache_replication_group.default[0].cluster_enabled, null)
  description = "Indicates if cluster mode is enabled"
}

output "serverless_enabled" {
  value       = var.serverless_enabled
  description = "Indicates if serverless mode is enabled"
}

output "transit_encryption_mode" {
  value       = try(aws_elasticache_replication_group.default[0].transit_encryption_mode, null)
  description = "The transit encryption mode of the replication group"
}
