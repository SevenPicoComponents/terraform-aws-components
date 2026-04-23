/*
Create SES domain identity and verify it with Route53 DNS records
*/

resource "aws_ses_domain_identity" "ses_domain" {
  count = module.context.enabled ? 1 : 0

  domain = module.context.domain_name
}

resource "aws_route53_record" "amazonses_verification_record" {
  count = module.context.enabled && var.verify_domain ? 1 : 0

  zone_id = var.zone_id
  name    = "_amazonses.${module.context.domain_name}"
  type    = "TXT"
  ttl     = "600"
  records = [join("", aws_ses_domain_identity.ses_domain[*].verification_token)]
}

resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  count = module.context.enabled ? 1 : 0

  domain = join("", aws_ses_domain_identity.ses_domain[*].domain)
}

resource "aws_route53_record" "amazonses_dkim_record" {
  count = module.context.enabled && var.verify_dkim ? 3 : 0

  zone_id = var.zone_id
  name    = "${element(aws_ses_domain_dkim.ses_domain_dkim[0].dkim_tokens, count.index)}._domainkey.${module.context.domain_name}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.ses_domain_dkim[0].dkim_tokens, count.index)}.dkim.amazonses.com"]
}


#-----------------------------------------------------------------------------------------------------------------------
# OPTIONALLY CREATE A USER AND GROUP WITH PERMISSIONS TO SEND EMAILS FROM SES domain
#-----------------------------------------------------------------------------------------------------------------------
locals {
  create_group_enabled = module.context.enabled && var.ses_group_enabled
  create_user_enabled  = module.context.enabled && var.ses_user_enabled

  ses_group_name = local.create_group_enabled ? coalesce(var.ses_group_name, module.context.id) : null
}

data "aws_iam_policy_document" "ses_policy" {
  count = local.create_user_enabled || local.create_group_enabled ? 1 : 0

  statement {
    actions   = var.iam_permissions
    resources = concat(aws_ses_domain_identity.ses_domain[*].arn, var.iam_allowed_resources)
  }
}

resource "aws_iam_group" "ses_users" {
  count = local.create_group_enabled ? 1 : 0

  name = local.ses_group_name
  path = var.ses_group_path
}

resource "aws_iam_group_policy" "ses_group_policy" {
  count = local.create_group_enabled ? 1 : 0

  name  = module.context.id
  group = aws_iam_group.ses_users[0].name

  policy = join("", data.aws_iam_policy_document.ses_policy[*].json)
}

resource "aws_iam_user_group_membership" "ses_user" {
  count = local.create_group_enabled && local.create_user_enabled ? 1 : 0

  user = module.ses_user.user_name

  groups = [
    aws_iam_group.ses_users[0].name
  ]
}

module "ses_user" {
  source     = "registry.terraform.io/SevenPicoForks/iam-system-user/aws"
  version    = "2.0.2"
  context    = module.context.self
  enabled    = module.context.enabled && local.create_user_enabled
  attributes = ["ses", "user"]

  iam_access_key_max_age        = var.iam_access_key_max_age
  create_iam_access_key         = var.create_iam_access_key
  force_destroy                 = var.force_destroy
  inline_policies               = var.inline_policies
  inline_policies_map           = var.inline_policies_map
  permissions_boundary          = var.permissions_boundary
  path                          = var.path
  policy_arns                   = var.policy_arns
  policy_arns_map               = var.policy_arns_map
  ssm_enabled                   = var.ssm_enabled
  ssm_ignore_value_changes      = var.ssm_ignore_value_changes
  ssm_ses_smtp_password_enabled = var.ssm_ses_smtp_password_enabled
}


resource "aws_iam_user_policy" "sending_emails" {
  #bridgecrew:skip=BC_AWS_IAM_16:Skipping `Ensure IAM policies are attached only to groups or roles` check because this module intentionally attaches IAM policy directly to a user.
  count = local.create_user_enabled && !local.create_group_enabled ? 1 : 0

  name   = module.context.id
  policy = join("", data.aws_iam_policy_document.ses_policy[*].json)
  user   = module.ses_user.user_name
}