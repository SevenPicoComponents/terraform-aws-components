variable "availability_zones" {
  type        = list(string)
  description = "The list of Availability Zones within the AWS region to deploy the VPC's subnets into."
}