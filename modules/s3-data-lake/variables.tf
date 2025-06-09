variable "buckets" {
  type = map(object({
    enable_versioning      = bool
    force_destroy          = optional(bool, false)
    lifecycle_rules = optional(list(object({
      id                                     = string
      enabled                                = bool
      prefix                                 = optional(string)
      tags                                   = optional(map(string))
      abort_incomplete_multipart_upload_days = optional(number)
      expiration = optional(object({
        date                         = optional(string)
        days                         = optional(number)
        expired_object_delete_marker = optional(bool)
      }))
      transition = optional(list(object({
        date          = optional(string)
        days          = optional(number)
        storage_class = string
      })))
      noncurrent_version_transition = optional(list(object({
        days          = number
        storage_class = string
      })))
      noncurrent_version_expiration = optional(object({
        days = number
      }))
    })), [])
    logging = optional(object({
      target_bucket = string
      target_prefix = string
    }))
  }))
  description = "A map of S3 buckets to create, with their configurations. Keys are bucket layer names (e.g., 'raw', 'processed')."
}

variable "bucket_prefix" {
  type        = string
  description = "Prefix for S3 bucket names (e.g., 'my-org-dl')."
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)."
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to apply to all resources."
  default     = {}
}

variable "kms_key_arn" {
  type        = string
  description = "Optional: Default KMS key ARN for S3 server-side encryption. Can be overridden per bucket if needed."
  default     = null
}

variable "block_public_access" {
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })
  description = "Configuration for S3 public access block."
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}