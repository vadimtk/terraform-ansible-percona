# Configure the Packet Provider
provider "aws" {
  region     = "us-east-1"
  shared_credentials_file = "/home/vadim/cred"
}

resource "aws_instance" "c5d_9xlarge" {
  ami = "ami-b70554c8"
  instance_type = "c5d.9xlarge"
  availability_zone = "us-east-1a"
  subnet_id = "${aws_subnet.public-subnet.id}"
  associate_public_ip_address=true
  vpc_security_group_ids = ["${aws_security_group.sgdb.id}"]
  key_name="VadimAmazonNorthV"
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test"
    iit-billing-tag = "vadim-perf"
  }
}

resource "aws_instance" "c5d_18xlarge" {
  ami = "ami-b70554c8"
  instance_type = "c5d.18xlarge"
  availability_zone = "us-east-1a"
  subnet_id = "${aws_subnet.public-subnet.id}"
  associate_public_ip_address=true
  vpc_security_group_ids = ["${aws_security_group.sgdb.id}"]
  key_name="VadimAmazonNorthV"
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test"
    iit-billing-tag = "vadim-perf"
  }
}

resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "terraform-aws-vpc"
        deparment = "CTOLab"
    }
}

resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "us-east-1a"

  tags {
        Name = "Public Subnet"
        deparment = "CTOLab"
  }
}


resource "aws_security_group" "sgdb"{
  name = "sg_test_web"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "DB SG"
    deparment = "CTOLab"
  }
}

# Define the route table
resource "aws_route_table" "web-public-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name = "Public Subnet RT"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.default.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public-rt" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.web-public-rt.id}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "VPC IGW"
  }
}
