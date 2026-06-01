# --------------------------------------------------
# AWS Provider
# --------------------------------------------------
provider "aws" {
  region  = "eu-north-1"
  profile = "terraform-dev"
}

# --------------------------------------------------
# VPC
# --------------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name        = var.vpc_name
    Environment = "project2_environment"
    Terraform   = "true"
  }
}

# --------------------------------------------------
# Availability Zones
# --------------------------------------------------
data "aws_availability_zones" "available_zones" {
  state = "available"
}

# --------------------------------------------------
# Public Subnet
# --------------------------------------------------
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name      = "project_public_subnet"
    Terraform = "true"
  }
}

# --------------------------------------------------
# Internet Gateway
# --------------------------------------------------
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "project_igw"
  }
}

# --------------------------------------------------
# Route Table
# --------------------------------------------------
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name      = "project_public_rtb"
    Terraform = "true"
  }
}

# --------------------------------------------------
# Route Table Association
# --------------------------------------------------
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# --------------------------------------------------
# Security Group
# --------------------------------------------------
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Security Group for Jenkins"
  vpc_id      = aws_vpc.vpc.id

  # Jenkins
  ingress {
    description = "Allow Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    # للتدريب فقط
    cidr_blocks = ["0.0.0.0/0"]

    # للإنتاج استبدلها بـ:
    # cidr_blocks = ["YOUR_PUBLIC_IP/32"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tutorial_jenkins_sg"
  }
}

# --------------------------------------------------
# SSH Key Pair
# --------------------------------------------------
resource "aws_key_pair" "mykey_ssh" {
  key_name   = "MyKey"
  public_key = file("~/.ssh/ubuntu-aws.pub")
}

# --------------------------------------------------
# Ubuntu AMI
# --------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --------------------------------------------------
# Jenkins EC2 Instance
# --------------------------------------------------
resource "aws_instance" "jenkins_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  key_name = aws_key_pair.mykey_ssh.key_name

  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  # user_data = file("${path.module}/jen.sh")
 provisioner "remote-exec" {
  script = "${path.module}/jen.sh"
}
 connection {
    type        = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/ubuntu-aws")
    host        = self.public_ip
 }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "Jenkins_Instance"
  }
}

# --------------------------------------------------
# Elastic IP
# --------------------------------------------------
resource "aws_eip" "jenkins_eip" {
  domain = "vpc"

  tags = {
    Name = "jenkins_eip"
  }
}

# --------------------------------------------------
# Associate Elastic IP
# --------------------------------------------------
resource "aws_eip_association" "jenkins_eip_assoc" {
  instance_id   = aws_instance.jenkins_instance.id
  allocation_id = aws_eip.jenkins_eip.id
}