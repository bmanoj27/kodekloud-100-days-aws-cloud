# Public VPC with EC2 Instance

## Task Overview

Create a public VPC and deploy an EC2 instance with the following specifications:

### Networking
- **VPC Name:** `devops-pub-vpc`
- **Subnet Name:** `devops-pub-subnet`
- Configure the subnet to **auto-assign public IP addresses** to resources launched within it

### EC2 Instance
- **Instance Name:** `devops-pub-ec2`
- Launch the instance inside the `devops-pub-vpc`

### Security
- Ensure **SSH access (port 22)** is allowed
- SSH must be **accessible over the internet**

---
