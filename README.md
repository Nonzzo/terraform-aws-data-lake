# AWS Data Lake with Terraform

This repository contains the Terraform code to provision an AWS Data Lake infrastructure, including S3 storage, Glue ETL jobs and crawlers, Lambda functions, and SageMaker notebooks. The infrastructure is deployed across different environments (dev, staging, production) using a modular and environment-specific configuration approach.

## Project Overview

The goal of this project is to establish a scalable and cost-effective data lake on AWS. The pipeline involves:
1.  Ingesting raw data into an S3 bucket.
2.  Crawling the raw data using AWS Glue to discover schema and create tables in the Glue Data Catalog.
3.  Processing the raw data using AWS Glue ETL jobs (e.g., cleaning, transforming, converting formats like CSV to Parquet).
4.  Storing processed data in another S3 bucket.
5.  Crawling the processed data to update the Data Catalog.
6.  Providing access to processed data for analysis (e.g., via SageMaker).

Development typically happens on feature branches, which are merged into the `develop` branch for integration testing in the `dev` environment. Changes are then promoted to `staging` and finally `production`.

## Prerequisites

Before you begin, ensure you have the following installed:

*   [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
*   [Terraform](https://developer.hashicorp.com/terraform/downloads) (Ensure your version matches the `required_version` in `versions.tf`)
*   [AWS CLI](https://aws.amazon.com/cli/)
*   Configured AWS credentials (e.g., via `aws configure` or environment variables) with sufficient permissions to create resources in your target AWS account(s).

## Project Structure

The repository is organized as follows:

*   `./`: Project root, contains main README, license, etc.
*   `./modules/`: Contains reusable Terraform modules for provisioning specific AWS services (S3, IAM, Glue, Lambda, SageMaker).
    *   `./modules/s3-data-lake/`: Module for creating S3 buckets.
    *   `./modules/iam-roles-policies/`: Module for creating IAM roles and policies.
    *   `./modules/glue-etl/`: Module for creating Glue databases, crawlers, jobs, and triggers.
    *   `./modules/lambda-functions/`: Module for creating Lambda functions.
    *   `./modules/sagemaker-ml/`: Module for creating SageMaker resources.
*   `./environments/`: Contains environment-specific configurations.
    *   `./environments/dev/`: Configuration for the development environment. ****
    *   `./environments/staging/`: Configuration for the staging environment.
    *   `./environments/prod/`: Configuration for the production environment.
*   `./.github/workflows/`: Contains GitHub Actions workflow files for CI/CD.
*   `./sample_etl_job.py`: Example Python script for the Glue ETL job.
*   `./versions.tf`: Specifies required Terraform and provider versions.

## Environments

The infrastructure is deployed to different environments, each with its own configuration and deployment process:

*   **Development (Dev):** Used by individual developers or teams for rapid iteration and testing. Typically deployed automatically on pushes to the `develop` branch. See [environments/dev/README.md](./environments/dev/README.md) for details. 
*   **Staging:** Used for integration testing and pre-production validation. Mirrors production setup. See [environments/staging/README.md](./environments/staging/README.md) for details.
*   **Production:** The live environment hosting the production data lake. Deployments are protected by manual gates (e.g., via Branch Protection). See [environments/prod/README.md](./environments/prod/README.md) for details.

## CI/CD

This project uses GitHub Actions for Continuous Integration and Continuous Deployment. Workflows are defined in the `./.github/workflows/` directory.

*   `terraform-ci-cd-dev.yml`: Workflow for deploying to the development environment. **(You would need to create this workflow file)**
*   `terraform-ci-cd-staging.yml`: Workflow for deploying to the staging environment.
*   `terraform-ci-cd-prod.yml`: Workflow for deploying to the production environment.

Refer to the environment-specific READMEs for details on how the CI/CD pipelines work for each environment.

## Getting Started

1.  Clone this repository.
2.  Navigate to the desired environment directory (`environments/dev/`, `environments/staging/`, or `environments/prod/`).
3.  Initialize Terraform: `terraform init` (refer to environment README for backend config).
4.  Review the plan: `terraform plan` (refer to environment README for var file).
5.  Apply the changes: `terraform apply` (refer to environment README and CI/CD for deployment process).

---