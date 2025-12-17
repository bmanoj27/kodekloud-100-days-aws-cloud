#!/usr/bin/env bash
set -xe

# Usage: ./sync-s3-data.sh <source-bucket> <dest-bucket> [<region>]

SRC_BUCKET="$1"
DEST_BUCKET="$2"
REGION="${3:-us-east-1}"

if [[ -z "${SRC_BUCKET}" || -z "${DEST_BUCKET}" ]]; then
  echo "Usage: $0 <source-bucket> <dest-bucket> [region]"
  exit 1
fi

if [[ ! $(aws s3 ls s3://${DEST_BUCKET} 2>/dev/null) ]]; then
  echo "Bucket s3://${DEST_BUCKET} does not exist. Creating..."
  aws s3 mb s3://${DEST_BUCKET}
else
  echo "Bucket s3://${DEST_BUCKET} already exists."
  exit 1
fi

echo "Syncing from s3://${SRC_BUCKET} to s3://${DEST_BUCKET} in region ${REGION}..."

aws s3 sync "s3://${SRC_BUCKET}" "s3://${DEST_BUCKET}" --region "${REGION}"

echo "Sync completed."
