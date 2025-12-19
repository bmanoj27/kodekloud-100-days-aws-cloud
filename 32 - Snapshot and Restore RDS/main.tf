terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "rds_instance" {
  type = string
  default = "datacenter-rds"   #Replace if needed.
}

variable "snapshot_id" {
  type = string
  default = "datacenter-snapshot"   #Replace if needed.
}

variable "restore_inst" {
  type = string
  default = "datacenter-snapshot-restore"   #Replace if needed.
}

data "aws_db_instance" "datacenter-rds" {
  db_instance_identifier = var.rds_instance
}

#Take Snapshot
resource "aws_db_snapshot" "datacenter-snapshot" {
  db_instance_identifier = data.aws_db_instance.datacenter-rds.id
  db_snapshot_identifier = var.snapshot_id
}


resource "aws_db_instance" "datacenter-snapshot-restore" {
#    db_name = "datacentersnapshot"
    instance_class = "db.t3.micro"
    engine = data.aws_db_instance.datacenter-rds.engine
    engine_version = data.aws_db_instance.datacenter-rds.engine_version
    allocated_storage = data.aws_db_instance.datacenter-rds.allocated_storage
    max_allocated_storage = data.aws_db_instance.datacenter-rds.max_allocated_storage
    identifier = var.restore_inst
    db_subnet_group_name = data.aws_db_instance.datacenter-rds.db_subnet_group
    vpc_security_group_ids = [data.aws_db_instance.datacenter-rds.vpc_security_groups[0]]


    snapshot_identifier = aws_db_snapshot.datacenter-snapshot.id
    tags = {
      Name = var.restore_inst
    }
}