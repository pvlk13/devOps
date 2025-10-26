variable "aws_region"{
    description = "AWS region"
    type = string
    default = "us-west-2"
}
variable "vpc_cidr"{
    description = "VPC CIDR"
    type = string
    default = "10.0.0.0/16"
}
variable "public_subnet_cidr"{
    description = "Public subnet CIDR"
    type = string
    default = "10.0.1.0/24"
}
variable "private_subnet_cidr"{
    description = "Private Subnet CIDR"
    type = string
    default = "10.0.2.0/24"
}
variable "enable_bastion"{
    description = "Enable/disable bastion host"
    type = bool
    default = true
}
variable "key_name"{
    description = "SSH key pair name"
    type = string
    default = "vijaya-key-cloudwatch"
}
variable "instance_type" {
    description = "EC2 instance type"
    type = string
    default = "t2.micro"
  
}
variable "ami" {
  description = "ami value"
  type = string
  default = "ami-03aa99ddf5498ceb9"
}