# VPC Peering: Public and Private VPC Connectivity

## Task Overview

The objective of this task is to establish connectivity between an existing public EC2 instance and an existing private EC2 instance by using **VPC Peering**.

---

## Existing Infrastructure

### Public VPC / EC2
- An EC2 instance already exists in the **public VPC/subnet**
- **Instance Name:** `devops-public-ec2`

### Private VPC
- **VPC Name:** `devops-private-vpc`
- **CIDR Block:** `10.1.0.0/16`

### Private Subnet
- **Subnet Name:** `devops-private-subnet`
- **CIDR Block:** `10.1.1.0/24`

### Private EC2
- An EC2 instance already exists in the private subnet
- **Instance Name:** `devops-private-ec2`

---

## Tasks to Perform

### VPC Peering
- Create a VPC peering connection between the **Default VPC** and the **Private VPC**
- **VPC Peering Connection Name:** `devops-vpc-peering`

### Route Table Configuration
- Update route tables in both VPCs to enable communication between them
- Ensure traffic can flow between the public and private subnets

### Security and Access
- Add `/root/.ssh/id_rsa.pub` to the **`ec2-user`** `authorized_keys` file on the public EC2 instance to allow SSH access from the AWS client host
- Update the security group of the **private EC2 instance** to allow **ICMP traffic** from the public/default VPC CIDR

---

## Usage

1. Ensure AWS CLI is configured and Terraform is installed.

2. Verify the following EC2 instances already exist:
   - `nautilus-public-ec2` (in default/public VPC)
   - `nautilus-private-ec2` (in private VPC)

3. Ensure your SSH key exists on the AWS client host:

4. Make the script executable and run it:

    ```bash
    chmod +x vpcpeering.sh
    ./vpcpeering.sh

5. Login to the public ec2 instance using AWS console and copy the ~/.ssh/id_rsa.pub to /home/ec2-user/.ssh/authorized_keys

6. After completion, SSH into the public EC2 instance and verify connectivity by pinging the private EC2 instance.
