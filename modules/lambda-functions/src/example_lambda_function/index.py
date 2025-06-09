import json
import os
import boto3

# Example: Environment variable for a target S3 bucket
# TARGET_BUCKET = os.environ.get('TARGET_BUCKET')
# s3_client = boto3.client('s3')

def handler(event, context):
    """
    Example Lambda function.
    This function logs the received event and context.
    """
    print("Received event: " + json.dumps(event, indent=2))
    print("Received context: " + str(context))

    # Example: Processing an S3 event
    # if 'Records' in event and event['Records'][0]['eventSource'] == 'aws:s3':
    #     try:
    #         bucket_name = event['Records'][0]['s3']['bucket']['name']
    #         object_key = event['Records'][0]['s3']['object']['key']
    #         print(f"Processing S3 object: s3://{bucket_name}/{object_key}")

    #         # Example: Get the object from source S3
    #         # response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
    #         # file_content = response['Body'].read().decode('utf-8')
    #         # print(f"File content: {file_content[:100]}...") # Print first 100 chars

    #         # Example: Put processed object to another S3 bucket
    #         # if TARGET_BUCKET:
    #         #     processed_key = f"processed/{object_key}"
    #         #     s3_client.put_object(Bucket=TARGET_BUCKET, Key=processed_key, Body=f"Processed: {file_content}")
    #         #     print(f"Successfully processed and moved to s3://{TARGET_BUCKET}/{processed_key}")
    #         # else:
    #         #     print("TARGET_BUCKET environment variable not set.")

    #         return {
    #             'statusCode': 200,
    #             'body': json.dumps(f'Successfully processed S3 object: s3://{bucket_name}/{object_key}')
    #         }
    #     except Exception as e:
    #         print(f"Error processing S3 event: {e}")
    #         return {
    #             'statusCode': 500,
    #             'body': json.dumps(f'Error processing S3 event: {e}')
    #         }

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda! Event and context logged.')
    }