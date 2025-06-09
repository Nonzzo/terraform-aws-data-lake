output "notebook_instance_arns" {
  description = "ARNs of the SageMaker Notebook Instances created."
  value       = { for k, v in aws_sagemaker_notebook_instance.this : k => v.arn }
}

output "notebook_instance_urls" {
  description = "URLs of the SageMaker Notebook Instances created."
  value       = { for k, v in aws_sagemaker_notebook_instance.this : k => v.url }
}

output "notebook_instance_names" {
  description = "Names of the SageMaker Notebook Instances created."
  value       = { for k, v in aws_sagemaker_notebook_instance.this : k => v.name }
}
