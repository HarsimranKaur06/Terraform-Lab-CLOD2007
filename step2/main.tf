terraform {
  backend "gcs" {
    bucket = "lab-tfstate-dev-001"
    prefix = "terraform/state/step2"
  }
}

provider "google" {
  project     = "lab1-clod2007"
  region      = "us-east1"
  credentials = file("/home/runner/credentials.json")
}

# Create a VPC Network
resource "google_compute_network" "example" {
  name                    = "lab-vpc-dev-001"
  auto_create_subnetworks = false
}

# Create a Subnet
resource "google_compute_subnetwork" "example" {
  name          = "lab-subnet-dev-001"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-east1"
  network       = google_compute_network.example.id
}

# Deploy an Ubuntu Compute Engine VM
resource "google_compute_instance" "example" {
  name         = "lab-vm-dev-001"
  machine_type = "e2-medium"
  zone         = "us-east1-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.example.id
    access_config {} # Assign public IP
  }

  service_account {
    email  = google_service_account.example.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    # OS Login is enabled by default when no SSH keys are passed
  }
}

# Firewall Rule
resource "google_compute_firewall" "example" {
  name    = "lab-fw-allow-http-https-dev-001"
  network = google_compute_network.example.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

# Create a Service Account
resource "google_service_account" "example" {
  account_id   = "lab-sa-dev-001"
  display_name = "Terraform Service Account"
}

# Output Service Account Email
output "service_account_email" {
  value = google_service_account.example.email
}

# Add IAM Permissions for Terraform Service Account
resource "google_project_iam_binding" "iam_permissions" {
  project = "lab1-clod2007"
  role    = "roles/iam.securityAdmin"

  members = [
    "serviceAccount:${google_service_account.example.email}"
  ]
}