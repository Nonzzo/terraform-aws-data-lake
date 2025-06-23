output "catalog_database_names" {
  description = "Names of the Glue Catalog Databases created."
  value       = [for db in aws_glue_catalog_database.this : db.name]
}

output "crawler_names" {
  description = "Names of the Glue Crawlers created."
  value       = [for crawler in aws_glue_crawler.this : crawler.name]
}

output "crawler_arns" {
  description = "ARNs of the Glue Crawlers created."
  value       = [for crawler in aws_glue_crawler.this : crawler.arn]
}

output "job_names" {
  description = "Names of the Glue Jobs created."
  value       = [for job in aws_glue_job.this : job.name]
}

output "job_arns" {
  description = "ARNs of the Glue Jobs created."
  value       = [for job in aws_glue_job.this : job.arn]
}


output "glue_crawlers" {
  description = "Map of created Glue Crawler resources"
  # Assuming your aws_glue_crawler resource in the module is named 'this'
  value       = aws_glue_crawler.this
}

output "glue_jobs" {
  description = "Map of created Glue Job resources"
  # Assuming your aws_glue_job resource in the module is named 'this'
  value       = aws_glue_job.this
}