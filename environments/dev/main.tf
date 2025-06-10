terraform {
  backend "s3" {
    bucket         = "nonso-terraform-state-bucket-713881790611" # Replace with your actual bucket name
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"               # Replace with your desired region
    dynamodb_table = "nonso-terraform-lock-table" # Replace with your actual DynamoDB table name
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
  # For CI/CD, configure assume_role or use OIDC provider via GitHub Actions
}

locals {
  environment_name = "dev"
  common_tags = {
    Environment = local.environment_name
    Project     = "DataLake"
    ManagedBy   = "Terraform"
  }
  lambda_code_bucket_name = "${var.s3_bucket_prefix}-${var.lambda_code_s3_bucket_name_suffix}-${local.environment_name}"
  glue_assets_bucket_name = "${var.s3_bucket_prefix}-${var.glue_scripts_s3_bucket_name_suffix}-${local.environment_name}"
}

module "s3_storage" {
  source = "../../modules/s3-data-lake"

  environment     = local.environment_name
  bucket_prefix   = var.s3_bucket_prefix
  kms_key_arn     = var.s3_kms_key_arn
  common_tags     = local.common_tags

  buckets = {
    raw = {
      enable_versioning = true
      lifecycle_rules = [
        {
          id      = "archive-raw-data"
          enabled = true
          transition = [{
            days          = 90
            storage_class = "GLACIER"
          }]
        }
      ]
    },
    processed = {
      enable_versioning = true
    },
    curated = {
      enable_versioning = false # Typically curated data might not need versioning or less aggressive
    },
    logs = { # For S3 access logs from other buckets
      enable_versioning = false
      lifecycle_rules = [{
        id         = "log-archive"
        enabled    = true
        expiration = { days = 365 }
      }]
    },
    "${var.glue_scripts_s3_bucket_name_suffix}" = { # Bucket for Glue scripts and temporary files
      enable_versioning = true
    },
    "${var.lambda_code_s3_bucket_name_suffix}" = { # Bucket for Lambda code
      enable_versioning = true
    }
  }
}

module "iam_roles" {
  source = "../../modules/iam-roles-policies"

  environment                         = local.environment_name
  aws_account_id                      = var.aws_account_id
  aws_region                          = var.aws_region
  common_tags                         = local.common_tags

  glue_role_name_prefix               = "glue-datalake"
  glue_s3_bucket_arns_for_read_write  = [
    module.s3_storage.bucket_arns.raw,
    "${module.s3_storage.bucket_arns.raw}/*",
    module.s3_storage.bucket_arns.processed,
    "${module.s3_storage.bucket_arns.processed}/*",
    module.s3_storage.bucket_arns.curated,
    "${module.s3_storage.bucket_arns.curated}/*",
  ]
  glue_scripts_s3_bucket_arn          = module.s3_storage.bucket_arns[var.glue_scripts_s3_bucket_name_suffix]


  lambda_role_name_prefix             = "lambda-datalake"
  lambda_allow_cloudwatch_logs        = true
  lambda_allow_s3_access_to_buckets   = [
    {
      bucket_arn  = module.s3_storage.bucket_arns.raw
      permissions = ["s3:GetObject", "s3:ListBucket"]
    },
    {
      bucket_arn  = module.s3_storage.bucket_arns.processed
      permissions = ["s3:PutObject"]
    }
  ]
  # lambda_additional_policy_arns     = ["arn:aws:iam::aws:policy/AmazonSQSFullAccess"] # Example

  sagemaker_role_name_prefix          = "sagemaker-datalake"
  sagemaker_s3_bucket_arns_for_read_write = [
    module.s3_storage.bucket_arns.raw,
    "${module.s3_storage.bucket_arns.raw}/*",
    module.s3_storage.bucket_arns.processed,
    "${module.s3_storage.bucket_arns.processed}/*",
    module.s3_storage.bucket_arns.curated,
    "${module.s3_storage.bucket_arns.curated}/*",
    module.s3_storage.bucket_arns[var.glue_scripts_s3_bucket_name_suffix], # SageMaker might need access to assets
    "${module.s3_storage.bucket_arns[var.glue_scripts_s3_bucket_name_suffix]}/*",
  ]
}

module "glue_processing" {
  source = "../../modules/glue-etl"

  environment                 = local.environment_name
  common_tags                 = local.common_tags
  glue_iam_role_arn           = module.iam_roles.glue_service_role_arn
  glue_scripts_s3_bucket_id   = module.s3_storage.bucket_ids[var.glue_scripts_s3_bucket_name_suffix]

  catalog_databases = [
    { name = "raw_db", description = "Database for raw data" },
    { name = "processed_db", description = "Database for processed data" }
  ]

  crawlers = {
    "raw_data_crawler" = {
      database_name = "raw_db" # This will be appended with -${var.environment} in the module
      s3_targets    = [{ path = "s3://${module.s3_storage.bucket_ids.raw}/input/" }]
      schedule      = "cron(0 1 * * ? *)" # Daily at 1 AM UTC
    }

    # --- NEW CRAWLER FOR PROCESSED DATA ---
    "processed_data_crawler" = {
      database_name = "processed_db" # Puts table in the processed database
      s3_targets    = [{ path = "s3://${module.s3_storage.bucket_ids.processed}/output/" }] # Points to the output of your ETL job
      schedule      = "cron(0 2 * * ? *)" # Runs an hour after the raw crawler
      configuration = jsonencode({
        Version = 1.0,
        CrawlerOutput = {
          Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
        },
        Grouping = {
          TableGroupingPolicy = "CombineCompatibleSchemas"
        }
      })
    }
  }

  glue_jobs = {
    "sample_etl_job" = {
      script_location   = "s3://${local.glue_assets_bucket_name}/scripts/sample_etl_job.py" # You'll need to upload this script
      glue_version      = "4.0"
      worker_type       = "G.1X"
      number_of_workers = 2
      default_arguments = {
        "--source_database"   = "raw_db-${local.environment_name}"
        "--source_table"      = "input_table" # Example table name
        "--target_s3_path"    = "s3://${module.s3_storage.bucket_ids.processed}/output/"
        "--enable-job-insights" = "true"
      }
    }
  }
}

module "lambda_processing" {
  source = "../../modules/lambda-functions"

  environment                 = local.environment_name
  common_tags                 = local.common_tags
  lambda_execution_role_arn   = module.iam_roles.lambda_execution_role_arn
  lambda_code_s3_bucket       = local.lambda_code_bucket_name # Pass the bucket name

  lambda_functions = {
    "example_lambda_function" = { # This key must match the folder name in modules/lambda-functions/src/
      name_prefix = "s3-processor"
      handler     = "index.handler"
      runtime     = "python3.9"
      timeout     = 120
      memory_size = 512
      environment_variables = {
        TARGET_PROCESSED_BUCKET = module.s3_storage.bucket_ids.processed
        LOG_LEVEL               = "INFO"
      }
      s3_triggers = [
        {
          bucket_id = module.s3_storage.bucket_ids[var.example_lambda_s3_target_bucket_layer]
          events    = ["s3:ObjectCreated:*"]
          filter_prefix = "uploads/"
        }
      ]
    }
  }
}

module "sagemaker_notebooks" {
  source = "../../modules/sagemaker-ml"

  environment            = local.environment_name
  common_tags            = local.common_tags
  sagemaker_execution_role_arn = module.iam_roles.sagemaker_execution_role_arn # Confirm output name from iam_roles
  

  notebook_instances = {
    "data_science_notebook" = {
      # Add the required name_prefix attribute here
      name_prefix = "data-science" # Or choose a suitable prefix
      instance_type = "ml.t3.medium"
      volume_size_in_gb = 50
      # subnet_id = "subnet-xxxxxxxxxxxxxxxxx" # If deploying in VPC
      # security_group_ids = ["sg-xxxxxxxxxxxxxxxxx"] # If deploying in VPC
    }
  }
}