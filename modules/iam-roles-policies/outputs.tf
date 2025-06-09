output "glue_service_role_arn" {
  description = "ARN of the IAM role for AWS Glue services."
  value       = aws_iam_role.glue_service_role.arn
}

output "glue_service_role_name" {
  description = "Name of the IAM role for AWS Glue services."
  value       = aws_iam_role.glue_service_role.name
}

output "lambda_execution_role_arn" {
  description = "ARN of the IAM role for AWS Lambda execution."
  value       = aws_iam_role.lambda_execution_role.arn
}

output "lambda_execution_role_name" {
  description = "Name of the IAM role for AWS Lambda execution."
  value       = aws_iam_role.lambda_execution_role.name
}

output "sagemaker_execution_role_arn" {
  description = "ARN of the IAM role for AWS SageMaker execution."
  value       = aws_iam_role.sagemaker_execution_role.arn
}

output "sagemaker_execution_role_name" {
  description = "Name of the IAM role for AWS SageMaker execution."
  value       = aws_iam_role.sagemaker_execution_role.name
}