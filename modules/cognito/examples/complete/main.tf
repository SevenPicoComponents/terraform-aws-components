module "cognito" {
  source = "../../"
  # This Example is deploying 3 resources:  cognito_user_pool  | cognito_user_group | cognito_identity_pool
  context          = module.context.self
  enabled          = module.context.enabled
  attributes       = ["components", "cognito"]
  domain_name      = ""
  enable_user_pool = true

  acm_certificate_arn                                   = null
  admin_create_user_config                              = {}
  admin_create_user_config_allow_admin_create_user_only = true
  admin_create_user_config_email_message                = "{username}, your temporary password is `{####}`"
  admin_create_user_config_email_subject                = "Your verification code"
  admin_create_user_config_sms_message                  = "Your username is {username} and temporary password is `{####}`"
  auto_verified_attributes                              = []
  client_access_token_validity                          = 60
  client_allowed_oauth_flows                            = []
  client_allowed_oauth_flows_user_pool_client           = true
  client_allowed_oauth_scopes                           = []
  client_callback_urls                                  = []
  client_default_redirect_uri                           = ""
  client_explicit_auth_flows                            = []
  client_generate_secret                                = true
  client_id_token_validity                              = 60
  client_logout_urls                                    = []
  client_name                                           = null
  client_prevent_user_existence_errors                  = null
  client_read_attributes                                = []
  client_refresh_token_validity                         = 30
  client_supported_identity_providers                   = []
  client_token_validity_units = {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
  client_write_attributes                                    = []
  clients                                                    = []
  device_configuration                                       = {}
  device_configuration_challenge_required_on_new_device      = false
  device_configuration_device_only_remembered_on_user_prompt = false
  email_configuration                                        = {}
  email_configuration_email_sending_account                  = "COGNITO_DEFAULT"
  email_configuration_from_email_address                     = null
  email_configuration_reply_to_email_address                 = ""
  email_configuration_source_arn                             = ""
  email_verification_message                                 = null
  email_verification_subject                                 = null
  identity_providers                                         = []
  lambda_config                                              = null
  lambda_config_create_auth_challenge                        = ""
  lambda_config_custom_email_sender                          = {}
  lambda_config_custom_message                               = ""
  lambda_config_custom_sms_sender                            = {}
  lambda_config_define_auth_challenge                        = ""
  lambda_config_kms_key_id                                   = null
  lambda_config_post_authentication                          = ""
  lambda_config_post_confirmation                            = ""
  lambda_config_pre_authentication                           = ""
  lambda_config_pre_sign_up                                  = ""
  lambda_config_pre_token_generation                         = ""
  lambda_config_user_migration                               = ""
  lambda_config_verify_auth_challenge_response               = ""
  mfa_configuration                                          = "OFF"
  number_schemas                                             = []
  password_policy                                            = null
  password_policy_minimum_length                             = 8
  password_policy_require_lowercase                          = true
  password_policy_require_numbers                            = true
  password_policy_require_symbols                            = true
  password_policy_require_uppercase                          = true
  password_policy_temporary_password_validity_days           = 7
  recovery_mechanisms                                        = []
  resource_server_identifier                                 = null
  resource_server_name                                       = null
  resource_server_scope_description                          = null
  resource_server_scope_name                                 = null
  resource_servers                                           = []
  schemas                                                    = []
  sms_authentication_message                                 = null
  sms_configuration                                          = {}
  sms_configuration_external_id                              = ""
  sms_configuration_sns_caller_arn                           = ""
  sms_verification_message                                   = null
  software_token_mfa_configuration                           = {}
  software_token_mfa_configuration_enabled                   = false
  string_schemas                                             = []
  temporary_password_validity_days                           = 7
  user_group_description                                     = "Test_User_Group Description"
  user_group_name                                            = "Test_user_group"
  user_group_precedence                                      = null
  user_group_role_arn                                        = null
  user_groups                                                = []
  user_pool_add_ons                                          = {}
  user_pool_add_ons_advanced_security_mode                   = null
  user_pool_name                                             = "Test_User_Pool"
  username_attributes                                        = []
  username_configuration                                     = {}
  verification_message_template                              = {}
  verification_message_template_default_email_option         = null
  verification_message_template_email_message_by_link        = null
  verification_message_template_email_subject_by_link        = null

  #Identity Pool Inputs for creating Identity Pool
  enable_identity_pool              = true
  identity_pool_name                = "Default_Identity_Pool_Name"
  allow_unauthenticated_identities  = false
  allow_classic_flow                = false
  developer_provider_name           = "PLACE_HOLDER_VALUE"
  supported_login_providers         = {}
  saml_provider_arns                = []
  openid_connect_provider_arns      = []
  identity_pool_tags                = {}
  enable_cognito_identity_providers = false

  #When cognito_identity_providers is enabled
  cognito_identity_providers_client_id               = ""
  cognito_identity_providers_provider_name           = ""
  cognito_identity_providers_server_side_token_check = false
  #These cognito identity provider input data(client_id,provider_name,server_side_token_check) will be added.

  #When identity_pool_roles_attachment is enabled, the below inputs will be added
  enable_identity_pool_roles_attachment = false
  cognito_identity_pool_roles           = { "authenticated" = "arn:aws:mobiletargeting:*:111363027042:apps/44bdbc0071d6dummyf98777456ba7f7198*" }
  role_mapping_enabled                  = false

  #If Role Mappings is enabled
  role_mapping_identity_provider         = "Test_provider"
  role_mapping_ambiguous_role_resolution = "AuthenticatedRole"
  role_mapping_type                      = "Rules"
  role_mapping_mapping_rule_claim        = "isAdmin"
  role_mapping_mapping_rule_match_type   = "Equals"
  cognito_identity_pool_iam_role_arn     = "arn:aws::DUMMY_VALUE"
  role_mapping_mapping_rule_match_value  = "paid"
  #Then the above inputs are required.
}