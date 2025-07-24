data "aws_rds_engine_version" "postgresql" {
  engine = "aurora-postgresql"
  latest = true
}

module "aurora_postgresql_v2" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~>v9.0"

  name                = "${local.project}-postgresqlv2"
  engine              = data.aws_rds_engine_version.postgresql.engine
  engine_mode         = "provisioned"
  engine_version      = data.aws_rds_engine_version.postgresql.version
  storage_encrypted   = true
  deletion_protection = false
  instance_class      = "db.serverless"
  instances = {
    one = {}
  }

  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.database_subnet_group_name
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }
  master_username                     = local.postgres.master_username
  manage_master_user_password         = true
  iam_database_authentication_enabled = true
  monitoring_interval                 = 60


  serverlessv2_scaling_configuration = {
    min_capacity = 1
    max_capacity = 2
  }

  apply_immediately   = true
  skip_final_snapshot = true

  scaling_configuration = {
    auto_pause               = true
    min_capacity             = 2
    max_capacity             = 16
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  tags = local.tags
}
