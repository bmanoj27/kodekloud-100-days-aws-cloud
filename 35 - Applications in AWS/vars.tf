variable "rds_instance" {
  default = "datacenter-rds"
  type = string
}

variable "db_name" {
  default = "datacenter_db"
  type = string
}

variable "db_user" {
  default = "datacenter_admin"
  type = string
}

variable "db_pass" {
  default = "nimda_sulituan"
  type = string
}

variable "priv_sg_id" {
  type = string
}

######################### DATA ###########################

data "aws_instance" "def_ec2" {
    filter {
      name = "tag:Name"
      values = ["datacenter-ec2"]
    }
}

data "aws_subnet" "subnet_ec2" {
    id = data.aws_instance.def_ec2.subnet_id
}

