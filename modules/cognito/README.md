# terraform-aws-cognito

[![SevenPico](https://img.shields.io/badge/SevenPico-terraform--aws--cognito-blue)](https://registry.terraform.io/modules/SevenPico/cognito/aws)
[![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.1.5-blue)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS%20Provider-%3E%3D4.12.1-orange)](https://registry.terraform.io/providers/hashicorp/aws/latest)

This Terraform module provides a comprehensive solution for provisioning and managing AWS Cognito resources, including both **User Pools** and **Identity Pools** with advanced role mapping capabilities.

## Features

This module can provision the following AWS Cognito resources:

### User Pool Resources
- [Cognito User Pools](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html) - Complete user management
- [Cognito User Pool Clients](https://docs.aws.amazon.com/cognito/latest/developerguide/user-pool-settings-client-apps.html) - Application integration
- [Cognito User Pool Domains](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-add-custom-domain.html) - Custom domain support
- [Cognito User Pool Identity Providers](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-identity-provider.html) - Social/SAML providers
- [Cognito User Pool Resource Servers](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-define-resource-servers.html) - OAuth 2.0 resource servers
- [Cognito User Pool User Groups](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-user-groups.html) - User group management

### Identity Pool Resources (Unique Advantage)
- [Cognito Identity Pools](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-identity.html) - Federated identities
- [Identity Pool Role Attachments](https://docs.aws.amazon.com/cognito/latest/developerguide/role-based-access-control.html) - IAM role mapping
- [Advanced Role Mapping](https://docs.aws.amazon.com/cognito/latest/developerguide/role-based-access-control.html) - Rule-based role assignment

### Advanced Features
- **User Attribute Update Settings** - Enhanced security for attribute modifications
- **Comprehensive Schema Support** - String, number, and custom attribute schemas
- **Advanced Security Mode** - Built-in threat protection
- **Account Recovery Settings** - Flexible recovery mechanisms
- **Lambda Triggers** - Complete lifecycle event handling
- **Custom Email/SMS Senders** - Branded communication

## Usage

### Basic User Pool

```hcl
module "cognito" {
  source = "SevenPico/cognito/aws"

  # Context
  namespace   = "acme"
  environment = "prod"
  stage       = "main"
  name        = "app"
  region      = "us-east-1"

  # Enable User Pool
  enable_user_pool = true
  
  # Basic configuration
  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]
  
  # Password policy
  password_policy_minimum_length    = 12
  password_policy_require_lowercase = true
  password_policy_require_uppercase = true
  password_policy_require_numbers   = true
  password_policy_require_symbols   = true

  # User Pool Client
  client_name                = "web-app"
  client_generate_secret     = false
  client_explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  tags = {
    Environment = "production"
    Application = "web-app"
  }
}
```

### Complete Setup with Identity Pool

```hcl
module "cognito_complete" {
  source = "SevenPico/cognito/aws"

  # Context
  namespace   = "acme"
  environment = "prod"
  stage       = "main"
  name        = "app"
  region      = "us-east-1"

  # Enable both User Pool and Identity Pool
  enable_user_pool    = true
  enable_identity_pool = true

  # User Pool Configuration
  user_pool_name           = "MyApp Users"
  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]
  
  # Advanced security
  user_pool_add_ons_advanced_security_mode = "ENFORCED"
  mfa_configuration                        = "OPTIONAL"
  
  # User attribute update security
  user_attribute_update_settings_require_verification_before_update = ["email"]

  # Multiple clients
  clients = [
    {
      name                = "web-app"
      generate_secret     = false
      explicit_auth_flows = [
        "ALLOW_USER_PASSWORD_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH"
      ]
      callback_urls = ["https://app.example.com/callback"]
      logout_urls   = ["https://app.example.com/logout"]
    },
    {
      name                = "mobile-app"
      generate_secret     = true
      explicit_auth_flows = [
        "ALLOW_USER_SRP_AUTH",
        "ALLOW_REFRESH_TOKEN_AUTH"
      ]
      callback_urls = ["myapp://callback"]
    }
  ]

  # Identity Pool Configuration
  identity_pool_name                  = "MyApp Identity Pool"
  allow_unauthenticated_identities   = false
  
  # Identity Pool with role mapping
  enable_identity_pool_roles_attachment = true
  role_mapping_enabled                  = true
  
  cognito_identity_pool_roles = {
    authenticated = aws_iam_role.authenticated.arn
  }

  # Role mapping rules
  role_mapping_identity_provider           = "cognito-idp.us-east-1.amazonaws.com/us-east-1_example:app_client_id"
  role_mapping_type                       = "Rules"
  role_mapping_ambiguous_role_resolution  = "AuthenticatedRole"
  role_mapping_mapping_rule_claim         = "custom:role"
  role_mapping_mapping_rule_match_type    = "Equals"
  role_mapping_mapping_rule_match_value   = "admin"

  # Custom domain
  domain_name         = "auth.example.com"
  acm_certificate_arn = aws_acm_certificate.auth.arn

  # Schema definitions
  schemas = [
    {
      name                     = "email"
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = false
      required                 = true
    }
  ]

  string_schemas = [
    {
      name                     = "department"
      attribute_data_type      = "String"
      developer_only_attribute = false
      mutable                  = true
      required                 = false
      string_attribute_constraints = {
        min_length = 1
        max_length = 50
      }
    }
  ]

  tags = {
    Environment = "production"
    Application = "web-app"
  }
}

# IAM role for authenticated users
resource "aws_iam_role" "authenticated" {
  name = "cognito-authenticated-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = module.cognito_complete.identity_pool_id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })
}
```

### Lambda Triggers Example

```hcl
module "cognito_with_triggers" {
  source = "SevenPico/cognito/aws"

  # Context
  namespace   = "acme"
  environment = "prod"
  stage       = "main"
  name        = "app"
  region      = "us-east-1"

  enable_user_pool = true

  # Lambda triggers
  lambda_config_pre_sign_up       = aws_lambda_function.pre_signup.arn
  lambda_config_post_confirmation = aws_lambda_function.post_confirmation.arn
  lambda_config_pre_authentication = aws_lambda_function.pre_auth.arn
  
  # Custom email sender
  lambda_config_custom_email_sender = {
    lambda_arn     = aws_lambda_function.custom_email.arn
    lambda_version = "V1_0"
  }

  # KMS key for encryption
  lambda_config_kms_key_id = aws_kms_key.cognito.arn
}
```

## Examples

- [Complete Example](./examples/complete) - Full-featured setup with User Pool and Identity Pool
- [Basic User Pool](./examples/basic) - Simple User Pool setup
- [Identity Pool Only](./examples/identity-pool) - Identity Pool with role mapping
- [Lambda Triggers](./examples/lambda-triggers) - User Pool with Lambda triggers

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1.5 |
| aws | >= 4.12.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.12.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| context | SevenPico/context/null | 2.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cognito_user_pool.pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [aws_cognito_identity_provider.identity_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_provider) | resource |
| [aws_cognito_resource_server.resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_resource_server) | resource |
| [aws_cognito_user_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_group) | resource |
| [aws_cognito_identity_pool.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_pool) | resource |
| [aws_cognito_identity_pool_roles_attachment.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_pool_roles_attachment) | resource |

## Inputs

### Context Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| namespace | ID element. Usually an abbreviation of your organization name | `string` | `null` | no |
| environment | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| stage | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| name | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| region | AWS region | `string` | `null` | no |
| tags | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`) | `map(string)` | `{}` | no |

### User Pool Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_user_pool | Whether to create the User Pool | `bool` | `false` | no |
| user_pool_name | User pool name. If not provided, the name will be generated from the context | `string` | `null` | no |
| alias_attributes | Attributes supported as an alias for this user pool | `list(string)` | `null` | no |
| username_attributes | Specifies whether email addresses or phone numbers can be specified as usernames | `list(string)` | `null` | no |
| auto_verified_attributes | The attributes to be auto-verified | `list(string)` | `[]` | no |
| mfa_configuration | Multi-factor authentication configuration | `string` | `"OFF"` | no |
| deletion_protection | When active, DeletionProtection prevents accidental deletion | `string` | `"INACTIVE"` | no |

### Password Policy

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| password_policy_minimum_length | The minimum password length | `number` | `8` | no |
| password_policy_require_lowercase | Whether to require lowercase letters | `bool` | `true` | no |
| password_policy_require_uppercase | Whether to require uppercase letters | `bool` | `true` | no |
| password_policy_require_numbers | Whether to require numbers | `bool` | `true` | no |
| password_policy_require_symbols | Whether to require symbols | `bool` | `true` | no |

### Client Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| clients | User Pool clients configuration | `any` | `[]` | no |
| client_name | The name of the application client | `string` | `null` | no |
| client_generate_secret | Should an application secret be generated | `bool` | `true` | no |
| client_explicit_auth_flows | List of authentication flows | `list(string)` | `[]` | no |
| client_callback_urls | List of allowed callback URLs | `list(string)` | `[]` | no |
| client_logout_urls | List of allowed logout URLs | `list(string)` | `[]` | no |

### Identity Pool Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| enable_identity_pool | Whether to create the Identity Pool | `bool` | `false` | no |
| identity_pool_name | The Cognito Identity Pool name | `string` | `"identity pool"` | no |
| allow_unauthenticated_identities | Whether the identity pool supports unauthenticated logins | `bool` | `false` | no |
| enable_identity_pool_roles_attachment | Whether to enable roles attachment | `bool` | `false` | no |
| cognito_identity_pool_roles | Map of roles for the identity pool | `map(any)` | `{}` | no |

### Role Mapping Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| role_mapping_enabled | Whether to enable role mapping | `bool` | `false` | no |
| role_mapping_identity_provider | Identity provider for role mapping | `string` | `"PLACEHOLDER_IDENTITY_PROVIDER_VALUE"` | no |
| role_mapping_type | The role mapping type | `string` | `"Rules"` | no |
| role_mapping_mapping_rule_claim | The claim name that must be present in the token | `string` | `"isAdmin"` | no |
| role_mapping_mapping_rule_match_type | The match condition for the claim value | `string` | `"Equals"` | no |
| role_mapping_mapping_rule_match_value | The value that the claim must match | `string` | `"paid"` | no |

### Domain Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain_name | Cognito User Pool domain | `string` | `null` | no |
| acm_certificate_arn | The ARN of an ISSUED ACM certificate in `us-east-1` for a custom domain | `string` | `null` | no |

### Advanced Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| user_pool_add_ons_advanced_security_mode | The mode for advanced security | `string` | `null` | no |
| user_attribute_update_settings_require_verification_before_update | Attributes requiring verification before update | `list(string)` | `null` | no |
| schemas | A container with the schema attributes of a User Pool | `list(any)` | `[]` | no |
| string_schemas | A container with the string schema attributes | `list(any)` | `[]` | no |
| number_schemas | A container with the number schema attributes | `list(any)` | `[]` | no |

## Outputs

### User Pool Outputs

| Name | Description |
|------|-------------|
| id | The ID of the User Pool |
| arn | The ARN of the User Pool |
| endpoint | The endpoint name of the User Pool |
| creation_date | The date the User Pool was created |
| last_modified_date | The date the User Pool was last modified |

### Client Outputs

| Name | Description |
|------|-------------|
| client_ids | The IDs of the User Pool clients |
| client_secrets | The client secrets of the User Pool clients |
| client_ids_map | Map of client names to IDs |
| client_secrets_map | Map of client names to secrets |

### Domain Outputs

| Name | Description |
|------|-------------|
| domain_aws_account_id | The AWS account ID for the User Pool domain |
| domain_cloudfront_distribution_arn | The ARN of the CloudFront distribution |
| domain_s3_bucket | The S3 bucket for domain static files |
| domain_app_version | The app version for the domain |

### Identity Pool Outputs

| Name | Description |
|------|-------------|
| identity_pool_id | The ID of the Identity Pool |
| identity_pool_arn | The ARN of the Identity Pool |
| identity_pool_tags_all | Tags assigned to the Identity Pool |

### Resource Server Outputs

| Name | Description |
|------|-------------|
| resource_servers_scope_identifiers | List of all scopes configured |

## Key Advantages

### 🚀 Complete Cognito Solution
Unlike other modules that focus only on User Pools, this module provides comprehensive support for both User Pools and Identity Pools with advanced role mapping.

### 🔐 Enhanced Security Features
- User attribute update verification settings
- Advanced security mode support
- Comprehensive password policies
- MFA configuration options

### 🎯 Flexible Architecture
- SevenPico context system for consistent resource naming
- Support for multiple clients with different configurations
- Extensive customization options
- Lambda trigger integration

### 📊 Better Outputs
- Map-based outputs for easier client reference
- Comprehensive Identity Pool information
- Domain and resource server details

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## License

This module is licensed under the Apache 2.0 License. See [LICENSE](LICENSE) for full details.

## About SevenPico

This module is maintained by [SevenPico](https://www.sevenpico.com/), a team of DevOps engineers and cloud architects focused on creating robust, scalable infrastructure solutions.

---

[![SevenPico](https://img.shields.io/badge/Built%20by-SevenPico-blue)](https://www.sevenpico.com/)
