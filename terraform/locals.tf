locals {
  project = "iam-auth-rds"
  region  = "us-east-1"
  github = {
    oidc_domain = "token.actions.githubusercontent.com"
    reponame    = "repo:lays147/rds-terraform-ansible:ref:refs/tags/*"
  }

  network = {
    vpc_cidr   = "10.0.0.0/16"
    azs        = ["us-east-1a", "us-east-1b", ]
    https_port = 443
  }

  postgres = {
    db_name                      = "aws-summit"
    app_user                     = "my_user"
    master_username              = "master_user"
    preferred_maintenance_window = "sun:05:00-sun:06:00"
  }

  context = {
    default = {
      ecs = {
        cluster_name  = "my-ecs-cluster"
        cpu           = "256"
        memory        = "512"
        container_tag = "latest"
      }
    }
  }

  tags = {
    AWSSummit = "2025"
  }
}
