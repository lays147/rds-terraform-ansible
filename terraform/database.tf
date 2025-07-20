module "db" {
  source                         = "terraform-aws-modules/rds/aws"
  identifier                     = local.project
  instance_use_identifier_prefix = true

  create_db_option_group    = false
  create_db_parameter_group = false

  engine               = "postgres"
  engine_version       = "16"
  family               = "postgres16"
  major_engine_version = "16"
  instance_class       = "db.t3.micro"

  allocated_storage = 5

  db_name                     = local.postgres.db_name
  manage_master_user_password = true
  iam_database_authentication_enabled = true
  port                        = local.postgres.port

  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 0
}