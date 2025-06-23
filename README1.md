# AWS Data Lake Automation with Terraform

This project deploys a scalable data lake architecture on AWS using Terraform.
It includes S3 buckets for data storage, AWS Glue for data cataloging and ETL,
AWS Lambda for orchestration, and Amazon SageMaker for data analysis and machine learning.

## Goals

* Automate the deployment of a common data lake infrastructure.
* Reduce manual setup time, allowing data teams to focus on insights.
* Provide a modular and customizable foundation.

## Prerequisites

* [Terraform](https://www.terraform.io/downloads.html) (e.g., v1.0.0+)
* [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials and region.
* An S3 bucket for Terraform remote state backend (recommended for team collaboration).
* (Optional) `zip` command-line tool for packaging Lambda functions.

## Architecture Overview



* **S3 Buckets**:
    * `raw-data-bucket`: For ingesting raw data.
    * `processed-data-bucket`: For storing transformed/processed data.
    * `curated-data-bucket`: For data ready for analytics/ML.
    * `logs-bucket`: For access logs, Glue job logs, etc.
    * `artifacts-bucket`: For Lambda code, Glue scripts, SageMaker notebooks/models.
* **AWS Glue**:
    * `data_lake_catalog`: A Glue Data Catalog database.
    * `raw_data_crawler`: A Glue Crawler to scan the `raw-data-bucket` and populate the catalog.
    * (Placeholder for Glue Jobs)
* **AWS Lambda**:
    * `s3_trigger_glue_crawler_lambda`: A Lambda function triggered by new objects in the `raw-data-bucket` to start the `raw_data_crawler`.
* **Amazon SageMaker**:
    * `data_analyst_notebook`: A SageMaker notebook instance for data exploration.
* **IAM Roles & Policies**:
    * Specific roles for Glue, Lambda, and SageMaker to access necessary resources securely.

## Project Structure



## Setup & Deployment

1.  **Clone the repository:**
    ```bash
    
    ```

2.  **Configure Terraform Backend (Optional but Recommended):**
    Update `main.tf` or create a `backend.tf` file with your S3 backend configuration.
    ```terraform
    
    ```

3.  **Prepare Variables:**
    Copy `terraform.tfvars.example` to `terraform.tfvars` and customize the variables.
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    nano terraform.tfvars # Edit the file with your values
    ```

4.  **Package Lambda Function:**
    If you have custom Lambda code, navigate to the Lambda source directory and zip it.
    This example provides a script.
    ```bash
    # Ensure the script is executable: chmod +x scripts/package_lambda.sh
    ./scripts/package_lambda.sh
    ```
    

5.  **Initialize Terraform:**
    ```bash
    terraform init
    ```

6.  **Review the Plan:**
    ```bash
    terraform plan
    ```

7.  **Apply the Configuration:**
    ```bash
    terraform apply
    ```
    Type `yes` when prompted.

## Usage

* Upload data to the raw S3 bucket.
* Verify the Lambda function triggers the Glue crawler.
* Check the Glue Data Catalog for new tables.
* Access the SageMaker Notebook instance for data analysis.

## Cleanup

To destroy all resources created by this Terraform configuration:
```bash
terraform destroy


```markdown


Glue Workflow
The data processing pipeline in production is orchestrated by the Glue Workflow named data-lake-pipeline-prod. This workflow is triggered by the start-data-lake-pipeline-prod On-Demand trigger.

The workflow consists of the following steps:

raw_data_crawler-prod (triggered by the On-Demand trigger)
sample_etl_job-prod (triggered conditionally after raw_data_crawler-prod succeeds)
processed_data_crawler-prod (triggered conditionally after sample_etl_job-prod succeeds)
Manually Running the Workflow (Use with Caution in Prod)
While possible, manually triggering the workflow in production should be done with caution and potentially only for specific operational needs.

Navigate to the AWS Glue console for your production account.
In the left navigation pane, under ETL, click on Workflows.
Find and select the workflow named data-lake-pipeline-prod.
Click the Run workflow button.
Monitor the workflow run progress on the "History" or "Graph" tab.

Resources
Key AWS resources provisioned in this environment include:

S3 Buckets: datalake-raw-prod, datalake-processed-prod, etc.
Glue Database: raw_db-prod, processed_db-prod
Glue Crawlers: raw_data_crawler-prod, processed_data_crawler-prod
Glue Job: sample_etl_job-prod
Glue Workflow: data-lake-pipeline-prod
Glue Triggers: start-data-lake-pipeline-prod, etl-on-raw-crawl-success-prod, processed-crawl-on-etl-success-prod
IAM Roles: glue-datalake-prod, lambda-datalake-prod, sagemaker-datalake-prod
Lambda Functions: s3-processor-prod
SageMaker Notebook Instances: data-science-prod