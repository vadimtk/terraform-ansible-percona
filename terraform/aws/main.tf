# Configure the Packet Provider
provider "aws" {
  region     = "us-east-1"
  shared_credentials_file = "/home/vadim/cred"
}

resource "aws_instance" "box" {
  ami = "ami-b70554c8"
  instance_type = "c5d.4xlarge"
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

resource "aws_spot_instance_request" "box1" {
  ami = "ami-b70554c8"
  instance_type = "c5.9xlarge"
  availability_zone = "us-east-1a"
  subnet_id = "${aws_subnet.public-subnet.id}"
  associate_public_ip_address=true
  vpc_security_group_ids = ["${aws_security_group.sgdb.id}"]
  key_name="VadimAmazonNorthV"
  wait_for_fulfillment = true
  spot_type = "one-time"
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test"
    iit-billing-tag = "vadim-perf"
  }
  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${aws_spot_instance_request.box1.spot_instance_id} --tags Key=Name,Value=Vadim-test-innodb1 Key=iit-billing-tag,Value=vadim-perf"

    environment {
      AWS_ACCESS_KEY_ID = "${var.aws_access_key}"
      AWS_SECRET_ACCESS_KEY = "${var.aws_secret_key}"
      AWS_DEFAULT_REGION = "us-east-1"
    }
  }

}

output "ip-box1" {
  value = "${aws_spot_instance_request.box1.public_ip}"
}


data "aws_route53_zone" "vtk" {
  name         = "aws.vtk.one."
  private_zone = false
}

resource "aws_route53_record" "b2" {
  zone_id = "${data.aws_route53_zone.vtk.zone_id}"
  name    = "b2.${data.aws_route53_zone.vtk.name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.box_rocksdb.public_ip}"]
}

resource "aws_instance" "box_rocksdb" {
  ami = "ami-b70554c8"
  instance_type = "c5.9xlarge"
  availability_zone = "us-east-1a"
  subnet_id = "${aws_subnet.public-subnet.id}"
  associate_public_ip_address=true
  vpc_security_group_ids = ["${aws_security_group.sgdb.id}"]
  key_name="VadimAmazonNorthV"
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test-rocksdb"
    iit-billing-tag = "vadim-perf"
  }
}

resource "aws_spot_instance_request" "box_innodb" {
  ami = "ami-b70554c8"
  instance_type = "c5.9xlarge"
  availability_zone = "us-east-1a"
  subnet_id = "${aws_subnet.public-subnet.id}"
  associate_public_ip_address=true
  vpc_security_group_ids = ["${aws_security_group.sgdb.id}"]
  key_name="VadimAmazonNorthV"
  wait_for_fulfillment = true
  spot_type = "one-time"
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test"
    iit-billing-tag = "vadim-perf"
  }
  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${aws_spot_instance_request.box_innodb.spot_instance_id} --tags Key=Name,Value=Vadim-test-innodb Key=iit-billing-tag,Value=vadim-perf"

    environment {
      AWS_ACCESS_KEY_ID = "${var.aws_access_key}"
      AWS_SECRET_ACCESS_KEY = "${var.aws_secret_key}"
      AWS_DEFAULT_REGION = "us-east-1"
    }
  }

}

resource "aws_route53_record" "box_innodb" {
  zone_id = "${data.aws_route53_zone.vtk.zone_id}"
  name    = "box_innodb.${data.aws_route53_zone.vtk.name}"
  type    = "A"
  ttl     = "10"
  records = ["${aws_spot_instance_request.box_innodb.public_ip}"]
}

resource "aws_spot_instance_request" "box_client" {
  ami = "ami-b70554c8"
  instance_type = "c5.9xlarge"
  availability_zone = "us-east-1a"
  subnet_id = "${aws_subnet.public-subnet.id}"
  associate_public_ip_address=true
  vpc_security_group_ids = ["${aws_security_group.sgdb.id}"]
  key_name="VadimAmazonNorthV"
  wait_for_fulfillment = true
  spot_type = "one-time"
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test"
    iit-billing-tag = "vadim-perf"
  }
  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${aws_spot_instance_request.box_client.spot_instance_id} --tags Key=Name,Value=Vadim-test-client Key=iit-billing-tag,Value=vadim-perf"

    environment {
      AWS_ACCESS_KEY_ID = "${var.aws_access_key}"
      AWS_SECRET_ACCESS_KEY = "${var.aws_secret_key}"
      AWS_DEFAULT_REGION = "us-east-1"
    }
  }

}

resource "aws_route53_record" "box_client" {
  zone_id = "${data.aws_route53_zone.vtk.zone_id}"
  name    = "box_client.${data.aws_route53_zone.vtk.name}"
  type    = "A"
  ttl     = "10"
  records = ["${aws_spot_instance_request.box_client.public_ip}"]
}

output "ip-rocksdb" {
  value = "${aws_instance.box_rocksdb.public_ip}"
}
output "ip-innodb" {
  value = "${aws_spot_instance_request.box_innodb.public_ip}"
}
output "ip-client" {
  value = "${aws_spot_instance_request.box_client.public_ip}"
}

resource "aws_ebs_volume" "volume_rocksdb1" {
  availability_zone = "us-east-1a"
  size = 3400
  type = "gp2"
  iops = 10000
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test-rocksdb-3K"
    iit-billing-tag = "vadim-perf"
  }
}

resource "aws_ebs_volume" "volume_innodb1" {
  availability_zone = "us-east-1a"
  size = 3400
  type = "gp2"
  iops = 10000
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test-innodb-3K"
    iit-billing-tag = "vadim-perf"
  }
}

resource "aws_ebs_volume" "volume_innodb" {
  availability_zone = "us-east-1a"
  size = 1024
  type = "io1"
  iops = 30000
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test-innodb"
    iit-billing-tag = "vadim-perf"
  }
}

resource "aws_ebs_volume" "backup" {
  availability_zone = "us-east-1a"
  size = 1000
  type = "gp2"
  iops = 10000
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test"
    iit-billing-tag = "vadim-perf"
  }
}

resource "aws_volume_attachment" "attach_rocksdb" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.volume_rocksdb1.id}"
  instance_id = "${aws_instance.box_rocksdb.id}"
}

resource "aws_volume_attachment" "backup_att" {
  device_name = "/dev/sdj"
  volume_id   = "${aws_ebs_volume.backup.id}"
  instance_id = "${aws_instance.box_rocksdb.id}"
  skip_destroy = true
}

data "aws_instance" "box_innodb" {
  instance_tags {
    Name = "Vadim-test-innodb"
  }
}

resource "aws_volume_attachment" "attach_innodb" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.volume_innodb.id}"
  instance_id = "${data.aws_instance.box_innodb.id}"
}

data "aws_instance" "box1" {
  instance_tags {
    Name = "Vadim-test-innodb1"
  }
}


resource "aws_volume_attachment" "attach_innodb1" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.volume_innodb1.id}"
  instance_id = "${data.aws_instance.box1.id}"
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
