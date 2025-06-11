resource "aws_glue_trigger" "this" {
  for_each = var.triggers # Iterate over the map of triggers

  name        = "${each.key}-${var.environment}"
  type        = each.value.type
  description = lookup(each.value, "description", null)
  schedule    = lookup(each.value, "schedule", null)
  start_on_creation = lookup(each.value, "start_on_creation", true) # Default to true

  dynamic "actions" {
    for_each = each.value.actions
    content {
      job_name = actions.value.job_name
      arguments = lookup(actions.value, "arguments", null)
      timeout = lookup(actions.value, "timeout", null)
      # Add other action attributes if needed
    }
  }

  dynamic "predicate" {
    # Only create predicate block if the trigger type is CONDITIONAL and predicate is defined in the variable
    for_each = each.value.type == "CONDITIONAL" && each.value.predicate != null ? [each.value.predicate] : []
    content {
      logical = lookup(predicate.value, "logical", "AND") # Default to AND

      # Alternative dynamic conditions block using count
      dynamic "conditions" {
        count = length(predicate.value.conditions) # Iterate based on the number of conditions
        content {
          # Access values using the count index
          job_name         = lookup(predicate.value.conditions[count.index], "job_name", null)
          crawler_name     = lookup(predicate.value.conditions[count.index], "crawler_name", null)
          state            = predicate.value.conditions[count.index].state # Access state by index
          logical_operator = lookup(predicate.value.conditions[count.index], "logical_operator", "EQUALS") # Default to EQUALS
          # Add other condition attributes if needed
        }
      }
    }
  }

  tags = merge(var.common_tags, {
    Name = "${each.key}-${var.environment}"
  })

  # Ensure the jobs and crawlers being referenced exist before creating the trigger
  # This depends_on might need to be more specific if you have multiple jobs/crawlers
  # For a single job/crawler referenced by the trigger, this might be okay.
  # If the trigger watches a specific job/crawler, depends_on should reference that specific resource instance.
  # Example: depends_on = [aws_glue_job.this[actions.value.job_name], aws_glue_crawler.this[conditions.value.crawler_name]]
  # However, the current depends_on refers to the entire map resource, which is less precise but often works.
  # Let's keep the current depends_on for now as the error is not dependency related.
  depends_on = [
    aws_glue_job.this,
    aws_glue_crawler.this
  ]
}