locals {
  project = "iam-auth-rds"
  region       = "us-west-1"
    
    postgres = {
        db_name = "aws-summit"
        app_user = "my_user"
        master_username = "master_user"
        port = 5432
    }

    tags = {
        AWSSummit = "2025"
    }

    ecs_cluster = "my-ecs-cluster"

    context = {
        default = {
            ecs = {
                cpu = "256"
                memory = "512"
            }
        }
    }

    network = {
    vpc_cidr = "10.0.0.0/16"
    azs      = slice(data.aws_availability_zones.available.names, 0, 3)
    }
}