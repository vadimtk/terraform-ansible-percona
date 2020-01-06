
resource "aws_lightsail_instance" "test1" {
  count		    = 3
  name              = "test-${count.index + 1}"
  availability_zone = "us-west-2a"
  blueprint_id      = "ubuntu_18_04"
  bundle_id         = "xlarge_2_0"
  key_pair_name     = "vadim-oregon"
}



