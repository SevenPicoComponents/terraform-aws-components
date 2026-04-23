## ----------------------------------------------------------------------------
##  examples/serverless/versions.tf
##
##  Terraform and provider version constraints for the serverless example.
## ----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.32"
    }
  }
}
