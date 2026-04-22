provider "aws" {
  region = var.region
}

module "vpc" {
  source                  = "../../"
  ipv4_primary_cidr_block = "172.16.0.0/16"

  context = module.context.self
}

module "subnets" {
  source  = "SevenPico/dynamic-subnets/aws"
  version = "3.0.0"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  ipv4_cidr_block      = [module.vpc.vpc_cidr_block]
  nat_gateway_enabled  = false
  nat_instance_enabled = false

  context = module.context.self
}

# Verify that a disabled VPC generates a plan without errors
module "vpc_disabled" {
  source  = "../../"
  enabled = false

  ipv4_primary_cidr_block = "172.16.0.0/16"

  context = module.context.self
}
