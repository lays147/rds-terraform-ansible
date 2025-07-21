module "ecs_cluster" {
  source       = "terraform-aws-modules/ecs/aws"
  cluster_name = local.context[terraform.workspace].ecs.cluster_name
  version      = "~> 6.0"

  # Capacity provider
  default_capacity_provider_strategy = {
    FARGATE_SPOT = {
      weight = 100
    }
  }

  tags = local.tags
}
