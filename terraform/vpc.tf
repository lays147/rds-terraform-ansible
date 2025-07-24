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
  egress_rules       = ["https-443-tcp"]
  egress_with_source_security_group_id = [{
    source_security_group_id = module.aurora_postgresql_v2.security_group_id
    from_port                = 5432
    to_port                  = 5432
    protocol                 = "tcp"
  }]

  tags = local.tags
}

module "endpoints" {
  source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.https_sg.security_group_id]
  endpoints = {
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    }
    rds = {
      service             = "rds"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    },
    secretsmanager = {
      service             = "secretsmanager"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    }

    logs = {
      service             = "logs"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
    }

    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      subnet_ids      = module.vpc.private_subnets
      route_table_ids = flatten([module.vpc.private_route_table_ids])
    }
  }
}
