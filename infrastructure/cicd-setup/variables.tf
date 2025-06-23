variable "environments" {
  description = "Map of environments to deploy CI/CD roles for."
  type        = map(object({
    github_branch = string
    common_tags   = map(string)
  }))
  # Define the environments you want to manage here
  default = {
    "dev" = {
      github_branch = "develop"
      common_tags = {
        Project = "DataLake"
        Environment = "dev"
      }
    }
    "staging" = {
      github_branch = "staging"
      common_tags = {
        Project = "DataLake"
        Environment = "staging"
      }
    }
    # Add other environments as needed
    "prod" = {
      github_branch = "prod"
      common_tags = {
        Project = "DataLake"
        Environment = "prod"
      }
    }
  }
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "github_repository" {
  description = "GitHub repository in the format 'owner/repo'"
  type        = string
  # You might want to make this a variable or derive it
  default = "Nonzzo/terraform-aws-data-lake"
}

variable "role_name_prefix" {
  description = "Prefix for the GitHub Actions IAM role name"
  type        = string
  default     = "GitHubActionsTerraformRole"
}

variable "policy_name_prefix" {
  description = "Prefix for the GitHub Actions IAM policy name"
  type        = string
  default     = "GitHubActionsTerraformPolicy"
}