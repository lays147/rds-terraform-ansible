locals {
  golang = {
    src_path     = "${path.module}/../app"
    binary_path  = "${path.module}/bin/bootstrap"
    archive_path = "${path.module}/bin/lambda.zip"
    binary_name  = "bootstrap"
  }
}
// build the binary for the lambda function in a specified path
resource "null_resource" "function_binary" {
  triggers = {
    # Rebuild when Go source files change
    code_diff = sha1(join("", [
      for file in fileset(local.golang.src_path, "*.go") :
      filesha1("${local.golang.src_path}/${file}")
    ]))
    go_mod = filesha1("${local.golang.src_path}/go.mod")
    go_sum = fileexists("${local.golang.src_path}/go.sum") ? filesha1("${local.golang.src_path}/go.sum") : ""
  }

  provisioner "local-exec" {
    command     = "GOOS=linux GOARCH=amd64 CGO_ENABLED=0 GOFLAGS=-trimpath go build -tags lambda.norpc -mod=readonly -ldflags='-s -w' -o ${abspath(local.golang.binary_path)} ."
    working_dir = local.golang.src_path
  }
}

// zip the binary, as we can use only zip files to AWS lambda
data "archive_file" "lambda_go" {
  depends_on = [null_resource.function_binary]

  type        = "zip"
  source_file = local.golang.binary_path
  output_path = local.golang.archive_path
}

module "go_lambda" {
  depends_on = [data.archive_file.lambda_go]
  source     = "terraform-aws-modules/lambda/aws"
  version    = "~>v8.0"

  description            = "Trigger login to rds"
  handler                = local.golang.binary_name
  runtime                = "provided.al2023"
  function_name          = "${local.project}-golang"
  create_package         = false
  attach_network_policy  = true
  local_existing_package = data.archive_file.lambda_go.output_path
  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.https_sg.security_group_id]
  tags                   = merge(local.tags, { "Name" : "${local.project}-golang" })
  environment_variables = {
    "DB_NAME" = local.postgres.db_name
    "DB_USER" = local.postgres.app_user
    "DB_HOST" = module.aurora_postgresql_v2.cluster_endpoint
  }
}
