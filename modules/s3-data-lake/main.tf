resource "aws_s3_bucket" "data_lake_bucket" {
  for_each = var.buckets
  bucket   = "${var.bucket_prefix}-${each.key}-${var.environment}" # each.key is the layer_name (raw, processed, etc.)

  tags = merge(var.common_tags, {
    Name  = "${var.bucket_prefix}-${each.key}-${var.environment}"
    Layer = each.key
  })
}



resource "aws_s3_bucket_versioning" "data_lake_bucket_versioning" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.data_lake_bucket[each.key].id
  versioning_configuration {
    status = each.value.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake_bucket_sse" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.data_lake_bucket[each.key].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_arn != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = var.kms_key_arn != null ? true : false # Enable S3 Bucket Key for KMS if KMS key is used
  }
}


resource "aws_s3_bucket_lifecycle_configuration" "data_lake_bucket_lifecycle" {
  # Only create this resource if there are any buckets with lifecycle rules defined
  for_each = { for k, v in var.buckets : k => v if v.lifecycle_rules != null && length(v.lifecycle_rules) > 0 }
  bucket   = aws_s3_bucket.data_lake_bucket[each.key].id

  # Use a dynamic block to create multiple 'rule' blocks
  dynamic "rule" {
    for_each = each.value.lifecycle_rules # Iterate over the list of rules for this bucket
    content {
      id     = rule.value.id
      # The 'status' argument is required inside the rule block
      status = rule.value.enabled ? "Enabled" : "Disabled" # Use the 'enabled' value from your variable to set 'status'

      # Add prefix or filter block here if needed for specific rules
      # If the rule applies to the whole bucket, you can add filter {} or prefix = ""
      # Based on previous discussion, adding prefix = "" for rules without specific filters
      prefix = lookup(rule.value, "prefix", "") # Use lookup to handle rules without a specific prefix

      dynamic "transition" {
        for_each = lookup(rule.value, "transition", null) != null ? rule.value.transition : []
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = lookup(rule.value, "expiration", null) != null ? [rule.value.expiration] : []
        content {
          days = expiration.value.days
        }
      }

      
    }
  }
}



resource "aws_s3_bucket_logging" "data_lake_bucket_logging" {
  for_each = { for k, v in var.buckets : k => v if lookup(v, "logging", null) != null }
  bucket   = aws_s3_bucket.data_lake_bucket[each.key].id

  target_bucket = each.value.logging.target_bucket
  target_prefix = each.value.logging.target_prefix
}

resource "aws_s3_bucket_public_access_block" "data_lake_bucket_public_access_block" {
  for_each = var.buckets
  bucket   = aws_s3_bucket.data_lake_bucket[each.key].id

  block_public_acls       = var.block_public_access.block_public_acls
  block_public_policy     = var.block_public_access.block_public_policy
  ignore_public_acls      = var.block_public_access.ignore_public_acls
  restrict_public_buckets = var.block_public_access.restrict_public_buckets
}