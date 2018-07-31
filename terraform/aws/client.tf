resource "aws_spot_instance_request" "box_clients" {
  count            = "1"
  ami = "ami-b70554c8"
  instance_type = "c5.9xlarge"
  availability_zone = "us-east-1b"
  subnet_id = "${aws_subnet.private-subnet.id}"
  associate_public_ip_address=true
  vpc_security_group_ids = ["${aws_security_group.sgdb.id}"]
  key_name="VadimAmazonNorthV"
  wait_for_fulfillment = true
  spot_type = "one-time"
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test-${count.index + 1}"
    iit-billing-tag = "vadim-perf"
  }

  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${self.spot_instance_id} --tags Key=Name,Value=Vadim-test-client-${count.index} Key=iit-billing-tag,Value=vadim-perf"

    environment {
      AWS_ACCESS_KEY_ID = "${var.aws_access_key}"
      AWS_SECRET_ACCESS_KEY = "${var.aws_secret_key}"
      AWS_DEFAULT_REGION = "us-east-1"
    }
  }

}

resource "aws_route53_record" "box_clients" {
  count   = 1
  zone_id = "${data.aws_route53_zone.vtk.zone_id}"
  name    = "box_client-${count.index}.${data.aws_route53_zone.vtk.name}"
  type    = "A"
  ttl     = "10"
  records = ["${aws_spot_instance_request.box_clients.*.public_ip[count.index]}"]
}
