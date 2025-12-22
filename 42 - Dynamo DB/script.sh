#!/bin/bash

aws dynamodb create-table \
  --table-name xfusion-tasks \
  --attribute-definitions \
    AttributeName=taskId,AttributeType=S \
  --key-schema \
    AttributeName=taskId,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

sleep 30

aws dynamodb describe-table \
  --table-name xfusion-tasks \
  --query "Table.TableStatus"

sleep 5

aws dynamodb put-item \
  --table-name xfusion-tasks \
  --item '{
    "taskId": {"S": "1"},
    "description": {"S": "Learn DynamoDB"},
    "status": {"S": "completed"}
  }'

aws dynamodb put-item \
  --table-name xfusion-tasks \
  --item '{
    "taskId": {"S": "2"},
    "description": {"S": "Build To-Do App"},
    "status": {"S": "in-progress"}
  }'



aws dynamodb get-item \
  --table-name xfusion-tasks \
  --key '{"taskId":{"S":"1"}}' \
  --query "Item.status.S"


aws dynamodb get-item \
  --table-name xfusion-tasks \
  --key '{"taskId":{"S":"2"}}' \
  --query "Item.status.S"

aws dynamodb scan --table-name xfusion-tasks
