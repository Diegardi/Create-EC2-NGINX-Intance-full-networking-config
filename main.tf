# Specify the provider and the AWS region 
# IF USING ~/.aws/config it is not necessary to include this provider block

provider "aws" {
  region = "us-east-1"  # > aws configure get region <  to check CURRENT REGION usin CLI  > cat ~/.aws/config < TO CHECK ALL CONFIGS
}

# Specify a new vpc for the ec2 instance, this will setup a new VPC with the cidr block 10.0.0.0/16
resource "aws_vpc" "ec2lab_custom_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "EC2 Lab Custom VPC"
  }
}

# create subnets for different parts of the infrastructure
# PUBLIC SUBNET
resource "aws_subnet" "ec2lab_public_subnet" {
  vpc_id            = aws_vpc.ec2lab_custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "EC2 LAB Public Subnet"
  }
}

# PRIVATE SUBNET
resource "aws_subnet" "ec2lab_private_subnet" {
  vpc_id            = aws_vpc.ec2lab_custom_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "EC2 LAB Private Subnet"
  }
}

# Attach an internet gateway to the VPC
resource "aws_internet_gateway" "ec2lab_ig" {
  vpc_id = aws_vpc.ec2lab_custom_vpc.id

  tags = {
    Name = "EC2LAB Internet Gateway"
  }
}

# Create a route table for a public subnet
resource "aws_route_table" "ec2lab_public_rt" {
  vpc_id = aws_vpc.ec2lab_custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ec2lab_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.ec2lab_ig.id
  }

  tags = {
    Name = "EC2LAB Public Route Table"
  }
}

# This will create a new route table on the custom vpc.
# We can also specify the routes to route internet traffic through the gateway.
resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.ec2lab_public_subnet.id
  route_table_id = aws_route_table.ec2lab_public_rt.id
}

# Create security groups to allow specific traffic
# Before we setup a new EC2 instance on the public subnet,
# we need to create a security group that allows internet traffic on port 80 and 22.
# We’ll also allow outgoing traffic on all ports.
resource "aws_security_group" "ec2lab_web_sg" {
  name   = "HTTP and SSH"
  vpc_id = aws_vpc.ec2lab_custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create ec2 instances on the subnets
# Time to deploy an EC2 instance. If you already have an ssh keypair setup,
# you can just use that and skip the next step. If you haven’t,
# or if you want to setup a new ssh key for this instance,
# run the following command using the aws cli.

# aws ec2 create-key-pair --key-name EC2LAB_key --query 'KeyMaterial' --output text > ~/.ssh/EC2LAB_key.pem
# chmod 400  ~/.ssh/EC2LAB_key.pem

# This will generate a new keypair and store the private key on your machine at ~/.ssh/MyKeyPair.pem

## EC2 INSTANCE ##
# Create ec2 instances on the subnets #
resource "aws_instance" "web_instance" {
  ami           = "ami-0b0dcb5067f052a63"  #Amazon Linux (amzn2-ami-kernel-5.10-hvm-2.0.20221103.3-x86_64-gp2)
  instance_type = "t2.micro"
  key_name      = "dg_ec2lab_keys"

  subnet_id                   = aws_subnet.ec2lab_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ec2lab_web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
  #!/bin/bash -ex
  amazon-linux-extras install nginx1 -y
  echo "<h1>Hello from EC2 LAB Machine!</h1>" >  /usr/share/nginx/html/index.html
  systemctl enable nginx
  systemctl start nginx
  EOF

  tags = {
    "Name" : "EC2 LAB WEBSERVER"
  }
}
