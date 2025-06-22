import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

# Get job arguments
args = getResolvedOptions(sys.argv, [
    'JOB_NAME',
    'source_database',
    'source_table',
    'target_s3_path'
])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Source database and table from job parameters
source_database = args['source_database']
source_table = args['source_table']

# Target S3 path from job parameters
target_path = args['target_s3_path']

# Create a DynamicFrame from the Glue Data Catalog
datasource0 = glueContext.create_dynamic_frame.from_catalog(
    database=source_database,
    table_name=source_table,
    transformation_ctx="datasource0"
)

print(f"Schema for {source_table}:")
datasource0.printSchema()
print(f"Count of records read: {datasource0.count()}")

# Example Transformation: Change a column name (optional)
# mapped_frame = ApplyMapping.apply(
#     frame=datasource0,
#     mappings=[
#         ("user_id", "long", "user_identifier", "long"),
#         ("first_name", "string", "first_name", "string"),
#         ("last_name", "string", "last_name", "string"),
#         ("email", "string", "email_address", "string"),
#         ("registration_date", "string", "reg_date", "string")
#     ],
#     transformation_ctx="mapped_frame"
# )

# Write the DynamicFrame to the target S3 path in Parquet format
# The 'partitionKeys' parameter is very useful for large datasets to improve query performance.
# For this example, we are not partitioning.
glueContext.write_dynamic_frame.from_options(
    frame=datasource0, # Use mapped_frame if you did the transformation
    connection_type="s3",
    connection_options={"path": target_path},
    format="parquet",
    transformation_ctx="datasink0"
)

job.commit()