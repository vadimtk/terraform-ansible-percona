// Configure the Google Cloud provider
provider "google" {
  credentials = "${file("../account.json")}"
  project     = "benchmark-163319"
  region      = "us-west1"
}
resource "google_compute_firewall" "allow_http" {  
    name = "allow-http"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["80"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["http"]
}

resource "google_compute_disk" "pmmserver" {
  name  = "pmm-disk-1"
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
  machine_type = "n1-standard-4"
  zone         = "us-west1-b"

  tags = ["pmmserver-node", "test"]

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


  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  allow_stopping_for_update=true
}
