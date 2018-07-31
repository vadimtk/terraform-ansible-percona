resource "aws_db_instance" "db2" {
  identifier = "vadim-db2"
  allocated_storage    = 1000
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.m4.4xlarge"
  name                 = "sbtest"
  multi_az             = false
  username             = "sbtest"
  password             = "sbtestsbtest"
  parameter_group_name = "vadim-parameters"
  skip_final_snapshot  = true
  vpc_security_group_ids  = ["${aws_security_group.sgdb.id}"]
  db_subnet_group_name     = "${aws_db_subnet_group.default.id}"
  tags {
    deparment = "CTOLab"
    Name = "Vadim-test-rds"
    iit-billing-tag = "vadim-perf"
  }
}

resource "aws_db_parameter_group" "vadim-param" {
  name   = "vadim-parameters"
  family = "mysql5.7"

  parameter {
    name  = "innodb_io_capacity_max"
    value = "4500"
  }
  parameter {
    name  = "innodb_io_capacity"
    value = "2500"
  }
  parameter {
    name  = "innodb_log_buffer_size"
    value = "67108864"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "innodb_log_file_size"
    value = "4294967296"
    apply_method = "pending-reboot"
  }
}

