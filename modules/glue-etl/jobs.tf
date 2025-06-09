resource "aws_glue_job" "this" {
  for_each = var.glue_jobs

  name              = "${each.key}-${var.environment}" # each.key is the logical job name
  description       = each.value.description
  role_arn          = var.glue_iam_role_arn
  glue_version      = each.value.glue_version
  worker_type       = each.value.worker_type
  number_of_workers = each.value.number_of_workers
  timeout           = each.value.timeout
  max_retries       = each.value.max_retries
  connections       = each.value.connections
  execution_class   = each.value.execution_class # For Spark streaming, set to FLEX
  security_configuration = each.value.security_configuration


  command {
    name            = "glueetl" # or "pythonshell" or "gluestreaming"
    script_location = each.value.script_location # e.g., s3://my-glue-scripts-bucket/etl/my_job.py
    python_version  = "3" # For Glue 3.0+, Python 3 is default. For pythonshell, can be 2 or 3.
  }

  default_arguments = merge(
    {
      "--job-language"       = "python", # or scala
      "--TempDir"            = "s3://${var.glue_scripts_s3_bucket_id}/temporary/" # Required for some jobs
      "--enable-metrics"     = "" # Enable CloudWatch metrics for the job
      # Add other common default arguments if needed
    },
    each.value.default_arguments
  )

  tags = merge(var.common_tags, {
    Name = "${each.key}-${var.environment}"
  })
}