terraform {
  backend "s3" {
    bucket         = "my-datalake-tfstate-bucket-prod" # Use unique bucket or path per env
    key            = "prod/terraform.tfstate"
    region         = "us-east-1" # Or your preferred region
    dynamodb_table = "my-datalake-tf-lock-table"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  # Assume role configuration can be added here for CI/CD
}
