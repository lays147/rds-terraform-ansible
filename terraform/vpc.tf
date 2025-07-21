module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name               = local.project
  cidr               = local.network.vpc_cidr
  enable_nat_gateway = false

  azs                          = local.network.azs
  private_subnets              = [for k, v in local.network.azs : cidrsubnet(local.network.vpc_cidr, 8, k + 3)]
  database_subnets             = [for k, v in local.network.azs : cidrsubnet(local.network.vpc_cidr, 8, k + 6)]
  create_database_subnet_group = true
  tags                         = local.tags
}

module "https_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.3"

  name        = local.project
  description = "Allow HTTPS traffic"
  vpc_id      = module.vpc.vpc_id

  egress_cidr_blocks = module.vpc.private_subnets_cidr_blocks
  egress_rules = [ "https-443-tcp" ]

  tags = local.tags
}
