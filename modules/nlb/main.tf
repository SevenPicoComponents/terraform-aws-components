locals {
  listener_port         = var.tcp_enabled ? (var.udp_enabled ? var.udp_port : var.tcp_port) : var.udp_port
  listener_proto        = var.tcp_enabled ? (var.udp_enabled ? "TCP_UDP" : "TCP") : "UDP"
  health_check_port     = coalesce(var.health_check_port, "traffic-port")
  target_group_protocol = var.tls_enabled ? "TCP" : local.listener_proto
  health_check_protocol = coalesce(var.health_check_protocol, local.target_group_protocol)
}

resource "aws_lb" "default" {
  count = module.context.enabled ? 1 : 0
  #bridgecrew:skip=BC_AWS_NETWORKING_41 - Skipping `Ensure that ALB drops HTTP headers` check. Only valid for Load Balancers of type application.
  name               = module.context.id
  tags               = module.context.tags
  internal           = var.internal
  load_balancer_type = "network"

  subnets                          = var.subnet_ids
  enable_cross_zone_load_balancing = var.cross_zone_load_balancing_enabled
  ip_address_type                  = var.ip_address_type
  enable_deletion_protection       = var.deletion_protection_enabled

  dynamic "access_logs" {
    for_each = var.access_logs_s3_bucket_id != null ? [var.access_logs_s3_bucket_id] : []
    content {
      bucket  = var.access_logs_s3_bucket_id
      prefix  = var.access_logs_prefix
      enabled = var.access_logs_enabled
    }
  }
}

module "default_target_group_label" {
  source     = "SevenPico/context/null"
  version    = "2.0.0"
  attributes = ["default"]

  context = module.context.self
  enabled = module.context.enabled && var.create_default_target_group
}

resource "aws_lb_target_group" "default" {
  count                = module.default_target_group_label.enabled ? 1 : 0
  name                 = var.target_group_name == "" ? module.default_target_group_label.id : var.target_group_name
  port                 = var.target_group_port
  protocol             = local.target_group_protocol
  vpc_id               = var.vpc_id
  target_type          = var.target_group_target_type
  deregistration_delay = var.deregistration_delay

  health_check {
    enabled             = var.health_check_enabled
    port                = local.health_check_port
    protocol            = local.health_check_protocol
    path                = local.health_check_protocol == "HTTP" ? var.health_check_path : null
    healthy_threshold   = var.health_check_threshold
    unhealthy_threshold = var.health_check_threshold
    interval            = var.health_check_interval
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    module.default_target_group_label.tags,
    var.target_group_additional_tags
  )

  depends_on = [
    aws_lb.default,
  ]
}

resource "aws_lb_listener" "default" {
  count             = module.default_target_group_label.enabled && var.tcp_enabled ? 1 : (module.default_target_group_label.enabled && var.udp_enabled ? 1 : 0)
  load_balancer_arn = aws_lb.default[0].arn
  port              = local.listener_port
  protocol          = local.listener_proto

  default_action {
    target_group_arn = aws_lb_target_group.default[0].arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "tls" {
  count             = module.default_target_group_label.enabled && var.tls_enabled ? 1 : 0
  load_balancer_arn = aws_lb.default[0].arn

  port            = var.tls_port
  protocol        = "TLS"
  ssl_policy      = var.tls_ssl_policy
  certificate_arn = var.certificate_arn

  default_action {
    target_group_arn = aws_lb_target_group.default[0].arn
    type             = "forward"
  }
}
