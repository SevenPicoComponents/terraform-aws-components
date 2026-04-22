locals {
  account_id = get_aws_account_id()
  tenant     = "Brim"

  region      = get_env("AWS_REGION")
  root_domain = "modules.thebrim.io"

  namespace   = "brim"
  project     = "sqs-queue" //replace(basename(get_repo_root()), "teraform-", "")
  environment = ""
  stage       = basename(get_terragrunt_dir()) //
  domain_name = "${local.stage}.${local.project}.${local.root_domain}"

  tags                = { Source = "Managed by Terraform" }
  regex_replace_chars = "/[^-a-zA-Z0-9]/"
  delimiter           = "-"
  replacement         = ""
  id_length_limit     = 0
  id_hash_length      = 5
  label_key_case      = "title"
  label_value_case    = "lower"
  label_order         = ["namespace", "project", "environment", "stage", "name", "attributes"]
}

inputs = {
  root_domain = local.root_domain

  # Standard Context
  region              = local.region
  tenant              = local.tenant
  project             = local.project
  domain_name         = local.domain_name
  project             = local.project
  namespace           = local.namespace
  environment         = local.environment
  stage               = local.stage
  tags                = local.tags
  regex_replace_chars = local.regex_replace_chars
  delimiter           = local.delimiter
  replacement         = local.replacement
  id_length_limit     = local.id_length_limit
  id_hash_length      = local.id_hash_length
  label_key_case      = local.label_key_case
  label_value_case    = local.label_value_case
  label_order         = local.label_order

  # Module / Example Specific - SQS Queue Configuration
  
  # Basic Queue Configuration
  visibility_timeout_seconds = 30
  message_retention_seconds  = 345600 # 4 days
  max_message_size          = 262144  # 256 KiB
  delay_seconds             = 0
  receive_wait_time_seconds = 0

  # Dead Letter Queue Configuration
  dlq_enabled                       = false
  dlq_name_suffix                   = "dlq"
  dlq_max_receive_count             = 5
  dlq_content_based_deduplication   = null
  dlq_deduplication_scope           = null
  dlq_delay_seconds                 = null
  dlq_kms_data_key_reuse_period_seconds = null
  dlq_kms_master_key_id             = null
  dlq_message_retention_seconds     = null
  dlq_receive_wait_time_seconds     = null
  create_dlq_redrive_allow_policy   = true
  dlq_redrive_allow_policy          = {}
  dlq_sqs_managed_sse_enabled       = true
  dlq_visibility_timeout_seconds    = null
  dlq_tags                          = {}

  # FIFO Queue Configuration
  fifo_queue                  = false
  fifo_throughput_limit       = null
  content_based_deduplication = false
  deduplication_scope         = null

  # Encryption Configuration
  kms_master_key_id                 = null
  kms_data_key_reuse_period_seconds = 300
  sqs_managed_sse_enabled           = true

  # IAM Policy Configuration
  iam_policy_limit_to_current_account = true
  iam_policy = []

}

remote_state {
  backend      = "s3"
  disable_init = false
  config = {
    bucket                = "brim-sandbox-tfstate"
    disable_bucket_update = true
    dynamodb_table        = "brim-sandbox-tfstate-lock"
    encrypt               = true
    key                   = "${local.account_id}/${local.project}/${local.stage}/terraform.tfstate"
    region                = local.region
  }
  generate = {
    path      = "generated-backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

generate "providers" {
  path      = "generated-providers.tf"
  if_exists = "overwrite"
  contents  = <<EOF
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 4"
      }
      local = {
        source  = "hashicorp/local"
      }
      acme = {
        source  = "vancluever/acme"
        version = "~> 2.8.0"
      }
    }
  }

  provider "aws" {
    region  = "${local.region}"
  }
}
