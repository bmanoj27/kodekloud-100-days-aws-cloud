# AWS Security Group creation using Terraform

Create a security group under default VPC with the following requirementes:

Name of the SG is devops-sg

Description: Security group for Nautilus App Servers

Inbound Rule 1: HTTP with port range of 80, Source CIDR 0.0.0.0/0
Inbound Rule 2: SSH with port range of 22, Source CIDR 0.0.0.0/0