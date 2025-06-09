variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)."
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources."
  default     = {}
}

variable "sagemaker_execution_role_arn" {
  description = "ARN of the IAM role for SageMaker execution."
  type        = string
}


variable "notebook_instances" {
  type = map(object({
   
    name_prefix            = string # Prefix for the notebook instance name
    instance_type          = string # e.g., "ml.t3.medium"
    volume_size_in_gb      = optional(number, 20)
    kms_key_id             = optional(string) # For volume encryption
    subnet_id              = optional(string) # For VPC configuration
    security_group_ids     = optional(list(string)) # For VPC configuration
    direct_internet_access = optional(string, "Enabled") # Enabled | Disabled
    lifecycle_config_name  = optional(string)
    default_code_repository = optional(string) # URL of a Git repository
    
    root_access            = optional(string, "Disabled") # Enabled | Disabled
  }))
  description = "A map of SageMaker Notebook Instances to create. Keys are logical names."
  default     = {}
}