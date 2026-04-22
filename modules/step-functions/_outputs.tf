output "state_machine_id" {
  description = "State machine ID"
  value       = try(aws_sfn_state_machine.default[0].id, "")
}

output "state_machine_arn" {
  description = "State machine ARN"
  value       = try(aws_sfn_state_machine.default[0].arn, "")
}

output "state_machine_creation_date" {
  description = "State machine creation date"
  value       = try(aws_sfn_state_machine.default[0].creation_date, "")
}

output "state_machine_status" {
  description = "State machine status"
  value       = try(aws_sfn_state_machine.default[0].status, "")
}

output "role_arn" {
  description = "The ARN of the IAM role created for the Step Function"
  value       = module.iam_role.arn
}

output "role_name" {
  description = "The name of the IAM role created for the Step Function"
  value       = module.iam_role.name
}
