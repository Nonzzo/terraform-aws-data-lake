# Staging Environment

This directory contains the Terraform configuration for the **staging** data lake environment. The staging environment is designed to mirror the production setup and is used for testing new features, configurations, and data pipelines before deploying to production.

## Deployment Process

Deployments to the staging environment are automated via GitHub Actions.

*   Changes pushed to the `staging` branch that affect the `modules/` or `environments/staging/` directories will trigger the `Terraform CI/CD (Staging) For Data Lake` workflow (`.github/workflows/terraform-ci-cd-staging.yml`).
*   The workflow will automatically run `terraform init`, `validate`, `plan`, and `apply`.
*   The `apply` step is configured with `-auto-approve` and runs automatically on pushes to the `staging` branch.

## Terraform Backend

The Terraform state for the staging environment is stored in an S3 backend. You will need the bucket and DynamoDB table created for state locking.

To initialize Terraform for staging:

```bash
cd environments/staging/
terraform init \
  -backend-config="bucket=<your-staging-tfstate-bucket-name>" \
  -backend-config="key=staging/terraform.tfstate" \
  -backend-config="region=<your-aws-region>" \
  -backend-config="dynamodb_table=<your-staging-tflock-table-name>"