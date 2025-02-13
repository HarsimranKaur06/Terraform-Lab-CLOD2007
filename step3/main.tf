provider "google" {
  project     = "lab1-clod2007"
  region      = "us-east1"
  credentials = file("/home/runner/credentials.json")
}

# SSH Key Variable
variable "ssh_public_key" {
  type      = string
  sensitive = true
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

# Deploy an Ubun
"google" {
  project     = "lab1-clod2007"
  region      = "us-east1"
  credentials = file("/home/runner/credentials.json")
}

# Fetch Terraform Remote State from Step 2
data "terraform_remote_state" "step2" {
  backend = "gcs"
  config = {
    bucket = "lab-tfstate-dev-001"
    prefix = "terraform/state/step2"
  }
}

# Use Service Account from Step 2
locals {
  service_account_email = data.terraform_remote_state.step2.outputs.service_account_email
}

# Create GCS Bucket
resource "google_storage_bucket" "terraform_state" {
  name     = "lab-tfstate-dev-001"
  location = "US"

  versioning {
    enabled = true
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.example.id
  }
}

# Create KMS Key Ring & Crypto Key
resource "google_kms_key_ring" "example" {
  name     = "lab-keyring-dev-001"
  location = "us-east1"
}

resource "google_kms_crypto_key" "example" {
  name            = "lab-cryptokey-dev-001"
  key_ring        = google_kms_key_ring.example.id
  rotation_period = "100000s"

  version_template {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
  }
}

# IAM Bindings
resource "google_project_iam_binding" "example" {
  project = "lab1-clod2007"
  role    = "roles/compute.instanceAdmin"

  members = [
    "user:harsimrankaur06@gmail.com"
  ]
}

resource "google_project_iam_binding" "service_account" {
  project = "lab1-clod2007"
  role    = "roles/compute.admin"

  members = [
    "serviceAccount:${local.service_account_email}"
  ]
}

resource "google_project_iam_binding" "storage_admin" {
  project = "lab1-clod2007"
  role    = "roles/storage.admin"

  members = [
    "user:harsimrankaur06@gmail.com"
  ]
}
