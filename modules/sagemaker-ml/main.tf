resource "aws_sagemaker_notebook_instance" "this" {
  for_each = var.notebook_instances

  name                    = "${each.value.name_prefix}-${var.environment}"
  instance_type           = each.value.instance_type
  role_arn                = var.sagemaker_execution_role_arn
  subnet_id               = each.value.subnet_id
  
  volume_size             = each.value.volume_size_in_gb # Assuming the variable name is correct
  
  security_groups         = each.value.security_group_ids # Assuming the variable name is correct
  lifecycle_config_name   = each.value.lifecycle_config_name
  direct_internet_access  = each.value.direct_internet_access
  root_access             = each.value.root_access

  tags = merge(var.common_tags, {
    Name = "${each.value.name_prefix}-${var.environment}"
  })
}

# Add other SageMaker resources here as needed (Models, Endpoints, Training Jobs etc.)
# Example: SageMaker Model (very basic)
# resource "aws_sagemaker_model" "example_model" {
#   name               = "my-model-${var.environment}"
#   execution_role_arn = var.sagemaker_iam_role_arn
#   primary_container {
#     image = "174872318107.dkr.ecr.us-west-2.amazonaws.com/kmeans:1" # Example image
#   }
#   tags = var.common_tags
# }