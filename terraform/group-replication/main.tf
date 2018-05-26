// Configure the Google Cloud provider
provider "google" {
  credentials = "${file("../account.json")}"
  project     = "benchmark-163319"
  region      = "us-west1"
}


resource "google_compute_instance" "default" {
  count              = "3"
  name               = "mysql-node-${count.index + 1}"
  machine_type = "n1-highmem-16"
  zone         = "us-west1-b"

  tags = ["mysql-node", "test"]

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

  metadata {
    foo = "bar"
  }

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  allow_stopping_for_update=true
}

