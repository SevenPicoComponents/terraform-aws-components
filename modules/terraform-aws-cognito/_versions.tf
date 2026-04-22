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
##  ./_versions.tf
##  This file contains code written only by SevenPico, Inc.
## ----------------------------------------------------------------------------

terraform {
  required_version = ">= 1.1.5"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      # Starting with v4.8.0, the provider adds `aws_cognito_user_in_group` allowing adding Cognito Users to Cognito Groups in terraform
      # v4.12.1+ includes improvements for Cognito Identity Pool role mappings and enhanced security features
      # v4.51.0+ includes additional Cognito improvements and bug fixes
      # Upper bound prevents breaking changes from AWS provider v6
      # https://github.com/hashicorp/terraform-provider-aws/releases
      version = ">= 4.51.0, < 6.0.0"
    }
  }
}
