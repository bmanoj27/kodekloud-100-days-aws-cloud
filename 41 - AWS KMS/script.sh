#!/bin/bash
cd /tmp

IAMACC=$(aws sts get-caller-identity --query "Account" --output text)
IAMUSR=$(aws sts get-caller-identity --query "Arn" --output text)

cat <<EOF >kms-key-policy.json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Enable IAM User Permissions",
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::${IAMACC}:root"
			},
			"Action": "kms:*",
			"Resource": "*"
		},
		{
			"Sid": "Allow use of the key",
			"Effect": "Allow",
			"Principal": {
				"AWS": "${IAMUSR}"
			},
			"Action": [
				"kms:Encrypt",
				"kms:Decrypt",
				"kms:ReEncrypt*",
				"kms:GenerateDataKey*",
				"kms:DescribeKey"
			],
			"Resource": "*"
		},
		{
			"Sid": "Allow attachment of persistent resources",
			"Effect": "Allow",
			"Principal": {
				"AWS": "${IAMUSR}"
			},
			"Action": [
				"kms:CreateGrant",
				"kms:ListGrants",
				"kms:RevokeGrant"
			],
			"Resource": "*",
			"Condition": {
				"Bool": {
					"kms:GrantIsForAWSResource": "true"
				}
			}
		},
		{
			"Sid": "Allow access for Key Administrators",
			"Effect": "Allow",
			"Principal": {
				"AWS": "${IAMUSR}"
			},
			"Action": [
				"kms:Create*",
				"kms:Describe*",
				"kms:Enable*",
				"kms:List*",
				"kms:Put*",
				"kms:Update*",
				"kms:Revoke*",
				"kms:Disable*",
				"kms:Get*",
				"kms:Delete*",
				"kms:TagResource",
				"kms:UntagResource",
				"kms:ScheduleKeyDeletion",
				"kms:CancelKeyDeletion",
				"kms:RotateKeyOnDemand"
			],
			"Resource": "*"
		}
	]
}
EOF

KEY_ID=$(aws kms create-key --description "xfusion-KMS-Key for encryption and decryption" --policy file://kms-key-policy.json --key-usage ENCRYPT_DECRYPT --origin AWS_KMS --query "KeyMetadata.KeyId" --output text)

aws kms create-alias  --alias-name alias/xfusion-KMS-Key --target-key-id ${KEY_ID}


aws kms encrypt \
  --key-id alias/xfusion-KMS-Key \
  --plaintext fileb:///root/SensitiveData.txt \
  --output text \
  --query CiphertextBlob | base64 --decode > /root/EncryptedData.bin

#Optional: To Decrypt the data
aws kms decrypt \
  --ciphertext-blob fileb:///root/EncryptedData.bin \
  --output text \
  --query Plaintext | base64 --decode > /root/DecryptedData.txt
