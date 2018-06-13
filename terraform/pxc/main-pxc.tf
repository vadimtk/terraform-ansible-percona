// Configure the Google Cloud provider
provider "google" {
  credentials = "${file("../account.json")}"
  project     = "benchmark-163319"
  region      = "us-west1"
}


variable "azs" {
  description = "Run the Instances in these Availability Zones"
  type = "list"
  default = ["us-west1-a", "us-west1-b", "us-west1-c"]
}


resource "google_compute_instance" "pxc" {
  count              = "3"
  name               = "pxc-node-${count.index + 1}"
  machine_type = "${var.instancesize}"
  zone         = "${element(var.azs, count.index)}"

  tags = ["pxc-node"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  allow_stopping_for_update=true
}

resource "google_compute_instance" "proxy" {
  count              = "1"
  name               = "proxy-node-${count.index + 1}"
  machine_type = "${var.instancesize}"
  zone         = "${element(var.azs, count.index)}"

  tags = ["proxysql-node"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  // Local SSD disk
  scratch_disk {
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  allow_stopping_for_update=true
}

