variable "zone_id" {
  type        = string
  description = "Route53 parent zone ID. If provided (not empty), the module will create Route53 DNS records used for verification"
  default     = ""
}

variable "verify_domain" {
  type        = bool
  description = "If provided the module will create Route53 DNS records used for domain verification."
  default     = false
}

variable "verify_dkim" {
  type        = bool
  description = "If provided the module will create Route53 DNS records used for DKIM verification."
  default     = false
}

variable "iam_permissions" {
  type        = list(string)
  description = "Specifies permissions for the IAM user."
  default     = ["ses:SendRawEmail"]
}

variable "iam_allowed_resources" {
  type        = list(string)
  description = "Specifies resource ARNs that are enabled for `var.iam_permissions`. Wildcards are acceptable."
  default     = []
}

variable "iam_access_key_max_age" {
  type        = number
  description = "Maximum age of IAM access key (seconds). Defaults to 30 days. Set to 0 to disable expiration."
  default     = 2592000

  validation {
    condition     = var.iam_access_key_max_age >= 0
    error_message = "The iam_access_key_max_age must be 0 (disabled) or greater."
  }
}

variable "ses_group_enabled" {
  type        = bool
  description = "Creates a group with permission to send emails from SES domain"
  default     = true
}

variable "ses_group_name" {
  type        = string
  description = "The name of the IAM group to create. If empty the module will calculate name from a context (recommended)."
  default     = ""
}

variable "ses_group_path" {
  type        = string
  description = "The IAM Path of the group to create"
  default     = "/"
}

variable "ses_user_enabled" {
  type        = bool
  description = "Creates user with permission to send emails from SES domain"
  default     = true
}

variable "ssm_ignore_value_changes" {
  type        = bool
  default     = false
  description = "Set to true to ignore Parameter store value changes when. Default is false"
}

variable "ssm_ses_smtp_password_enabled" {
  type        = bool
  description = "Whether or not to create an SES SMTP password"
  default     = false
}

variable "ssm_enabled" {
  type        = bool
  description = <<-EOT
    Set `true` to store secrets in SSM Parameter Store, `
    false` to store secrets in Terraform state as outputs.
    Since Terraform state would contain the secrets in plaintext,
    use of SSM Parameter Store is recommended.
    EOT
  default     = true
}

variable "force_destroy" {
  type        = bool
  description = "Destroy the user even if it has non-Terraform-managed IAM access keys, login profile or MFA devices"
  default     = false
}

variable "path" {
  type        = string
  description = "Path in which to create the user"
  default     = "/"
}

variable "inline_policies" {
  type        = list(string)
  description = "Inline policies to attach to our created user"
  default     = []
}

variable "inline_policies_map" {
  type        = map(string)
  description = "Inline policies to attach (descriptive key => policy)"
  default     = {}
}

variable "policy_arns" {
  type        = list(string)
  description = "Policy ARNs to attach to our created user"
  default     = []
}

variable "policy_arns_map" {
  type        = map(string)
  description = "Policy ARNs to attach (descriptive key => arn)"
  default     = {}
}

variable "permissions_boundary" {
  type        = string
  description = "Permissions Boundary ARN to attach to our created user"
  default     = null
}

variable "create_iam_access_key" {
  type        = bool
  description = "Whether or not to create IAM access keys"
  default     = true
}