variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "A unique name for the project to prefix resources"
  type        = string
  default     = "mydatalake"
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project   = "DataLakeAutomation"
    Terraform = "true"
  }
}

variable "s3_raw_bucket_name_suffix" {
  description = "Suffix for the raw S3 bucket name. Full name will be <project_name>-<suffix>."
  type        = string
  default     = "raw-data"
}

variable "s3_processed_bucket_name_suffix" {
  description = "Suffix for the processed S3 bucket name."
  type        = string
  default     = "processed-data"
}

variable "s3_query_results_bucket_name_suffix" {
  description = "Suffix for the S3 bucket to store Athena/Glue query results."
  type        = string
  default     = "query-results"
}

variable "s3_glue_scripts_bucket_name_suffix" {
  description = "Suffix for the S3 bucket to store Glue ETL scripts and Lambda code."
  type        = string
  default     = "glue-lambda-scripts"
}

variable "glue_catalog_db_name" {
  description = "Name for the AWS Glue Data Catalog database."
  type        = string
  default     = "data_lake_catalog"
}

variable "glue_crawler_name_raw" {
  description = "Name for the Glue Crawler for raw data."
  type        = string
  default     = "raw_data_crawler"
}

variable "lambda_function_name" {
  description = "Name for the Lambda function."
  type        = string
  default     = "s3_trigger_glue_crawler_lambda"
}

variable "lambda_zip_path" {
  description = "Path to the zipped Lambda deployment package."
  type        = string
  default     = "modules/lambda/src/s3_trigger_glue_crawler/package.zip" # Path relative to root
}

variable "sagemaker_notebook_instance_name" {
  description = "Name for the SageMaker Notebook Instance."
  type        = string
  default     = "MyDataLakeNotebook"
}

variable "sagemaker_notebook_instance_type" {
  description = "Instance type for the SageMaker Notebook."
  type        = string
  default     = "ml.t3.medium"
}

variable "glue_job_name" {
  description = "Name for the example AWS Glue ETL job."
  type        = string
  default     = "example_etl_job"
}

variable "glue_job_script_s3_key" {
  description = "S3 key for the Glue ETL script (must be uploaded to the glue-scripts bucket)."
  type        = string
  default     = "scripts/example_glue_job.py" # Example path
}