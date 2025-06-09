#!/bin/bash

# Script to create S3 backend and DynamoDB table for Terraform state

# Configuration
# Ensure these are unique and comply with AWS naming conventions.
# It's recommended to parameterize these or set them as environment variables.
# For multiple environments, you might run this script with different parameters
# or create separate buckets/tables per environment.
# This script creates a GLOBAL backend setup. For per-environment backends as per the doc,
# you'd typically have different bucket names/paths for dev, staging, prod.
# The Terraform config in `environments/<env>/main.tf` will point to these.

TF_STATE_BUCKET_NAME="nonso-terraform-state-bucket-$(aws sts get-caller-identity --query Account --output text)" # MAKE THIS GLOBALLY UNIQUE
TF_LOCK_TABLE_NAME="nonso-terraform-lock-table" # Can be shared across environments if region is same
AWS_REGION="us-east-1" # Choose your primary region

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null
then
    echo "AWS CLI could not be found. Please install and configure it."
    exit 1
fi

echo "Using AWS Region: $AWS_REGION"
echo "Attempting to create S3 bucket: $TF_STATE_BUCKET_NAME"
echo "Attempting to create DynamoDB table: $TF_LOCK_TABLE_NAME"
echo ""
read -p "Proceed? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    echo "Operation cancelled."
    exit 0
fi

# Create S3 Bucket for Terraform State
# Adding checks for bucket existence and region consistency
bucket_exists=$(aws s3api head-bucket --bucket "$TF_STATE_BUCKET_NAME" --region "$AWS_REGION" 2>&1 || true)

if [[ $bucket_exists == *"Not Found"* ]]; then
    echo "Creating S3 bucket: $TF_STATE_BUCKET_NAME in region $AWS_REGION..."
    if [ "$AWS_REGION" == "us-east-1" ]; then
        aws s3api create-bucket --bucket "$TF_STATE_BUCKET_NAME" --region "$AWS_REGION"
    else
        aws s3api create-bucket --bucket "$TF_STATE_BUCKET_NAME" --region "$AWS_REGION" --create-bucket-configuration LocationConstraint="$AWS_REGION"
    fi

    if [ $? -ne 0 ]; then
        echo "Error creating S3 bucket. Exiting."
        exit 1
    fi
    echo "S3 bucket $TF_STATE_BUCKET_NAME created successfully."
elif [[ $bucket_exists == *"Bad Request"* ]] || [[ $bucket_exists == *"Forbidden"* ]] ; then
    echo "Error checking S3 bucket $TF_STATE_BUCKET_NAME. It might exist in another region or you lack permissions."
    echo "Please ensure the bucket name is globally unique and you have s3:ListBucket permissions."
    exit 1
else
    echo "S3 bucket $TF_STATE_BUCKET_NAME already exists in region $AWS_REGION."
fi


# Enable Versioning on the S3 Bucket
echo "Enabling versioning on bucket $TF_STATE_BUCKET_NAME..."
aws s3api put-bucket-versioning --bucket "$TF_STATE_BUCKET_NAME" --versioning-configuration Status=Enabled --region "$AWS_REGION"
if [ $? -ne 0 ]; then
    echo "Error enabling versioning on S3 bucket. Please check permissions."
    # Not exiting, as this is a best practice but not strictly required for backend to function
fi
echo "Versioning enabled on $TF_STATE_BUCKET_NAME."

# Enable Server-Side Encryption on the S3 Bucket
echo "Enabling server-side encryption on bucket $TF_STATE_BUCKET_NAME..."
aws s3api put-bucket-encryption --bucket "$TF_STATE_BUCKET_NAME" --server-side-encryption-configuration '{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}' --region "$AWS_REGION"
if [ $? -ne 0 ]; then
    echo "Error enabling server-side encryption on S3 bucket. Please check permissions."
fi
echo "Server-side encryption enabled on $TF_STATE_BUCKET_NAME."

# Block Public Access on the S3 Bucket
echo "Blocking public access on bucket $TF_STATE_BUCKET_NAME..."
aws s3api put-public-access-block \
    --bucket "$TF_STATE_BUCKET_NAME" \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
    --region "$AWS_REGION"
if [ $? -ne 0 ]; then
    echo "Error blocking public access on S3 bucket. Please check permissions."
fi
echo "Public access blocked on $TF_STATE_BUCKET_NAME."


# Create DynamoDB Table for Terraform State Locking
table_status=$(aws dynamodb describe-table --table-name "$TF_LOCK_TABLE_NAME" --region "$AWS_REGION" --query "Table.TableStatus" --output text 2>/dev/null)

if [ -z "$table_status" ]; then
    echo "Creating DynamoDB table: $TF_LOCK_TABLE_NAME..."
    aws dynamodb create-table \
        --table-name "$TF_LOCK_TABLE_NAME" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
        --region "$AWS_REGION"

    if [ $? -ne 0 ]; then
        echo "Error creating DynamoDB table. Exiting."
        exit 1
    fi
    echo "DynamoDB table $TF_LOCK_TABLE_NAME creation initiated. Waiting for it to become active..."
    aws dynamodb wait table-exists --table-name "$TF_LOCK_TABLE_NAME" --region "$AWS_REGION"
    echo "DynamoDB table $TF_LOCK_TABLE_NAME created and active."
else
    echo "DynamoDB table $TF_LOCK_TABLE_NAME already exists with status: $table_status."
fi

echo ""
echo "Terraform backend S3 bucket and DynamoDB lock table setup complete."
echo "Bucket Name: $TF_STATE_BUCKET_NAME"
echo "DynamoDB Table Name: $TF_LOCK_TABLE_NAME"
echo "AWS Region: $AWS_REGION"
echo ""
echo "Configure your Terraform backend.tf or main.tf in each environment like this:"
echo "terraform {"
echo "  backend \"s3\" {"
echo "    bucket         = \"$TF_STATE_BUCKET_NAME\""
echo "    key            = \"<environment_name>/terraform.tfstate\"  # e.g., dev/terraform.tfstate"
echo "    region         = \"$AWS_REGION\""
echo "    dynamodb_table = \"$TF_LOCK_TABLE_NAME\""
echo "    encrypt        = true"
echo "  }"
echo "}"