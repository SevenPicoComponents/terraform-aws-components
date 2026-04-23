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
##  ./examples/legacy/_outputs.tf
##  This file contains code written only by SevenPico, Inc.
## ----------------------------------------------------------------------------

output "context_id" {
  value = module.context.id
}
output "context_dns_name" {
  value = module.context.dns_name
}
output "context_domain_name" {
  value = module.context.domain_name
}
output "context_dns_name_format" {
  value = module.context.dns_name_format
}

output "legacy_label_id" {
  value = module.legacy_label.id
}
output "legacy_label_dns_name" {
  value = try(module.legacy_label.dns_name, "EXPECTED FAILURE")
}
output "legacy_label_domain_name" {
  value = try(module.legacy_label.domain_name, "EXPECTED FAILURE")
}
output "legacy_label_dns_name_format" {
  value = try(module.legacy_label.dns_name_format, "EXPECTED FAILURE")
}
output "legacy_label" {
  value = module.legacy_label.context
}
