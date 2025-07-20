module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws"
  cluster_name = local.ecs_cluster

  # Capacity provider
  default_capacity_provider_strategy = {
    FARGATE_SPOT = {
      weight = 100
    }
  }

  tags = local.tags
}

module "container_definition" {
  source          = "cloudposse/ecs-container-definition/aws"
  version         = "v0.60.0"
  container_name  = local.project
  container_image = local.ecs.container_image
  log_configuration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = aws_cloudwatch_log_group.this.name
      "awslogs-region"        = local.region
      "awslogs-stream-prefix" = "ecs"
    }
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.project
  container_definitions    = module.container_definition.json_map_encoded_list
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = local.context[terraform.workspace].ecs.cpu
  memory                   = local.context[terraform.workspace].ecs.memory
  task_role_arn            = aws_iam_role.task.arn
  execution_role_arn       = aws_iam_role.exec.arn
  tags                     = local.tags
}