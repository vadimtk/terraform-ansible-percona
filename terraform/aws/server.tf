resource "aws_spot_instance_request" "box_innodb" {
  ami = "${var.ami}"
  instance_type = "r5.12xlarge"
  availability_zone = "${var.region}a"
  subnet_id = "${aws_subnet.public-subnet.id}"
  associate_public_ip_address=true
  vpc_security_group_ids = ["${aws_security_group.sgdb.id}"]
  key_name="${var.keyname}"
  wait_for_fulfillment = true
  spot_type = "one-time"
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test"
    iit-billing-tag = "vadim-perf"
  }
  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${self.spot_instance_id} --tags Key=Name,Value=Vadim-innodb Key=iit-billing-tag,Value=vadim-perf"

    environment {
      AWS_ACCESS_KEY_ID = "${var.aws_access_key}"
      AWS_SECRET_ACCESS_KEY = "${var.aws_secret_key}"
      AWS_DEFAULT_REGION = "${var.region}"
    }
  }

}

resource "aws_route53_record" "box_innodb" {
  zone_id = "${data.aws_route53_zone.vadimtk.zone_id}"
  name    = "box_innodb.${data.aws_route53_zone.vadimtk.name}"
  type    = "A"
  ttl     = "10"
  records = ["${aws_spot_instance_request.box_innodb.public_ip}"]
}

resource "aws_ebs_volume" "volume_innodb" {
  availability_zone = "${var.region}a"
  size = 3400
  type = "gp2"
  iops = 30000
  snapshot_id="snap-0270c3d4663dcfcb4"
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test-innodb"
    iit-billing-tag = "vadim-perf"
  }
}

data "aws_instance" "box_innodb" {
  instance_tags {
    Name = "Vadim-innodb"
  }
}

resource "aws_volume_attachment" "attach_innodb" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.volume_innodb.id}"
  instance_id = "${data.aws_instance.box_innodb.id}"
}

output "ip-innodb" {
  value = "${aws_spot_instance_request.box_innodb.public_ip}"
}

resource "aws_spot_instance_request" "box_rocksdb" {
  ami = "${var.ami}"
  instance_type = "c5.9xlarge"
  availability_zone = "${var.region}a"
  subnet_id = "${aws_subnet.public-subnet.id}"
  associate_public_ip_address=true
  vpc_security_group_ids = ["${aws_security_group.sgdb.id}"]
  key_name="${var.keyname}"
  wait_for_fulfillment = true
  spot_type = "one-time"
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test"
    iit-billing-tag = "vadim-perf"
  }
  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${self.spot_instance_id} --tags Key=Name,Value=Vadim-rocksdb Key=iit-billing-tag,Value=vadim-perf"

    environment {
      AWS_ACCESS_KEY_ID = "${var.aws_access_key}"
      AWS_SECRET_ACCESS_KEY = "${var.aws_secret_key}"
      AWS_DEFAULT_REGION = "${var.region}"
    }
  }

}

resource "aws_route53_record" "box_rocksdb" {
  zone_id = "${data.aws_route53_zone.vadimtk.zone_id}"
  name    = "box_rocksdb.${data.aws_route53_zone.vadimtk.name}"
  type    = "A"
  ttl     = "10"
  records = ["${aws_spot_instance_request.box_rocksdb.public_ip}"]
}

output "ip-rocksdb" {
  value = "${aws_spot_instance_request.box_rocksdb.public_ip}"
}

resource "aws_ebs_volume" "volume_rocksdb" {
  availability_zone = "${var.region}a"
  size = 3400
  type = "gp2"
  iops = 10000
  tags {
    deparment = "CTOLab"
    Name = "Vadim-rocksdb-3K"
    iit-billing-tag = "vadim-perf"
  }
}

data "aws_instance" "box_rocksdb" {
  instance_tags {
    Name = "Vadim-rocksdb"
  }
}

resource "aws_volume_attachment" "attach_rocksdb" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.volume_rocksdb.id}"
  instance_id = "${data.aws_instance.box_rocksdb.id}"
}



resource "aws_spot_instance_request" "pmm-server" {
  ami = "ami-03e930facd8d4562e"
  instance_type = "c4.4xlarge"
  availability_zone = "${var.region}a"
  subnet_id = "${aws_subnet.public-subnet.id}"
  associate_public_ip_address=true
  vpc_security_group_ids = ["${aws_security_group.sgdb.id}"]
  key_name="${var.keyname}"
  wait_for_fulfillment = true
  spot_type = "one-time"
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test"
    iit-billing-tag = "vadim-perf"
  }
  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${self.spot_instance_id} --tags Key=Name,Value=Vadim-pmmserver Key=iit-billing-tag,Value=vadim-perf"

    environment {
      AWS_ACCESS_KEY_ID = "${var.aws_access_key}"
      AWS_SECRET_ACCESS_KEY = "${var.aws_secret_key}"
      AWS_DEFAULT_REGION = "${var.region}"
    }
  }

}

resource "aws_route53_record" "pmm-server" {
  zone_id = "${data.aws_route53_zone.vadimtk.zone_id}"
  name    = "pmm-server.${data.aws_route53_zone.vadimtk.name}"
  type    = "A"
  ttl     = "10"
  records = ["${aws_spot_instance_request.pmm-server.public_ip}"]
}
