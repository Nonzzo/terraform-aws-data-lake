# Example Output for ARNs (update as needed)
output "github_actions_role_arns" {
  description = "ARNs of the GitHub Actions IAM roles per environment"
  value       = { for env, role in aws_iam_role.github_actions_role : env => role.arn }
}