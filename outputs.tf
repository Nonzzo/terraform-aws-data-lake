output "s3_raw_bucket_name" {
  description = "Name of the S3 bucket for raw data."
  value       = module.s3_storage.bucket_ids["raw"] # Example, depends on your s3 module output
}

output "glue_catalog_database_name" {
  description = "Name of the Glue Data Catalog database."
  value       = module.glue_processing.catalog_database_names # Example
}

# Add other important outputs that users might need to access