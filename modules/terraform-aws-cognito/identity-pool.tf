resource "aws_cognito_identity_pool" "main" {
  count                            = var.enable_identity_pool == true ? 1 : 0
  identity_pool_name               = var.identity_pool_name
  allow_unauthenticated_identities = var.allow_unauthenticated_identities
  allow_classic_flow               = var.allow_classic_flow
  developer_provider_name          = var.developer_provider_name
  supported_login_providers        = var.supported_login_providers
  saml_provider_arns               = var.saml_provider_arns
  openid_connect_provider_arns     = var.openid_connect_provider_arns
  tags                             = var.identity_pool_tags

  dynamic "cognito_identity_providers" {
    for_each = var.enable_cognito_identity_providers == true ? [1] : []
    content {
      client_id               = var.cognito_identity_providers_client_id
      provider_name           = var.cognito_identity_providers_provider_name
      server_side_token_check = var.cognito_identity_providers_server_side_token_check
    }
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  count            = var.enable_identity_pool_roles_attachment == true ? 1 : 0
  identity_pool_id = aws_cognito_identity_pool.main[0].id
  roles            = var.cognito_identity_pool_roles

  dynamic "role_mapping" {
    for_each = var.role_mapping_enabled ? [1] : []

    content {
      identity_provider         = var.role_mapping_identity_provider
      ambiguous_role_resolution = var.role_mapping_ambiguous_role_resolution
      type                      = var.role_mapping_type

      dynamic "mapping_rule" {
        for_each = var.role_mapping_enabled ? [1] : []

        content {
          claim      = var.role_mapping_mapping_rule_claim
          match_type = var.role_mapping_mapping_rule_match_type
          role_arn   = var.cognito_identity_pool_iam_role_arn
          value      = var.role_mapping_mapping_rule_match_value
        }
      }
    }
  }
}

