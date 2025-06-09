output "lambda_function_arns" {
  description = "ARNs of the Lambda functions created."
  value       = { for k, v in aws_lambda_function.this : k => v.arn }
}

output "lambda_function_names" {
  description = "Names of the Lambda functions created."
  value       = { for k, v in aws_lambda_function.this : k => v.function_name }
}

output "lambda_function_invoke_arns" {
  description = "Invoke ARNs of the Lambda functions created."
  value       = { for k, v in aws_lambda_function.this : k => v.invoke_arn }
}