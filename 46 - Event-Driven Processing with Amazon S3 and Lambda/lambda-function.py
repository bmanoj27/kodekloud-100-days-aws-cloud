import json
import boto3
from datetime import datetime
import uuid

# Initialize the S3 and DynamoDB clients
s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('REPLACE-WITH-YOUR-DYNAMODB-TABLE')

def lambda_handler(event, context):
    try:
        # Get the source bucket and object key from the event
        source_bucket = event['Records'][0]['s3']['bucket']['name']
        object_key = event['Records'][0]['s3']['object']['key']

        # Hardcoded destination bucket name
        destination_bucket = "REPLACE-WITH-YOUR-PRIVATE-BUCKET"

        # Log the event details for debugging
        print(f"[INFO] Source bucket: {source_bucket}, Object key: {object_key}")
        print(f"[INFO] Destination bucket: {destination_bucket}")

        # Copy the file from source bucket to destination bucket
        copy_source = {
            'Bucket': source_bucket,
            'Key': object_key
        }

        print(f"[INFO] Attempting to copy object from {source_bucket}/{object_key} to {destination_bucket}/{object_key}")
        s3.copy_object(
            CopySource=copy_source,
            Bucket=destination_bucket,
            Key=object_key
        )
        print(f"[INFO] File successfully copied from {source_bucket}/{object_key} to {destination_bucket}/{object_key}")

        # Create log entry for DynamoDB
        log_entry = {
            'LogID': str(uuid.uuid4()),  # Generate a unique ID for the log entry
            'SourceBucket': source_bucket,
            'DestinationBucket': destination_bucket,
            'ObjectKey': object_key,
            'Timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'Status': 'Success'
        }

        # Log the log entry before attempting to write to DynamoDB
        print(f"[INFO] Writing the following log entry to DynamoDB:\n{json.dumps(log_entry, indent=4)}")
        table.put_item(Item=log_entry)
        print(f"[INFO] Successfully wrote log entry to DynamoDB")

        return {
            'statusCode': 200,
            'body': json.dumps(f"File successfully copied to {destination_bucket}")
        }

    except Exception as e:
        # Store error log in DynamoDB in case of failure
        log_entry = {
            'LogID': str(uuid.uuid4()),  # Generate a unique ID for the log entry
            'SourceBucket': source_bucket,
            'DestinationBucket': destination_bucket,
            'ObjectKey': object_key,
            'Timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            'Status': 'Failure',
            'Error': str(e)
        }

        # Log the error log entry before attempting to write to DynamoDB
        print(f"[ERROR] Writing the following error log entry to DynamoDB:\n{json.dumps(log_entry, indent=4)}")
        try:
            table.put_item(Item=log_entry)
            print(f"[INFO] Successfully wrote error log entry to DynamoDB")
        except Exception as db_error:
            print(f"[ERROR] Failed to write error log entry to DynamoDB: {str(db_error)}")

        # Log the error in CloudWatch
        print(f"[ERROR] Error during file copy or DynamoDB operation: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error copying file: {str(e)}")
        }