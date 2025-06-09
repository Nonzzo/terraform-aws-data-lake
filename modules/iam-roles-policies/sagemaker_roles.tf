resource "aws_iam_role" "sagemaker_execution_role" {
  name = "${var.sagemaker_role_name_prefix}-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com"
        }
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_policy" "sagemaker_s3_access_policy" {
  count = length(var.sagemaker_s3_bucket_arns_for_read_write) > 0 ? 1 : 0

  name        = "${var.sagemaker_policy_name_prefix}-S3Access-${var.environment}"
  description = "Policy for SageMaker to access specified S3 buckets."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = var.sagemaker_s3_bucket_arns_for_read_write
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "sagemaker_s3_access_attach" {
  count = length(var.sagemaker_s3_bucket_arns_for_read_write) > 0 ? 1 : 0

  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_s3_access_policy[0].arn
}

# Attach the AmazonSageMakerFullAccess policy (or a more restrictive custom one)
resource "aws_iam_role_policy_attachment" "sagemaker_full_access_attach" {
  role       = aws_iam_role.sagemaker_execution_role.name
  # Consider creating a more restrictive policy based on actual needs
  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

# Policy for CloudWatch Logs
resource "aws_iam_policy" "sagemaker_cloudwatch_logs_policy" {
  name        = "${var.sagemaker_policy_name_prefix}-CloudWatchLogs-${var.environment}"
  description = "Allows SageMaker to write logs to CloudWatch."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/sagemaker/*:*"
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "sagemaker_cloudwatch_logs_attach" {
  role       = aws_iam_role.sagemaker_execution_role.name
  policy_arn = aws_iam_policy.sagemaker_cloudwatch_logs_policy.arn
}
