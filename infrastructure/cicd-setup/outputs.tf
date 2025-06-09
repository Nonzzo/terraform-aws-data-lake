output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions."
  value       = aws_iam_role.github_actions_role.arn
}

# github_actions_role_arn = "arn:aws:iam::713881790611:role/GitHubActionsTerraformRole-dev"