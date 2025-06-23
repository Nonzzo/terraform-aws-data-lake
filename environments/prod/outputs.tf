output "data_lake_s3_bucket_ids" {
  description = "IDs of the S3 data lake buckets."
  value       = module.s3_storage.bucket_ids
}

output "s3_raw_bucket_id" {
  description = "ID of the S3 raw data bucket."
  value       = module.s3_storage.bucket_ids["raw"] # Accessing the 'raw' key from the 'bucket_ids' map
}

output "glue_catalog_database_names" { # Assuming you want all catalog database names
  description = "Names of the Glue Catalog Databases created."
  value       = module.glue_processing.catalog_database_names 
                                                           
}

output "data_lake_s3_bucket_arns" {
  description = "ARNs of the S3 data lake buckets."
  value       = module.s3_storage.bucket_arns
}

output "glue_service_role_arn" {
  description = "ARN of the Glue service role."
  value       = module.iam_roles.glue_service_role_arn
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role."
  value       = module.iam_roles.lambda_execution_role_arn
}

output "example_lambda_function_arn" {
  description = "ARN of the example Lambda function."
  value       = module.lambda_processing.lambda_function_arns["example_lambda_function"] # Assuming "example_lambda_function" is the key in lambda_functions map
  sensitive   = true # Depending on your function, ARN might be sensitive
}

output "sagemaker_notebook_instance_urls" {
  description = "URLs of the SageMaker notebook instances."
  value       = module.sagemaker_notebooks.notebook_instance_urls
  sensitive   = true
}