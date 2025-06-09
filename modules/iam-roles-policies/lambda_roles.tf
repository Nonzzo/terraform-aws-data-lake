resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.lambda_role_name_prefix}-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  tags = var.common_tags
}

# Basic Lambda execution policy for CloudWatch Logs
resource "aws_iam_policy" "lambda_cloudwatch_logs_policy" {
  count = var.lambda_allow_cloudwatch_logs ? 1 : 0

  name        = "${var.lambda_policy_name_prefix}-CloudWatchLogs-${var.environment}"
  description = "Allows Lambda functions to write logs to CloudWatch."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/lambda/*:*" # Adjust if more specific log groups are needed
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_logs_attach" {
  count = var.lambda_allow_cloudwatch_logs ? 1 : 0

  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_logs_policy[0].arn
}

# Policy for S3 access if defined
resource "aws_iam_policy" "lambda_s3_access_policy" {
  count = length(var.lambda_allow_s3_access_to_buckets) > 0 ? 1 : 0

  name        = "${var.lambda_policy_name_prefix}-S3Access-${var.environment}"
  description = "Allows Lambda functions to access specified S3 buckets."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for bucket_access in var.lambda_allow_s3_access_to_buckets : {
        Action   = bucket_access.permissions
        Effect   = "Allow"
        Resource = [
          bucket_access.bucket_arn,
          "${bucket_access.bucket_arn}/*"
        ]
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_s3_access_attach" {
  count = length(var.lambda_allow_s3_access_to_buckets) > 0 ? 1 : 0

  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_s3_access_policy[0].arn
}

# Attach additional policies
resource "aws_iam_role_policy_attachment" "lambda_additional_policies_attach" {
  for_each = toset(var.lambda_additional_policy_arns)

  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = each.value
}

# AWSLambdaVPCAccessExecutionRole for VPC access if needed
# resource "aws_iam_role_policy_attachment" "lambda_vpc_access_attach" {
#   # condition if lambda needs VPC access
#   role       = aws_iam_role.lambda_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
# }