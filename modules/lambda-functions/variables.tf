variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)."
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources."
  default     = {}
}

variable "lambda_execution_role_arn" {
  type        = string
  description = "IAM Role ARN for Lambda function execution."
}

variable "lambda_code_s3_bucket" {
  type        = string
  description = "S3 bucket where Lambda deployment packages are stored."
}

variable "common_lambda_env_vars" {
  type        = map(string)
  description = "Common environment variables for all Lambda functions."
  default     = {}
}

variable "lambda_functions" {
  type = map(object({
    name_prefix           = string                 # Prefix for the function name
    handler               = string                 # e.g., "index.handler"
    runtime               = string                 # e.g., "python3.9", "nodejs18.x"
    timeout               = optional(number, 60)   # In seconds
    memory_size           = optional(number, 256)  # In MB
    layers                = optional(list(string)) # List of Lambda Layer ARNs
    environment_variables = optional(map(string), {})
    s3_triggers = optional(list(object({ # Optional S3 triggers
      bucket_id = string
      events    = list(string) # e.g., ["s3:ObjectCreated:*"]
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })), [])
    # Add other trigger types as needed (e.g., cloudwatch_event_rule, sqs_trigger)
  }))
  description = "A map of Lambda functions to create. Keys are logical names for the functions."
  default     = {}
}