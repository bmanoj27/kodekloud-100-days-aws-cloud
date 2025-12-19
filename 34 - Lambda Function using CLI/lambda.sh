#!/bin/bash

mkdir -p /tmp/lambda_aws
cd /tmp/lambda_aws

cat <<EOF > lambda.py
import json

def lambda_handler(event, context):
    # TODO implement
    return {
        'statusCode': 200,
        'body': json.dumps('Welcome to KKE AWS Labs!')
    }
EOF

#cat > trust-policy.json <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Effect": "Allow",
#      "Principal": {
#        "Service": "lambda.amazonaws.com"
#      },
#      "Action": "sts:AssumeRole"
#    }
#  ]
#}
#EOF

zip -r lambda.zip lambda.py

#Create the IAM Role
#The role mostly already exists.
#aws iam create-role --role-name lambda_execution_role --assume-role-policy-document file://trust-policy.json

read -p "Enter the function name to be created: " functionlambda

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws lambda create-function \
  --function-name ${functionlambda} \
  --runtime python3.14 \
  --role arn:aws:iam::${AWS_ACCOUNT_ID}:role/lambda_execution_role \
  --handler lambda.lambda_handler \
  --zip-file fileb://lambda.zip

#TO update code if necessary
#aws lambda update-function-code --function-name ${functionlambda} --zip-file fileb://lambda.zip

#TO delete functiion

#aws lambda delete-function --function-name ${functionlambda}


#Test the function
aws lambda invoke --function-name ${functionlambda}  response.json

cat response.json

