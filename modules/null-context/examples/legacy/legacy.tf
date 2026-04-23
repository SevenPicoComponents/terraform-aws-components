## ----------------------------------------------------------------------------
##  Copyright 2023 SevenPico, Inc.
##  Copyright 2020-2022 Cloud Posse, LLC
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
##  ./examples/legacy/legacy.tf
##  This file contains code written only by SevenPico, Inc.
## ----------------------------------------------------------------------------

module "legacy_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0" # requires Terraform >= 0.13.0
  context = module.context.legacy
  name    = "hello"
}
