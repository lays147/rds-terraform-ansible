# resource "aws_iam_openid_connect_provider" "default" {
#   url             = "https://${local.github.oidc_domain}"
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
# }

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "Github"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github_oidc.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.github.oidc_domain}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "${local.github.oidc_domain}:sub"
      values   = [local.github.reponame]
    }
  }
}

resource "aws_iam_role" "github_oidc" {
  name               = "${local.project}-assume-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
