# Provider Configuration
provider "google" {
  credentials = file("credentials.json")  # Explicitly use the credentials file
  project     = "lab1-clod2007"  # Your GCP project ID
  region      = "us-east1"       # Your preferred region
}

# Create a VPC Network
resource "google_compute_network" "example" {
  name                    = "lab-vpc-dev-001"  # Naming convention: lab-vpc-<environment>-<unique-id>
  auto_create_subnetworks = false
}

# Create a Subnet
resource "google_compute_subnetwork" "example" {
  name          = "lab-subnet-dev-001"  # Naming convention: lab-subnet-<environment>-<unique-id>
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-east1"            # Your preferred region
  network       = google_compute_network.example.id
}

# Deploy an Ubuntu Compute Engine VM
resource "google_compute_instance" "example" {
  name         = "lab-vm-dev-001"  # Naming convention: lab-vm-<environment>-<unique-id>
  machine_type = "e2-medium"
  zone         = "us-east1-b"      # Your preferred zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"  # Ubuntu 22.04 LTS image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.example.id

    access_config {
      # Assign a public IP to the VM
    }
  }

  service_account {
    email  = google_service_account.example.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"  # Use the SSH public key from the variable
  }
}

# Create Firewall Rules
resource "google_compute_firewall" "example" {
  name    = "lab-fw-allow-http-https-dev-001"  # Naming convention: lab-fw-<description>-<environment>-<unique-id>
  network = google_compute_network.example.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]  # Allow traffic from anywhere
  target_tags   = ["web-server"]  # Apply this rule to VMs with the tag "web-server"
}

# Create a Service Account for Secure Access
resource "google_service_account" "example" {
  account_id   = "lab-sa-dev-001"  # Naming convention: lab-sa-<environment>-<unique-id>
  display_name = "Service Account for Terraform Lab"
}

# Output the Service Account Email
output "service_account_email" {
  value = google_service_account.example.email
}

# Define a variable for the SSH public key
variable "ssh_public_key" {
  type      = string
  sensitive = true  # Mark the variable as sensitive
}