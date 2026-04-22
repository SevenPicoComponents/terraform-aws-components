## ----------------------------------------------------------------------------
##  Copyright 2023 SevenPico, Inc.
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##  ./_variables.tf
##  This file contains code written only by SevenPico, Inc.
## ----------------------------------------------------------------------------
variable "user_pool_name" {
  description = "User pool name. If not provided, the name will be generated from the context"
  type        = string
  default     = null
}

variable "email_verification_message" {
  description = "A string representing the email verification message"
  type        = string
  default     = null
}

variable "email_verification_subject" {
  description = "A string representing the email verification subject"
  type        = string
  default     = null
}

variable "username_configuration" {
  description = "The Username Configuration. Setting `case_sensitive` specifies whether username case sensitivity will be applied for all users in the user pool through Cognito APIs"
  type        = map(any)
  default     = {}
}

variable "admin_create_user_config" {
  description = "The configuration for AdminCreateUser requests"
  type        = map(any)
  default     = {}
}

variable "admin_create_user_config_allow_admin_create_user_only" {
  description = "Set to `true` if only the administrator is allowed to create user profiles. Set to `false` if users can sign themselves up via an app"
  type        = bool
  default     = true
}

variable "temporary_password_validity_days" {
  description = "The user account expiration limit, in days, after which the account is no longer usable"
  type        = number
  default     = 7
}

variable "admin_create_user_config_email_message" {
  description = "The message template for email messages. Must contain `{username}` and `{####}` placeholders, for username and temporary password, respectively"
  type        = string
  default     = "{username}, your temporary password is `{####}`"
}

variable "admin_create_user_config_email_subject" {
  description = "The subject line for email messages"
  type        = string
  default     = "Your verification code"
}

variable "admin_create_user_config_sms_message" {
  description = "The message template for SMS messages. Must contain `{username}` and `{####}` placeholders, for username and temporary password, respectively"
  type        = string
  default     = "Your username is {username} and temporary password is `{####}`"
}

variable "alias_attributes" {
  description = "Attributes supported as an alias for this user pool. Possible values: phone_number, email, or preferred_username. Conflicts with `username_attributes`"
  type        = list(string)
  default     = null
}

variable "username_attributes" {
  description = "Specifies whether email addresses or phone numbers can be specified as usernames when a user signs up. Conflicts with `alias_attributes`"
  type        = list(string)
  default     = null
}

variable "auto_verified_attributes" {
  description = "The attributes to be auto-verified. Possible values: email, phone_number"
  type        = list(string)
  default     = []
}

variable "sms_configuration" {
  description = "SMS configuration"
  type        = map(any)
  default     = {}
}

variable "sms_configuration_external_id" {
  description = "The external ID used in IAM role trust relationships"
  type        = string
  default     = ""
}

variable "sms_configuration_sns_caller_arn" {
  description = "The ARN of the Amazon SNS caller. This is usually the IAM role that you've given Cognito permission to assume"
  type        = string
  default     = ""
}

variable "device_configuration" {
  description = "The configuration for the user pool's device tracking"
  type        = map(any)
  default     = {}
}

variable "device_configuration_challenge_required_on_new_device" {
  description = "Indicates whether a challenge is required on a new device. Only applicable to a new device"
  type        = bool
  default     = false
}

variable "device_configuration_device_only_remembered_on_user_prompt" {
  description = "If true, a device is only remembered on user prompt"
  type        = bool
  default     = false
}

variable "email_configuration" {
  description = "Email configuration"
  type        = map(any)
  default     = {}
}

variable "email_configuration_reply_to_email_address" {
  description = "The REPLY-TO email address"
  type        = string
  default     = ""
}

variable "email_configuration_source_arn" {
  description = "The ARN of the email configuration source"
  type        = string
  default     = ""
}

variable "email_configuration_email_sending_account" {
  description = "Instruct Cognito to either use its built-in functionality or Amazon SES to send out emails. Allowed values: `COGNITO_DEFAULT` or `DEVELOPER`"
  type        = string
  default     = "COGNITO_DEFAULT"
}

variable "email_configuration_from_email_address" {
  description = "Sender’s email address or sender’s display name with their email address (e.g. `john@example.com`, `John Smith <john@example.com>` or `\"John Smith Ph.D.\" <john@example.com>)`. Escaped double quotes are required around display names that contain certain characters as specified in RFC 5322"
  type        = string
  default     = null
}

variable "lambda_config" {
  description = "Configuration for the AWS Lambda triggers associated with the User Pool"
  type        = any
  default     = null
}

variable "lambda_config_create_auth_challenge" {
  description = "The ARN of the lambda creating an authentication challenge"
  type        = string
  default     = ""
}

variable "lambda_config_custom_message" {
  description = "AWS Lambda trigger custom message"
  type        = string
  default     = ""
}

variable "lambda_config_define_auth_challenge" {
  description = "Authentication challenge"
  type        = string
  default     = ""
}

variable "lambda_config_post_authentication" {
  description = "A post-authentication AWS Lambda trigger"
  type        = string
  default     = ""
}

variable "lambda_config_post_confirmation" {
  description = "A post-confirmation AWS Lambda trigger"
  type        = string
  default     = ""
}

variable "lambda_config_pre_authentication" {
  description = "A pre-authentication AWS Lambda trigger"
  type        = string
  default     = ""
}

variable "lambda_config_pre_sign_up" {
  description = "A pre-registration AWS Lambda trigger"
  type        = string
  default     = ""
}

variable "lambda_config_pre_token_generation" {
  description = "Allow to customize identity token claims before token generation"
  type        = string
  default     = ""
}

variable "lambda_config_user_migration" {
  description = "The user migration Lambda config type"
  type        = string
  default     = ""
}

variable "lambda_config_verify_auth_challenge_response" {
  description = "Verifies the authentication challenge response"
  type        = string
  default     = ""
}

variable "lambda_config_kms_key_id" {
  description = "The Amazon Resource Name of Key Management Service Customer master keys. Amazon Cognito uses the key to encrypt codes and temporary passwords sent to CustomEmailSender and CustomSMSSender."
  type        = string
  default     = null
}

variable "lambda_config_custom_email_sender" {
  description = "A custom email sender AWS Lambda trigger"
  type        = map(any)
  default     = {}
}

variable "lambda_config_custom_sms_sender" {
  description = "A custom SMS sender AWS Lambda trigger"
  type        = map(any)
  default     = {}
}

variable "mfa_configuration" {
  description = "Multi-factor authentication configuration. Must be one of the following values (ON, OFF, OPTIONAL)"
  type        = string
  default     = "OFF"
}

variable "software_token_mfa_configuration" {
  description = "Configuration block for software token MFA. `mfa_configuration` must also be enabled for this to work"
  type        = map(any)
  default     = {}
}

variable "software_token_mfa_configuration_enabled" {
  description = "If `true`, and if `mfa_configuration` is also enabled, multi-factor authentication by software TOTP generator will be enabled"
  type        = bool
  default     = false
}

variable "password_policy" {
  description = "User Pool password policy configuration"
  type = object({
    minimum_length                   = number,
    require_lowercase                = bool,
    require_numbers                  = bool,
    require_symbols                  = bool,
    require_uppercase                = bool,
    temporary_password_validity_days = number
  })
  default = null
}

variable "password_policy_minimum_length" {
  description = "The minimum password length"
  type        = number
  default     = 8
}

variable "password_policy_require_lowercase" {
  description = "Whether you have required users to use at least one lowercase letter in their password"
  type        = bool
  default     = true
}

variable "password_policy_require_numbers" {
  description = "Whether you have required users to use at least one number in their password"
  type        = bool
  default     = true
}

variable "password_policy_require_symbols" {
  description = "Whether you have required users to use at least one symbol in their password"
  type        = bool
  default     = true
}

variable "password_policy_require_uppercase" {
  description = "Whether you have required users to use at least one uppercase letter in their password"
  type        = bool
  default     = true
}

variable "password_policy_temporary_password_validity_days" {
  description = "Password policy temporary password validity_days"
  type        = number
  default     = 7
}

variable "schemas" {
  description = "A container with the schema attributes of a User Pool. Maximum of 50 attributes"
  type        = list(any)
  default     = []
}

variable "string_schemas" {
  description = "A container with the string schema attributes of a user pool. Maximum of 50 attributes"
  type        = list(any)
  default     = []
}

variable "number_schemas" {
  description = "A container with the number schema attributes of a user pool. Maximum of 50 attributes"
  type        = list(any)
  default     = []
}

variable "sms_authentication_message" {
  description = "A string representing the SMS authentication message"
  type        = string
  default     = null
}

variable "sms_verification_message" {
  description = "A string representing the SMS verification message"
  type        = string
  default     = null
}

variable "user_pool_add_ons" {
  description = "Configuration block for user pool add-ons to enable user pool advanced security mode features"
  type        = map(any)
  default     = {}
}


variable "user_pool_add_ons_advanced_security_mode" {
  description = "The mode for advanced security, must be one of `OFF`, `AUDIT` or `ENFORCED`"
  type        = string
  default     = null
}

variable "verification_message_template" {
  description = "The verification message templates configuration"
  type        = map(any)
  default     = {}
}

variable "verification_message_template_default_email_option" {
  description = "The default email option. Must be either `CONFIRM_WITH_CODE` or `CONFIRM_WITH_LINK`. Defaults to `CONFIRM_WITH_CODE`"
  type        = string
  default     = null
}

variable "verification_message_template_email_message_by_link" {
  description = "The email message template for sending a confirmation link to the user, it must contain the `{##Click Here##}` placeholder"
  type        = string
  default     = null
}

variable "verification_message_template_email_subject_by_link" {
  description = "The subject line for the email message template for sending a confirmation link to the user"
  type        = string
  default     = null
}

variable "acm_certificate_arn" {
  description = "The ARN of an ISSUED ACM certificate in `us-east-1` for a custom domain"
  type        = string
  default     = null
}

variable "clients" {
  description = "User Pool clients configuration"
  type        = any
  default     = []
}

variable "client_allowed_oauth_flows" {
  description = "List of allowed OAuth flows (code, implicit, client_credentials)"
  type        = list(string)
  default     = []
}

variable "client_allowed_oauth_flows_user_pool_client" {
  description = "Whether the client is allowed to follow the OAuth protocol when interacting with Cognito user pools"
  type        = bool
  default     = true
}

variable "client_allowed_oauth_scopes" {
  description = "List of allowed OAuth scopes (phone, email, openid, profile, and aws.cognito.signin.user.admin)"
  type        = list(string)
  default     = []
}

variable "client_callback_urls" {
  description = "List of allowed callback URLs for the identity providers"
  type        = list(string)
  default     = []
}

variable "client_default_redirect_uri" {
  description = "The default redirect URI. Must be in the list of callback URLs"
  type        = string
  default     = ""
}

variable "client_explicit_auth_flows" {
  description = "List of authentication flows (ADMIN_NO_SRP_AUTH, CUSTOM_AUTH_FLOW_ONLY, USER_PASSWORD_AUTH)"
  type        = list(string)
  default     = []
}

variable "client_generate_secret" {
  description = "Should an application secret be generated"
  type        = bool
  default     = true
}

variable "client_logout_urls" {
  description = "List of allowed logout URLs for the identity providers"
  type        = list(string)
  default     = []
}

variable "client_name" {
  description = "The name of the application client"
  type        = string
  default     = null
}

variable "client_read_attributes" {
  description = "List of user pool attributes the application client can read from"
  type        = list(string)
  default     = []
}

variable "client_prevent_user_existence_errors" {
  description = "Choose which errors and responses are returned by Cognito APIs during authentication, account confirmation, and password recovery when the user does not exist in the user pool. When set to ENABLED and the user does not exist, authentication returns an error indicating either the username or password was incorrect, and account confirmation and password recovery return a response indicating a code was sent to a simulated destination. When set to LEGACY, those APIs will return a UserNotFoundException exception if the user does not exist in the user pool."
  type        = string
  default     = null
}

variable "client_supported_identity_providers" {
  description = "List of provider names for the identity providers that are supported on this client"
  type        = list(string)
  default     = []
}

variable "client_write_attributes" {
  description = "List of user pool attributes the application client can write to"
  type        = list(string)
  default     = []
}

variable "client_access_token_validity" {
  description = "Time limit, between 5 minutes and 1 day, after which the access token is no longer valid and cannot be used. This value will be overridden if you have entered a value in `token_validity_units`."
  type        = number
  default     = 60
}

variable "client_id_token_validity" {
  description = "Time limit, between 5 minutes and 1 day, after which the ID token is no longer valid and cannot be used. Must be between 5 minutes and 1 day. Cannot be greater than refresh token expiration. This value will be overridden if you have entered a value in `token_validity_units`."
  type        = number
  default     = 60
}

variable "client_refresh_token_validity" {
  description = "The time limit in days refresh tokens are valid for. Must be between 60 minutes and 3650 days. This value will be overridden if you have entered a value in `token_validity_units`"
  type        = number
  default     = 30
}

variable "client_token_validity_units" {
  description = "Configuration block for units in which the validity times are represented in. Valid values for the following arguments are: `seconds`, `minutes`, `hours` or `days`."
  type        = any
  default = {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

variable "user_groups" {
  description = "User groups configuration"
  type        = list(any)
  default     = []
}

variable "user_group_name" {
  description = "The name of the user group"
  type        = string
  default     = null
}

variable "user_group_description" {
  description = "The description of the user group"
  type        = string
  default     = null
}

variable "user_group_precedence" {
  description = "The precedence of the user group"
  type        = number
  default     = null
}

variable "user_group_role_arn" {
  description = "The ARN of the IAM role to be associated with the user group"
  type        = string
  default     = null
}

variable "resource_servers" {
  description = "Resource servers configuration"
  type        = list(any)
  default     = []
}

variable "resource_server_name" {
  description = "Resource server name"
  type        = string
  default     = null
}

variable "resource_server_identifier" {
  description = "Resource server identifier"
  type        = string
  default     = null
}

variable "resource_server_scope_name" {
  description = "Resource server scope name"
  type        = string
  default     = null
}

variable "resource_server_scope_description" {
  description = "Resource server scope description"
  type        = string
  default     = null
}

variable "recovery_mechanisms" {
  description = "List of account recovery options"
  type        = list(any)
  default     = []
}

variable "identity_providers" {
  description = "Cognito Identity Providers configuration"
  type        = list(any)
  default     = []
}

variable "identity_pool_name" {
  description = "The Cognito Identity Pool name."
  type        = string
  default     = "identity pool"
}

variable "allow_unauthenticated_identities" {
  description = "Whether the identity pool supports unauthenticated logins or not."
  type        = bool
  default     = false
}

variable "allow_classic_flow" {
  description = "Enables or disables the classic / basic authentication flow. "
  type        = bool
  default     = false
}

variable "developer_provider_name" {
  description = "The DOMAIN by which Cognito will refer to your users. This name acts as a placeholder that allows your backend and the Cognito service to communicate about the developer provider. "
  type        = string
  default     = ""
}

variable "supported_login_providers" {
  description = "Key-Value pairs mapping provider names to provider app IDs."
  type        = map(any)
  default     = {}
}

variable "saml_provider_arns" {
  description = "An array of Amazon Resource Names (ARNs) of the SAML provider for your identity."
  type        = list(any)
  default     = []
}

variable "openid_connect_provider_arns" {
  description = "Set of OpenID Connect provider ARNs."
  type        = set(string)
  default     = []
}

variable "identity_pool_tags" {
  description = "A map of tags to assign to the Identity Pool. "
  type        = map(any)
  default     = {}
}

variable "cognito_identity_providers_client_id" {
  description = "A map of tags to assign to the Identity Pool. "
  type        = string
  default     = ""
}

variable "cognito_identity_providers_provider_name" {
  description = "The provider name for an Amazon Cognito Identity User Pool."
  type        = string
  default     = ""
}

variable "cognito_identity_providers_server_side_token_check" {
  description = "Whether server-side token validation is enabled for the identity provider’s token or not."
  type        = bool
  default     = false
}

variable "enable_identity_pool" {
  description = "Whether identity pool is required or not"
  type        = bool
  default     = false
}

variable "enable_cognito_identity_providers" {
  description = "Whether cognito identity providers are required or not"
  type        = bool
  default     = false
}

variable "role_mapping_identity_provider" {
  description = "Role Mapping itself is OPTIONAL. But if you choose to have role mappings, Identity provider is REQUIRED : A string identifying the identity provider, for example, | graph.facebook.com | cognito-idp.us-east-1.amazonaws.com/us-east-1_abcdefghi:app_client_id. Depends on cognito_identity_providers set on aws_cognito_identity_pool resource or a aws_cognito_identity_provider resource."
  type        = string
  default     = "PLACEHOLDER_IDENTITY_PROVIDER_VALUE"
}

variable "role_mapping_ambiguous_role_resolution" {
  description = "(Optional) - Specifies the action to be taken if either no rules match the claim value for the Rules type, or there is no cognito:preferred_role claim and there are multiple cognito:roles matches for the Token type. Required if you specify Token or Rules as the Type."
  type        = string
  default     = "PLACEHOLDER_AuthenticatedRole"
}

variable "role_mapping_type" {
  description = "(Required) - The role mapping type."
  type        = string
  default     = "Rules"
}

variable "role_mapping_mapping_rule_claim" {
  description = <<EOT
  (Required) - The claim name that must be present in the token, for example, "isAdmin" or "paid"."
EOT
  type        = string
  default     = "isAdmin"
}

variable "role_mapping_mapping_rule_match_type" {
  description = <<EOT
  (Required) - The match condition that specifies how closely the claim value in the IdP token must match Value.
EOT
  type        = string
  default     = "Equals"
}

variable "role_mapping_mapping_rule_match_value" {
  description = <<EOT
  (Required) - A brief string that the claim must match, for example, "paid" or "yes".
EOT
  type        = string
  default     = "paid"
}

variable "cognito_identity_pool_roles" {
  description = "roles = { ''authenticated'' = aws_iam_role.authenticated.arn}" //Single quotes are not valid. Use double quotes (") to enclose strings.
  type        = map(any)
  default     = {}
}

variable "cognito_identity_pool_iam_role_arn" {
  description = "(Required) - The role ARN."
  type        = string
  default     = "PLACEHOLDER_VALUE"
}

variable "role_mapping_enabled" {
  description = "Functionality to have role mapping enabled or not."
  type        = bool
  default     = false
}

variable "enable_identity_pool_roles_attachment" {
  description = "Functionality to have roles attachment enabled or not."
  type        = bool
  default     = false
}

variable "enable_user_pool" {
  description = "Functionality to have user pool enabled or not."
  type        = bool
  default     = false
}

variable "deletion_protection" {
  description = "(Optional) When active, DeletionProtection prevents accidental deletion of your user pool. Before you can delete a user pool that you have protected against deletion, you must deactivate this feature. Valid values are ACTIVE and INACTIVE, Default value is INACTIVE"
  type        = string
  default     = "INACTIVE"
}
