resource "aws_cognito_user_pool_domain" "domain" {
  count = !local.enabled || var.domain_name == null || module.context.domain_name == "" ? 0 : 1

  domain          = var.domain_name
  certificate_arn = var.acm_certificate_arn
  user_pool_id    = try(aws_cognito_user_pool.pool[0].id, "")
}