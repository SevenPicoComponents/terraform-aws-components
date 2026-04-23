provider "aws" {
  region = var.region
}

provider "awsutils" {
  region = var.region
}

module "vpc" {
  source  = "registry.terraform.io/SevenPico/vpc/aws"
  version = "3.0.0"

  ipv4_primary_cidr_block = "172.16.0.0/16"
  context = module.context.self
}

resource "aws_route53_zone" "private_dns_zone" {
  name = module.context.domain_name
  vpc {
    vpc_id = module.vpc.vpc_id
  }
  tags = module.context.tags
}

module "ses" {
  source = "../../"

  zone_id       = aws_route53_zone.private_dns_zone.zone_id
  verify_dkim   = var.verify_dkim
  verify_domain = var.verify_domain

  context = module.context.self
}
