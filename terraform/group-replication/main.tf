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

resource "google_compute_disk" "nodedisk" {
  count  = "3"
  name  = "mysql-disk-${count.index+1}"
  type  = "pd-ssd"
  zone  = "${element(var.azs, count.index)}"
  labels {
    environment = "group-replication"
  }
  size = 400
}


resource "google_compute_instance" "default" {
  count              = "3"
  name               = "mysql-node-${count.index+1}"
  machine_type = "n1-highmem-16"
  zone         = "${element(var.azs, count.index)}"

  tags = ["mysql-node"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  attached_disk {
    source = "${element(google_compute_disk.nodedisk.*.self_link, count.index)}"
  }

  // Local SSD disk
  // scratch_disk {
  //  interface = "NVME"
  // }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    foo = "bar"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  allow_stopping_for_update=true
}

