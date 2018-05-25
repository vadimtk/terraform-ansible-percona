// Configure the Google Cloud provider
provider "google" {
  credentials = "${file("account.json")}"
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

resource "google_compute_instance" "sysbench" {
  count              = "1"
  name               = "sysbench-node-${count.index + 1}"
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

  metadata_startup_script = "echo hi > /test.txt"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  allow_stopping_for_update=true
}

resource "google_compute_disk" "pmmserver" {
  name  = "test-disk-1"
  type  = "pd-ssd"
  zone  = "us-west1-b"
  labels {
    environment = "pmm"
  }
  size = 40
}

resource "google_compute_instance" "pmm-server" {
  count              = "1"
  name               = "pmm-server-${count.index + 1}"
  machine_type = "n1-standard-8"
  zone         = "us-west1-b"

  tags = ["sysbench-node", "test"]

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

  attached_disk {
    source = "${google_compute_disk.pmmserver.self_link}"
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
