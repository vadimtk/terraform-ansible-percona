// Configure the Google Cloud provider
provider "google" {
  credentials = "${file("../account.json")}"
  project     = "benchmark-163319"
  region      = "us-west1"
}


resource "google_compute_instance" "pxc" {
  count              = "3"
  name               = "pxc-node-${count.index + 1}"
  machine_type = "n1-highmem-16"
  zone         = "us-west1-b"

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

  metadata {
    foo = "bar"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  allow_stopping_for_update=true
}

resource "google_compute_instance" "sysbench" {
  count              = "1"
  name               = "sysbench-pxc-node-${count.index + 1}"
  machine_type = "n1-highmem-8"
  zone         = "us-west1-b"

  tags = ["sysbench-node", "test"]

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

  metadata {
    foo = "bar"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  allow_stopping_for_update=true
}

