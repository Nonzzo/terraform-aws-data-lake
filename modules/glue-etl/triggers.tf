resource "aws_glue_trigger" "this" {
  for_each = var.triggers

  name              = "${each.key}-${var.environment}"
  description       = each.value.description
  type              = each.value.type
  schedule          = each.value.schedule
  start_on_creation = each.value.start_on_creation
  enabled           = true # You can make this configurable

  dynamic "actions" {
    for_each = each.value.actions
    content {
      job_name  = "${actions.value.job_name}-${var.environment}"
      arguments = actions.value.arguments
      timeout   = actions.value.timeout
    }
  }

  dynamic "predicate" {
    for_each = each.value.predicate != null ? [each.value.predicate] : []
    content {
      logical = predicate.value.logical

      dynamic "conditions" {
        for_each = predicate.value.conditions
        content {
          job_name         = conditions.value.job_name != null ? "${conditions.value.job_name}-${var.environment}" : null
          crawler_name     = conditions.value.crawler_name != null ? "${conditions.value.crawler_name}-${var.environment}" : null
          state            = conditions.value.state
          logical_operator = conditions.value.logical_operator
        }
      }
    }
  }

  tags = merge(var.common_tags, {
    Name = "${each.key}-${var.environment}"
  })

  # Ensure the jobs and crawlers being referenced exist before creating the trigger
  depends_on = [
    aws_glue_job.this,
    aws_glue_crawler.this
  ]
}