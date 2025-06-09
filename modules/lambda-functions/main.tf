data "archive_file" "lambda_zip" {
  for_each    = var.lambda_functions
  type        = "zip"
  source_dir  = "${path.module}/src/${each.key}/" # Assumes source code is in src/<function_logical_name>/
  output_path = "${path.root}/.lambda_package_builds/${each.key}/${each.key}_payload.zip" # Store zip in a temporary build location at root
}

resource "aws_s3_object" "lambda_code" {
  for_each = var.lambda_functions
  bucket   = var.lambda_code_s3_bucket
  key      = "lambda-functions/${each.key}/${data.archive_file.lambda_zip[each.key].output_md5}.zip"
  source   = data.archive_file.lambda_zip[each.key].output_path # Path to the zipped file
  etag     = data.archive_file.lambda_zip[each.key].output_md5   # Ensures new version uploaded if code changes
}

resource "aws_lambda_function" "this" {
  for_each         = var.lambda_functions
  function_name    = "${each.value.name_prefix}-${var.environment}"
  handler          = each.value.handler
  runtime          = each.value.runtime
  role             = var.lambda_execution_role_arn
  timeout          = each.value.timeout
  memory_size      = each.value.memory_size
  layers           = each.value.layers

  s3_bucket        = aws_s3_object.lambda_code[each.key].bucket
  s3_key           = aws_s3_object.lambda_code[each.key].key
  source_code_hash = data.archive_file.lambda_zip[each.key].output_base64sha256

  environment {
    variables = merge(var.common_lambda_env_vars, each.value.environment_variables)
  }

  tags = merge(var.common_tags, {
    Name = "${each.value.name_prefix}-${var.environment}"
  })
}

# S3 Triggers
resource "aws_lambda_permission" "s3_trigger_permission" {
  # Corrected for_each to flatten nested loops into a map
  for_each = tomap({
    for trigger in flatten([
      for func_key, func_val in var.lambda_functions : [
        for trig_idx, trig_val in func_val.s3_triggers : {
          key           = "${func_key}-s3-${trig_idx}" # Unique key for each permission
          function_name = aws_lambda_function.this[func_key].function_name
          bucket_id     = trig_val.bucket_id
          events        = trig_val.events
          filter_prefix = trig_val.filter_prefix
          filter_suffix = trig_val.filter_suffix
        }
      ] if length(func_val.s3_triggers) > 0 # Filter out functions with no triggers
    ]) : trigger.key => trigger # Convert the flat list of trigger objects into a map
  })

  statement_id  = "AllowS3InvokeLambda-${each.key}" # Use the generated key for uniqueness
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${each.value.bucket_id}" # Construct the source ARN
  
}


resource "aws_s3_bucket_notification" "s3_lambda_notification" {
  for_each = tomap({
    for trigger in flatten([
      for func_key, func_val in var.lambda_functions : [
        for trig_idx, trig_val in func_val.s3_triggers : {
          key           = "${func_key}-s3-${trig_idx}"
          function_arn  = aws_lambda_function.this[func_key].arn
          bucket_id     = trig_val.bucket_id
          events        = trig_val.events
          filter_prefix = trig_val.filter_prefix
          filter_suffix = trig_val.filter_suffix
        }
      ] if length(func_val.s3_triggers) > 0
    ]) : trigger.key => trigger
  })

  bucket = each.value.bucket_id

  lambda_function {
    lambda_function_arn = each.value.function_arn
    events              = each.value.events
    # filter_prefix and filter_suffix go directly here
    filter_prefix       = each.value.filter_prefix
    filter_suffix       = each.value.filter_suffix
  }

  depends_on = [aws_lambda_permission.s3_trigger_permission]
}
