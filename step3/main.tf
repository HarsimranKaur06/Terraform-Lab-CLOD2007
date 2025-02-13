provider "google" {
  project     = "lab1-clod2007"
  region      = "us-east1"
  credentials = file("credentials.json")  # Read from local file
}

# Fetch the Service Account Email from Step 2
data "terraform_remote_state" "step2" {
  backend = "gcs"
  config = {
    bucket = "lab-tfstate-dev-001"  # Replace with your GCS bucket name
    prefix = "terraform/state/step2"  # Path to Step 2 state file
  }
}

# Use the service account email from Step 2
locals {
  service_account_email = data.terraform_remote_state.step2.outputs.service_account_email
}

# Create a GCS Bucket for Terraform State
resource "google_storage_bucket" "terraform_state" {
  name     = "lab-tfstate-dev-001"  # Naming convention: lab-tfstate-<environment>-<unique-id>
  location = "US"

  versioning {
    enabled = true  # Enable versioning for the bucket
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.example.id  # Encrypt the bucket
  }
}

# Create a KMS Key Ring and Crypto Key for Encryption
resource "google_kms_key_ring" "example" {
  name     = "lab-keyring-dev-001"  # Naming convention: lab-keyring-<environment>-<unique-id>
  location = "us-east1"             # Your preferred region
}

resource "google_kms_crypto_key" "example" {
  name            = "lab-cryptokey-dev-001"  # Naming convention: lab-cryptokey-<environment>-<unique-id>
  key_ring        = google_kms_key_ring.example.id
  rotation_period = "100000s"  # Rotate the key every 100,000 seconds

  version_template {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
  }
}

# Assign IAM Roles for the VM
resource "google_project_iam_binding" "example" {
  project = "lab1-clod2007"  # Your GCP project ID
  role    = "roles/compute.instanceAdmin"

  members = [
    "user:harsimrankaur06@gmail.com",  # Your email
  ]
}

# Assign IAM Roles to the Service Account
resource "google_project_iam_binding" "service_account" {
  project = "lab1-clod2007"  # Your GCP project ID
  role    = "roles/compute.admin"

  members = [
    "serviceAccount:${local.service_account_email}",
  ]
}

# Assign IAM Role for Storage Admin
resource "google_project_iam_binding" "storage_admin" {
  project = "lab1-clod2007"  # Your GCP project ID
  role    = "roles/storage.admin"

  members = [
    "user:harsimrankaur06@gmail.com",  # Your email
  ]
}