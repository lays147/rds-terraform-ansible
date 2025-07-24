output "github_oidc_role_arn" {
  description = "The ARN of the GitHub OIDC role"
  value       = aws_iam_role.github_oidc.arn
}
