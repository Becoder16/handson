terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "devsecopsterralearning"
    key    = "state.tf"
    region = "us-east-1"
  }
}


# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
resource "aws_vpc" "Devsecops-vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = "true"
  tags = {
    Name = "Devsecops-vpc"
  }
lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "Devsecops-subnet" {
  vpc_id     = aws_vpc.Devsecops-vpc.id
  cidr_block = "${var.subnet_cidr}"
  availability_zone = "${var.az}"

  tags = {
    Name = "Devsecops-subnet"
  }
lifecycle {
    create_before_destroy = true
  }

}

resource "aws_internet_gateway" "Devsecops-igw" {
  vpc_id = aws_vpc.Devsecops-vpc.id

  tags = {
    Name = "Devsecops-igw"
  }
lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "Devsecops-rt" {
  vpc_id = aws_vpc.Devsecops-vpc.id

  route {
    cidr_block = "${var.rt_cidr}"
    gateway_id = aws_internet_gateway.Devsecops-igw.id
  }

  tags = {
    Name = "Devsecops-rt"
  }
lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route_table_association" "Devsecops-rta" {
  subnet_id      = aws_subnet.Devsecops-subnet.id
  route_table_id = aws_route_table.Devsecops-rt.id
}


resource "aws_security_group" "Devsecops-sg" {
  name   = "web"
  vpc_id = aws_vpc.Devsecops-vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Devsecops-sg"
  }
lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "Server-1" {
     ami = "${var.ami}"
     availability_zone = "${var.az}"
     instance_type = "${var.instance_type}"
     key_name = "${var.key_pair}"
     subnet_id = "${aws_subnet.Devsecops-subnet.id}"
     vpc_security_group_ids = ["${aws_security_group.Devsecops-sg.id}"]
     associate_public_ip_address = true	
     tags = {
         Name = "Server-1"
         Env = "Test"
     }
lifecycle {
    create_before_destroy = true
  }
}

