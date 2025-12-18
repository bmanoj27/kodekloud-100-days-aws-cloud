#!/bin/bash
set -euo pipefail

if ! command -v aws >/dev/null 2>&1
then
    echo "AWS CLI could not be found. Please install it to run this script."
    echo "https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
    exit 1
fi

if ! aws sts get-caller-identity >/dev/null 2>&1
then
    echo "AWS CLI is not configured. Please configure it to run this script."
    echo "https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html"
    exit 1
fi

# -------------------------------
# Read inputs
# -------------------------------
read -p "Enter IAM Role name (EC2 trust): " ROLE_NAME
read -p "Enter IAM Policy name: " POLICY_NAME

if [[ -z "$ROLE_NAME" || -z "$POLICY_NAME" ]]; then
  echo "Role name and Policy name cannot be empty"
  exit 1
fi

# -------------------------------
# Create trust policy
# -------------------------------
TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
)

# -------------------------------
# Create IAM Role
# -------------------------------
if aws iam get-role --role-name "${ROLE_NAME}" >/dev/null 2>&1; then
  echo "ℹIAM Role '${ROLE_NAME}' already exists. Skipping creation."
else
  aws iam create-role \
    --role-name "${ROLE_NAME}" \
    --assume-role-policy-document "${TRUST_POLICY}"

  echo "IAM Role created: ${ROLE_NAME}"
fi

# -------------------------------
# Create IAM Policy
# -------------------------------
POLICY_DOCUMENT=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeTags"
      ],
      "Resource": "*"
    }
  ]
}
EOF
)

POLICY_ARN=$(aws iam list-policies \
  --scope Local \
  --query "Policies[?PolicyName=='${POLICY_NAME}'].Arn" \
  --output text)

if [[ -z "${POLICY_ARN}" ]]; then
  POLICY_ARN=$(aws iam create-policy \
    --policy-name "${POLICY_NAME}" \
    --policy-document "${POLICY_DOCUMENT}" \
    --query 'Policy.Arn' \
    --output text)

  echo "IAM Policy created: ${POLICY_NAME}"
else
  echo "IAM Policy '${POLICY_NAME}' already exists."
fi

# -------------------------------
# Attach Policy to Role
# -------------------------------
aws iam attach-role-policy \
  --role-name "${ROLE_NAME}" \
  --policy-arn "${POLICY_ARN}"

echo "Policy attached to role successfully"

# -------------------------------
# Optional: Create instance profile
# -------------------------------
if ! aws iam get-instance-profile --instance-profile-name "$ROLE_NAME" >/dev/null 2>&1; then
  aws iam create-instance-profile \
    --instance-profile-name "$ROLE_NAME"

  aws iam add-role-to-instance-profile \
    --instance-profile-name "$ROLE_NAME" \
    --role-name "$ROLE_NAME"

  echo "Instance profile created: $ROLE_NAME"
fi

echo
echo "IAM Role setup complete"
echo "Role   : $ROLE_NAME"
echo "Policy : $POLICY_NAME"
