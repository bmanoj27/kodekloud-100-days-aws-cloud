The following components already exist in the environment:
1) A VPC named devops-priv-vpc and a private subnet named devops-priv-subnet have been created.
2) An EC2 instance named devops-priv-ec2 is already running in the private subnet.
3) The EC2 instance is configured with a cron job that uploads a test file to the S3 bucket devops-nat-3293 every minute. Upload will only succeed once internet access is established.

Task is to:

Create a new public subnet named devops-pub-subnet in the existing VPC.
Launch a NAT Instance in the public subnet using an Amazon Linux 2 AMI and name it devops-nat-instance. Configure this instance to act as a NAT instance. Make sure to use a custom security group for this instance.
After the configuration, verify that the test file devops-test.txt appears in the S3 bucket devops-nat-3293. This indicates successful internet access from the private EC2 instance via the NAT Instance.


Use sed to replace the instance names if needed. Example:

# Find and replace in all files
sed -i 's/devops/nautilus/g' *