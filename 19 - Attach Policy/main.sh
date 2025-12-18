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
read -p "Enter IAM Policy name (EC2 trust): " POLICY_NAME
read -p "Enter IAM User Name: " IAM_USER

if [[ -z "$POLICY_NAME" || -z "$IAM_USER" ]]; then
  echo "Policy name and IAM User name cannot be empty"
  exit 1
fi

POLICY_ARN=$(aws iam list-policies --scope Local --query "Policies[?PolicyName=='${POLICY_NAME}']" --output text)

if [[ -z "${POLICY_ARN}" ]]; then
  echo "IAM Policy '${POLICY_NAME}' does not exist. Please create it first."
  exit 1
fi

aws iam attach-user-policy \
  --user-name "${IAM_USER}" \
  --policy-arn "${POLICY_ARN}"

exit 0