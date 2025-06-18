variable "aws_region" {
  description = "AWS region for the deployment."
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID where resources will be deployed."
  type        = string
}

variable "s3_bucket_prefix" {
  description = "Prefix for all S3 data lake buckets."
  type        = string
}

variable "s3_kms_key_arn" {
  description = "Optional: KMS Key ARN for S3 bucket encryption. If null, AES256 is used."
  type        = string
  default     = null
}

variable "lambda_code_s3_bucket_name_suffix" {
  description = "Suffix for the Lambda code S3 bucket (prefix will be s3_bucket_prefix)."
  type        = string
  default     = "lambda-code-assets" # Results in <s3_bucket_prefix>-lambda-code-assets-dev
}

variable "glue_scripts_s3_bucket_name_suffix" {
  description = "Suffix for the Glue scripts S3 bucket."
  type        = string
  default     = "glue-assets" # Results in <s3_bucket_prefix>-glue-assets-dev
}

# Example Lambda function configuration
variable "example_lambda_s3_target_bucket_layer" {
  description = "The layer name of the S3 bucket that the example Lambda will target for triggers (e.g., 'raw')."
  type        = string
  default     = "raw"
}