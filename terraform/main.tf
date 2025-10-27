terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = var.aws_region
}
#VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc-vijaya"
  }
}
# Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "main-igw-vijaya"
    } 
}
#Public Subnet
resource "aws_subnet" "public"{
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr
    map_public_ip_on_launch = true
    availability_zone = "${var.aws_region}a"
    tags = {
        Name = "public-subnet-vijaya"
    }
}
#Private Subnet 
resource "aws_subnet" "private"{
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_subnet_cidr
    availability_zone = "${var.aws_region}a"
    tags = {
        Name = "private-subnet-vijaya"
    }
}
#RT for public subnet
resource "aws_route_table" "public"{
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "public-rt-vijaya"
    }
}
#Associate public subnet with Route Table 
resource "aws_route_table_association" "public"{
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}
# Security Group for load Balancer
resource "aws_security_group" "lb_sg"{
    name = "lb-sg-vijaya-mini"
    description = "security group for lb"
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "lb-sg-vijaya-mini"
    }
}
#Security Group for Bastion 
resource "aws_security_group" "bastion_sg" {
    name = "bastion-sg-mini-vijaya"
    description = "Security group for bastion"
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "bastion-sg-mini-vijaya"
    }
  
}

# Allow SSH from Bastion to Load Balancer
resource "aws_security_group_rule" "allow_ssh_from_bastion_to_lb" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id        = aws_security_group.lb_sg.id
  description              = "Allow SSH from Bastion host to Load Balancer"
}

#Security Group for Private Instanceste
resource "aws_security_group" "private_sg"{
    name = "private-sg-mini-vijaya"
    description = "Security group for private instances"
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [aws_security_group.bastion_sg.id]
    }

    ingress  {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.lb_sg.id]

    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
      Name = "private-sg-vijaya-mini"
    }
}
#Load Balance Instance 
resource "aws_instance" "load_balancer"{
    ami = var.ami
    instance_type = var.instance_type
    subnet_id = aws_subnet.public.id
    key_name = var.key_name
    vpc_security_group_ids = [aws_security_group.lb_sg.id]
    tags = {
        Name = "nginx-lb-mini-vijaya"
    }
    user_data = <<-EOF
                #!/bin/bash
                apt update -y
                apt install -y nginx
                systemctl start nginx
                systemctl enable nginx
                EOF

}
#Bastion Host
resource "aws_instance" "bastion"{
    count = var.enable_bastion ? 1 : 0
    ami = var.ami
    instance_type = var.instance_type
    subnet_id = aws_subnet.public.id
    key_name = var.key_name
    vpc_security_group_ids = [aws_security_group.bastion_sg.id]
    tags = {
        Name = "bastion-host-vijaya-mini"  
    }

}
#Frontend Instance
resource "aws_instance" "frontend" {
    ami = var.ami
    instance_type = var.instance_type
    subnet_id = aws_subnet.private.id
    vpc_security_group_ids = [aws_security_group.private_sg.id]
    key_name = var.key_name
    tags = {
      Name = "frontend-app-vijaya"
    } 
}
#Backend Instance
resource "aws_instance" "backend" {
    count = 3
    ami = var.ami
    instance_type = var.instance_type
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.private_sg.id]
    key_name = var.key_name
    tags = {
      Name = "backend-app-${count.index +1}"
    }
  
}