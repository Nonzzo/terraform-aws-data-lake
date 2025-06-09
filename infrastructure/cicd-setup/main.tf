# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# Create the IAM OIDC provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = [
    "6938fd48993aa451317fc3702d10a0a2511a2805", # As of June 2025, verify latest thumbprint if needed
  ]

  tags = var.common_tags
}


# Create the IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions_role" {
  name = "${var.role_name_prefix}-${var.environment}"

  # Define the trust policy to allow GitHub Actions OIDC provider to assume this role
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
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
          StringLike = {
            # Allow both push to develop branch and pull requests targeting develop
            "token.actions.githubusercontent.com:sub" : [
              "repo:${var.github_repository}:ref:refs/heads/${var.github_branch}",
              "repo:${var.github_repository}:pull_request"
            ]
          }
        }
      },
    ]
  })

  tags = var.common_tags
}

# Define the IAM Policy for the role 
# This policy should grant permissions required by your main data lake Terraform code
resource "aws_iam_policy" "github_actions_policy" {
  name        = "${var.policy_name_prefix}-${var.environment}"
  description = "Policy for GitHub Actions to deploy the data lake infrastructure"

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

  tags = var.common_tags
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}