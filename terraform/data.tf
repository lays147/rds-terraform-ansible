data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {}

data "aws_iam_openid_connect_provider" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"
}
