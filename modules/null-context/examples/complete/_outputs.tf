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
##  ./examples/complete/_outputs.tf
##  This file contains code modified by SevenPico, Inc.
## ----------------------------------------------------------------------------

output "id" {
  value = module.context.id
}
output "id_full" {
  value = module.context.id_full
}
output "dns_name" {
  value = module.context.dns_name
}
output "enabled" {
  value = module.context.enabled
}
output "namespace" {
  value = module.context.namespace
}
output "tenant" {
  value = module.context.tenant
}
output "environment" {
  value = module.context.environment
}
output "name" {
  value = module.context.name
}
output "stage" {
  value = module.context.stage
}
output "delimiter" {
  value = module.context.delimiter
}
output "attributes" {
  value = module.context.attributes
}
output "tags" {
  value = module.context.tags
}
output "additional_tag_map" {
  value = module.context.additional_tag_map
}
output "label_order" {
  value = module.context.label_order
}
output "regex_replace_chars" {
  value = module.context.regex_replace_chars
}
output "id_length_limit" {
  value = module.context.id_length_limit
}
output "tags_as_list_of_maps" {
  value = module.context.tags_as_list_of_maps
}
output "descriptors" {
  value = module.context.descriptors
}
output "normalized_context" {
  value = module.context.normalized_context
}

output "dns_name_format" {
  value = module.context.dns_name_format
}
output "domain_name" {
  value = module.context.domain_name
}
