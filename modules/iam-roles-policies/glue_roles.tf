resource "aws_iam_role" "glue_service_role" {
  name = "${var.glue_role_name_prefix}-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_policy" "glue_s3_access_policy" {
  name        = "${var.glue_policy_name_prefix}-S3Access-${var.environment}"
  description = "Policy for Glue to access specified S3 data lake buckets and Glue assets."
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
        Resource = var.glue_s3_bucket_arns_for_read_write # e.g., ["arn:aws:s3:::my-raw-bucket/*", "arn:aws:s3:::my-raw-bucket"]
      },
      { # Required for Glue to write logs and temporary files
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = [
          "${var.glue_scripts_s3_bucket_arn}/*",
          var.glue_scripts_s3_bucket_arn,
          "arn:aws:s3:::aws-glue-assets-${var.aws_account_id}-${var.aws_region}/temporary/*", # Generic Glue assets
          "arn:aws:s3:::aws-glue-assets-${var.aws_account_id}-${var.aws_region}/assets/*",
        ]
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "glue_s3_access_attach" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = aws_iam_policy.glue_s3_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "glue_service_policy_attach" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole" # Base Glue permissions
}

resource "aws_iam_policy" "glue_custom_cloudwatch_logs_policy" {
  name        = "${var.glue_policy_name_prefix}-CloudWatchLogs-${var.environment}"
  description = "Custom policy for Glue to write to specific CloudWatch Log Groups."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:AssociateKmsKey" # If using KMS for log encryption
        ],
        Effect   = "Allow",
        Resource = [ # Be as specific as possible
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws-glue/jobs/*:log-stream:*",
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws-glue/crawlers/*:log-stream:*",
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws-glue/devendpoints/*:log-stream:*",
          "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/custom-glue-logs/*:log-stream:*" # Example for custom logs
        ]
      }
    ]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "glue_cloudwatch_logs_attach" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = aws_iam_policy.glue_custom_cloudwatch_logs_policy.arn
}
