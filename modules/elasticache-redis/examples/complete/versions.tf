## ----------------------------------------------------------------------------
##  examples/complete/versions.tf
##
##  Terraform and provider version constraints for the complete example.
## ----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.18"
    }
  }
}
