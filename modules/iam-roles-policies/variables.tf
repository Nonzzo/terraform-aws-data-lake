variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)."
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID."
}

variable "aws_region" {
  type        = string
  description = "AWS Region."
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources."
  default     = {}
}

# --- Glue Role Variables ---
variable "glue_role_name_prefix" {
  type        = string
  description = "Prefix for the Glue service role name."
  default     = "glue-service"
}

variable "glue_policy_name_prefix" {
  type        = string
  description = "Prefix for Glue related IAM policies."
  default     = "GlueAccess"
}

variable "glue_s3_bucket_arns_for_read_write" {
  type        = list(string)
  description = "List of S3 bucket ARNs (and their /* content) that Glue needs read/write access to."
  default     = []
}

variable "glue_scripts_s3_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket where Glue scripts and temporary files are stored (e.g., arn:aws:s3:::my-glue-assets-bucket)."
  default     = "" # Should be provided
}

# --- Lambda Role Variables ---
variable "lambda_role_name_prefix" {
  type        = string
  description = "Prefix for the Lambda execution role name."
  default     = "lambda-execution"
}

variable "lambda_policy_name_prefix" {
  type        = string
  description = "Prefix for Lambda related IAM policies."
  default     = "LambdaAccess"
}

variable "lambda_allow_s3_access_to_buckets" {
  type = list(object({
    bucket_arn = string # e.g., "arn:aws:s3:::my-data-bucket"
    permissions = list(string) # e.g., ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
  }))
  description = "List of S3 buckets Lambda needs access to, with specific permissions."
  default     = []
}

variable "lambda_allow_cloudwatch_logs" {
  type        = bool
  description = "Whether to allow Lambda to write to CloudWatch Logs."
  default     = true
}

variable "lambda_additional_policy_arns" {
  type        = list(string)
  description = "List of additional IAM policy ARNs to attach to the Lambda role."
  default     = []
}

# --- SageMaker Role Variables ---
variable "sagemaker_role_name_prefix" {
  type        = string
  description = "Prefix for the SageMaker execution role name."
  default     = "sagemaker-execution"
}

variable "sagemaker_policy_name_prefix" {
  type        = string
  description = "Prefix for SageMaker related IAM policies."
  default     = "SageMakerAccess"
}

variable "sagemaker_s3_bucket_arns_for_read_write" {
  type        = list(string)
  description = "List of S3 bucket ARNs (and their /* content) that SageMaker needs read/write access to."
  default     = []
}