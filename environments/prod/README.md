# Production Environment

This directory contains the Terraform configuration for the **production** data lake environment. This is the live environment hosting production data and infrastructure. Deployments to this environment are protected by manual gates to ensure stability and prevent unreviewed changes.

## Deployment Process

Deployments to the production environment are managed via GitHub Actions and protected by **Branch Protection Rules** on the `main` branch.

1.  All changes intended for production must be submitted via a **Pull Request** targeting the `main` branch.
2.  The `Terraform CI/CD (Production) For Data Lake` workflow (`.github/workflows/terraform-ci-cd-prod.yml`) will automatically trigger on the Pull Request.
3.  The workflow will run `terraform init`, `validate`, and `plan`. The plan output will be available for review in the Pull Request checks.
4.  **Required reviewers** must examine the code changes and the Terraform plan output in the Pull Request.
5.  Reviewers must **approve** the Pull Request.
6.  Once approved and all required status checks pass, the Pull Request can be **merged** into the `main` branch.
7.  Merging into `main` triggers the `Terraform CI/CD (Production) For Data Lake` workflow again.
8.  This time, the `apply` step (which is conditional on pushes to `main`) will execute, applying the planned changes to the production AWS account.

This Pull Request and approval process serves as the manual gate for production deployments.

## Terraform Backend

The Terraform state for the production environment is stored in an S3 backend. It uses a separate state file key from staging.

To initialize Terraform for production:

```bash
cd environments/prod/
terraform init \
  -backend-config="bucket=<your-production-tfstate-bucket-name>" \
  -backend-config="key=prod/terraform.tfstate" \
  -backend-config="region=<your-aws-region>" \
  -backend-config="dynamodb_table=<your-production-tflock-table-name>"