resource "aws_glue_crawler" "this" {
  for_each = var.crawlers

  name          = "${each.key}-${var.environment}" # each.key is the logical crawler name
  role          = var.glue_iam_role_arn
  database_name = "${each.value.database_name}-${var.environment}" # Ensure DB name also includes env
  schedule      = each.value.schedule
  table_prefix  = each.value.table_prefix

  dynamic "s3_target" {
    for_each = each.value.s3_targets
    content {
      path       = s3_target.value.path
      exclusions = s3_target.value.exclusions
    }
  }

  dynamic "jdbc_target" {
    for_each = each.value.jdbc_targets != null ? each.value.jdbc_targets : []
    content {
      connection_name = jdbc_target.value.connection_name
      path            = jdbc_target.value.path
      exclusions      = jdbc_target.value.exclusions
    }
  }

  configuration = each.value.configuration

  dynamic "schema_change_policy" {
    for_each = each.value.schema_change_policy != null ? [each.value.schema_change_policy] : []
    content {
      update_behavior = schema_change_policy.value.update_behavior
      delete_behavior = schema_change_policy.value.delete_behavior
    }
  }

  tags = merge(var.common_tags, {
    Name = "${each.key}-${var.environment}"
  })

  depends_on = [aws_glue_catalog_database.this] # Ensure database exists before creating crawler
}
