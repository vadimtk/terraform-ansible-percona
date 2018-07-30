# Configure the Packet Provider
provider "packet" {
  auth_token = "${chomp(file("/home/vadim/keys/packet_key"))}"
}

resource "packet_ssh_key" "key1" {
  name       = "terraform-1"
  public_key = "${file("/home/vadim/keys/packet-keys/packet_rsa.pub")}"
}


# Create a project
resource "packet_project" "cool_project" {
  name           = "MySQLTest"
}

# Create a device and add it to tf_project_1
resource "packet_device" "nodes" {
  count            = "1"
  hostname         = "node-${count.index + 1}"
  plan             = "c1.small.x86"
  facility         = "ewr1"
  operating_system = "ubuntu_18_04"
  billing_cycle    = "hourly"
  project_id       = "${packet_project.cool_project.id}"
  connection {
    type     = "ssh"
    user = "root"
    private_key = "${file("/home/vadim/keys/packet-keys/packet_rsa")}"
  }
  provisioner "file" {
    source      = "conf/hosts.allow"
    destination = "/etc/hosts.allow"
  }
  provisioner "file" {
    source      = "conf/hosts.deny"
    destination = "/etc/hosts.deny"
  }
}

resource "packet_device" "nodesubu" {
  count            = "1"
  hostname         = "nodeubu-${count.index + 1}"
  plan             = "c2.medium.x86"
  facility         = "ewr1"
  operating_system = "ubuntu_18_04"
  billing_cycle    = "hourly"
  project_id       = "${packet_project.cool_project.id}"
  connection {
    type     = "ssh"
    user = "root"
    private_key = "${file("/root/.ssh/id_rsa")}"
  }
  provisioner "file" {
    source      = "conf/hosts.allow"
    destination = "/etc/hosts.allow"
  }
  provisioner "file" {
    source      = "conf/hosts.deny"
    destination = "/etc/hosts.deny"
  }
}

resource "packet_device" "client" {
  count            = "1"
  hostname         = "client-${count.index + 1}"
  plan             = "t1.small.x86"
  facility         = "ewr1"
  operating_system = "ubuntu_18_04"
  billing_cycle    = "hourly"
  project_id       = "${packet_project.cool_project.id}"
  connection {
    type     = "ssh"
    user = "root"
    private_key = "${file("/root/.ssh/id_rsa")}"
  }
  provisioner "file" {
    source      = "conf/hosts.allow"
    destination = "/etc/hosts.allow"
  }
  provisioner "file" {
    source      = "conf/hosts.deny"
    destination = "/etc/hosts.deny"
  }
}

# Create a device and add it to tf_project_1
resource "packet_device" "mngt" {
  count            = "1"
  hostname         = "mngt-${count.index + 1}"
  plan             = "t1.small.x86"
  facility         = "ewr1"
  operating_system = "centos_7"
  billing_cycle    = "hourly"
  project_id       = "${packet_project.cool_project.id}"
  connection {
    user = "root"
    private_key = "${file("/root/.ssh/id_rsa.pub")}"
  }
}
