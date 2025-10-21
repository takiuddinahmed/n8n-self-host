terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "takiuddin-test-vpc"
}

resource "google_compute_address" "terraform-test-instance-ip" {
  name   = "terraform-test-instance-ip"
  region = "us-central1"
}


resource "google_compute_instance" "terraform-test-instance" {
  name         = "terraform-test-instance"
  machine_type = "e2-medium"

  tags = ["server"]

  boot_disk {
    initialize_params {
      image = "projects/centos-cloud/global/images/centos-stream-10-v20251014"
      size  = 20
      type  = "pd-ssd"
    }
  }

  metadata_startup_script = "sudo dnf update -y && sudo dnf install git -y && git clone https://github.com/takiuddinahmed/n8n-self-host && cd n8n-self-host && sudo chmod +x command.sh && echo 'Running ./command.sh to install n8n and configure SSL'  && ./command.sh"



  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      nat_ip = google_compute_address.terraform-test-instance-ip.address
    }
  }

  metadata = {
    enable-oslogin = "FALSE"
    ssh-keys       = "takiuddin:${file("~/.ssh/id_minimatic_solutions_it.pub")}"
  }

}

resource "google_compute_firewall" "allow-ssh-http" {
  name          = "allow-ssh-http"
  network       = google_compute_network.vpc_network.name
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  priority      = 1000
  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }
  target_tags = ["server"]
}


output "web_server_ip" {
  value = google_compute_instance.terraform-test-instance.network_interface.0.access_config.0.nat_ip
}
