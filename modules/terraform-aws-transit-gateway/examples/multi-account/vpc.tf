module "vpc_prod" {
  source  = "SevenPico/vpc/aws"
  version = "3.0.2"

  ipv4_primary_cidr_block = "172.16.0.0/16"

  context = module.context.context

  providers = {
    aws = aws.prod
  }
}

module "subnets_prod" {
  source  = "SevenPico/dynamic-subnets/aws"
  version = "3.1.3"

  availability_zones      = var.availability_zones
  vpc_id                  = module.vpc_prod.vpc_id
  igw_id                  = [module.vpc_prod.igw_id]
  ipv4_cidr_block         = [module.vpc_prod.vpc_cidr_block]
  nat_gateway_enabled     = false
  nat_instance_enabled    = false
  map_public_ip_on_launch = false

  attributes = ["prod"]
  context    = module.context.context

  providers = {
    aws = aws.prod
  }
}

module "vpc_staging" {
  source  = "SevenPico/vpc/aws"
  version = "3.0.2"

  ipv4_primary_cidr_block = "172.32.0.0/16"

  context = module.context.context

  providers = {
    aws = aws.staging
  }
}

module "subnets_staging" {
  source  = "SevenPico/dynamic-subnets/aws"
  version = "3.1.3"

  availability_zones      = var.availability_zones
  vpc_id                  = module.vpc_staging.vpc_id
  igw_id                  = [module.vpc_staging.igw_id]
  ipv4_cidr_block         = [module.vpc_staging.vpc_cidr_block]
  nat_gateway_enabled     = false
  nat_instance_enabled    = false
  map_public_ip_on_launch = false

  attributes = ["staging"]
  context    = module.context.context

  providers = {
    aws = aws.staging
  }
}

module "vpc_dev" {
  source  = "SevenPico/vpc/aws"
  version = "3.0.2"

  ipv4_primary_cidr_block = "172.48.0.0/16"

  context = module.context.context

  providers = {
    aws = aws.dev
  }
}

module "subnets_dev" {
  source  = "SevenPico/dynamic-subnets/aws"
  version = "3.1.3"

  availability_zones      = var.availability_zones
  vpc_id                  = module.vpc_dev.vpc_id
  igw_id                  = [module.vpc_dev.igw_id]
  ipv4_cidr_block         = [module.vpc_dev.vpc_cidr_block]
  nat_gateway_enabled     = false
  nat_instance_enabled    = false
  map_public_ip_on_launch = false

  attributes = ["dev"]
  context    = module.context.context

  providers = {
    aws = aws.dev
  }
}
