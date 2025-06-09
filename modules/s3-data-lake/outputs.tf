output "bucket_ids" {
  description = "A map of S3 bucket IDs, keyed by the layer name."
  value       = { for k, bucket in aws_s3_bucket.data_lake_bucket : k => bucket.id }
}

output "bucket_arns" {
  description = "A map of S3 bucket ARNs, keyed by the layer name."
  value       = { for k, bucket in aws_s3_bucket.data_lake_bucket : k => bucket.arn }
}

output "bucket_domain_names" {
  description = "A map of S3 bucket domain names, keyed by the layer name."
  value       = { for k, bucket in aws_s3_bucket.data_lake_bucket : k => bucket.bucket_domain_name }
}

