terraform {
  required_version = ">= 1.7.0" # Specify your desired Terraform version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0.0" # Specify your desired AWS provider version
    }
  }

  # Backend configuration (example for S3 backend)
  # This will be configured per environment, but good to have a template here
  # backend "s3" {
  #   # bucket         = "your-terraform-state-bucket-name" # To be set in env config
  #   # key            = "global/s3/terraform.tfstate"      # To be set in env config
  #   # region         = "us-east-1"                        # To be set in env config
  #   # dynamodb_table = "your-terraform-lock-table"      # To be set in env config
  #   # encrypt        = true
  # }
}