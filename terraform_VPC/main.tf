terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.69.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-southeast-1"
}


resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "IGW-tf"
  }
}

resource "aws_subnet" "my_public_subnet" {
 vpc_id = aws_vpc.my_vpc.id
 cidr_block = "10.0.1.0/24"
 map_public_ip_on_launch = true
 availability_zone = "ap-southeast-1a"
 tags = {
   Name = "public-subnet"
 }
}

resource "aws_route_table" "my_public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "public-RTB"
  }
}

resource "aws_route_table_association" "public_rtb_assoc" {
  subnet_id = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.my_public_route_table.id
}

resource "aws_security_group" "my_ec2_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    Name = "ec2-sg"
  }
}

#key-pair = web01
resource "aws_instance" "web01" {
  ami = "ami-047126e50991d067b"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.my_public_subnet.id
  vpc_security_group_ids = [aws_security_group.my_ec2_sg.id]
  associate_public_ip_address = true
  key_name = "web01"

  user_data = file("script.sh")
  tags = {
    Name = "apache-server"
  }
  
}