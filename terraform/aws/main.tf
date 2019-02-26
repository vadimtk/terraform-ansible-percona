# Configure the Packet Provider
provider "aws" {
  region     = "${var.region}"
  shared_credentials_file = "/home/vadim/keys/amazon/cred"
}

data "aws_route53_zone" "vadimtk" {
  # name         = "aws.vadimtk.one."
  zone_id = "ZTU30Y1XQXYAG"
  private_zone = false
}


resource "aws_ebs_volume" "volume_innodb1" {
  availability_zone = "${var.region}a"
  size = 3400
  type = "gp2"
  iops = 10000
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test-innodb-3K"
    iit-billing-tag = "vadim-perf"
  }
}


resource "aws_ebs_volume" "backup" {
  availability_zone = "${var.region}a"
  size = 1000
  type = "gp2"
  iops = 10000
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
  availability_zone = "${var.region}a"

  tags {
     Name = "Vadim Public Subnet"
     deparment = "CTOLab"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}b"

  tags {
     Name = "Vadim Private Subnet"
     deparment = "CTOLab"
  }
}


resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = ["${aws_subnet.public-subnet.id}", "${aws_subnet.private-subnet.id}"]

  tags {
    Name = "Vadim DB subnet group"
  }
}


resource "aws_security_group" "sgdb"{
  name = "sg_test_web"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["${var.public_subnet_cidr}","10.0.1.0/24"]
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

  ingress {
    from_port = 80
    to_port = 80
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
