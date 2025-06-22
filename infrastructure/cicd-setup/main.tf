# filepath: /Users/nonso/Documents/Projects/terraform-aws-data-lake/infrastructure/cicd-setup/main.tf
# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# Create the IAM OIDC provider for GitHub Actions (This resource is global and doesn't need for_each)
resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = [
    "6938fd48993aa451317fc3702d10a0a2511a2805", # As of June 2025, verify latest thumbprint if needed
  ]

  # Apply tags from one of the environments, or define separate global tags
  tags = var.environments["dev"].common_tags # Example: using dev tags for the global provider
}


# Create the IAM Role for GitHub Actions for each environment
resource "aws_iam_role" "github_actions_role" {
  for_each = var.environments # Iterate over the environments map

  name = "${var.role_name_prefix}-${each.key}" # Use the environment key in the name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com",
            "token.actions.githubusercontent.com:sub" : "repo:${var.github_repository}:*"
          }
        }
      },
    ]
  })

  tags = each.value.common_tags # Apply environment-specific tags
}

# Define the IAM Policy for each environment's role
resource "aws_iam_policy" "github_actions_policy" {
  for_each = var.environments # Iterate over the environments map

  name        = "${var.policy_name_prefix}-${each.key}" # Use the environment key in the name
  description = "Policy for GitHub Actions to deploy the data lake infrastructure for ${each.key}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*",
          "iam:*",
          "glue:*",
          "lambda:*",
          "sagemaker:*",
          "dynamodb:*", # For state locking
          "cloudwatch:*", # For logs/metrics
        ]
        Resource = "*" # Refine this to specific resources/ARNs for better security
      },
    ]
  })

  tags = each.value.common_tags # Apply environment-specific tags
}

# Attach the policy to the role for each environment
resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  for_each = var.environments # Iterate over the environments map

  role       = aws_iam_role.github_actions_role[each.key].name # Reference the role using the environment key
  policy_arn = aws_iam_policy.github_actions_policy[each.key].arn # Reference the policy using the environment key
}

