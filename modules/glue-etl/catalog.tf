resource "aws_glue_catalog_database" "this" {
  for_each = { for db in var.catalog_databases : db.name => db }

  name         = "${each.key}-${var.environment}" # Appending environment to db name
  description  = each.value.description
  location_uri = each.value.location_uri
  parameters   = each.value.parameters

  tags = var.common_tags
}