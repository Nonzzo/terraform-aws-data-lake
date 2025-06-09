variable "aws_region" {
  description = "AWS region to deploy the CI/CD infrastructure."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)."
  type        = string
}

variable "role_name_prefix" {
  description = "Prefix for the GitHub Actions IAM role name."
  type        = string
  default     = "GitHubActionsTerraformRole"
}

variable "policy_name_prefix" {
  description = "Prefix for the GitHub Actions IAM policy name."
  type        = string
  default     = "GitHubActionsTerraformPolicy"
}

variable "github_repository" {
  description = "The GitHub repository (org/repo) that is allowed to assume the role."
  type        = string
  # Example: "nonso/terraform-aws-data-lake"
}

variable "github_branch" {
  description = "The GitHub branch that is allowed to assume the role."
  type        = string
  # Example: "develop"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources."
  default     = {}
}