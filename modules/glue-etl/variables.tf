variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)."
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources."
  default     = {}
}

variable "glue_iam_role_arn" {
  type        = string
  description = "IAM Role ARN for Glue services (crawlers, jobs)."
}

# --- Catalog Database Variables ---
variable "catalog_databases" {
  type = list(object({
    name        = string
    description = optional(string)
    location_uri = optional(string)
    parameters  = optional(map(string))
  }))
  description = "A list of Glue Catalog Databases to create."
  default     = []
}

# --- Crawler Variables ---
variable "crawlers" {
  type = map(object({
    database_name         = string
    schedule              = optional(string) # e.g., "cron(0 * * * ? *)"
    s3_targets = list(object({
      path       = string # e.g., "s3://my-bucket/my-path/"
      exclusions = optional(list(string))
    }))
    jdbc_targets = optional(list(object({ # Optional
      connection_name = string
      path            = string # e.g., "database/table/%"
      exclusions      = optional(list(string))
    })))
    configuration = optional(string) # JSON string for advanced config
    schema_change_policy = optional(object({
      update_behavior = optional(string, "UPDATE_IN_DATABASE") # LOG | UPDATE_IN_DATABASE
      delete_behavior = optional(string, "LOG")                # LOG | DELETE_FROM_DATABASE | DEPRECATE_IN_DATABASE
    }))
    table_prefix = optional(string)
  }))
  description = "A map of Glue Crawlers to create. Keys are logical names for the crawlers."
  default     = {}
}

# --- Glue Job Variables ---
variable "glue_jobs" {
  type = map(object({
    description         = optional(string, "Glue ETL Job")
    script_location     = string # S3 path to the Glue script (e.g., s3://my-glue-assets-bucket/scripts/my_job.py)
    glue_version        = optional(string, "4.0") # e.g., "3.0", "4.0"
    worker_type         = optional(string, "G.1X")
    number_of_workers   = optional(number, 2)
    timeout             = optional(number, 2880) # In minutes
    max_retries         = optional(number, 0)
    default_arguments   = optional(map(string)) # e.g., {"--job-bookmark-option": "job-bookmark-enable"}
    connections         = optional(list(string)) # List of connection names
    execution_class     = optional(string) # FLEX for Spark streaming jobs
    security_configuration = optional(string) # Name of the Glue security configuration
  }))
  description = "A map of Glue Jobs to create. Keys are logical names for the jobs."
  default     = {}
}

variable "glue_scripts_s3_bucket_id" {
  type        = string
  description = "ID of the S3 bucket where Glue job scripts are stored."
}

#  Trigger Variables ---
variable "triggers" {
  type = map(object({
    type          = string # ON_DEMAND | SCHEDULED | CONDITIONAL
    description   = optional(string)
    schedule      = optional(string) # For SCHEDULED triggers
    actions = list(object({
      job_name    = string
      arguments   = optional(map(string))
      timeout     = optional(number)
    }))
    predicate = optional(object({ # For CONDITIONAL triggers
      conditions = list(object({
        job_name      = optional(string) # Name of job to watch
        crawler_name  = optional(string) # Name of crawler to watch
        crawl_state         = string # SUCCEEDED, FAILED, TIMEOUT, STOPPED
        logical_operator = optional(string, "EQUALS") # EQUALS
      }))
      logical = optional(string, "AND") # AND | ANY
    }))
    start_on_creation = optional(bool, true)
  }))
  description = "A map of Glue Triggers to create. Keys are logical names for the triggers."
  default     = {}
}