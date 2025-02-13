# GCP Terraform Lab

This repository contains Terraform configurations to deploy infrastructure on Google Cloud Platform (GCP) using GitHub Actions for automation.

---

## **Steps to Set Up and Run the Lab**

### **1. Prerequisites**
- A GCP project with billing enabled.
- A service account with the necessary permissions.
- Terraform installed locally (for testing).
- GitHub repository to host the code and run workflows.

---

### **2. Steps to Deploy**

#### **Step 1: Set Up GitHub Secrets**
1. Go to your repository > **Settings** > **Secrets and variables** > **Actions**.
2. Add the following secrets:
   - **`GOOGLE_CREDENTIALS`**: Paste your GCP service account JSON key.
   - **`SSH_PUBLIC_KEY`**: Paste your SSH public key (`cat ~/.ssh/lab-vm-key.pub`).

#### **Step 2: Upload Code to GitHub**
1. Clone this repository or upload the code to your GitHub repository.

#### **Step 3: Run the Workflow**
1. Go to the **Actions** tab in your GitHub repository.
2. Click on the **Terraform Deployment** workflow.
3. Click **Run workflow** and select the `main` branch.

#### **Step 4: Monitor the Workflow**
- The workflow will automatically run `terraform init`, `terraform plan`, and `terraform apply` for both Step 2 and Step 3.
- Check the logs in the **Actions** tab to monitor progress and debug any issues.

#### **Step 5: Verify Resources in GCP**
- Go to the GCP Console and verify that the resources (VPC, subnet, VM, etc.) are created.

#### **Step 6: Clean Up (Optional)**
- To delete the resources, added a `terraform destroy` step to the workflow.

---

### **3. Workflow Details**
The GitHub Actions workflow (`.github/workflows/deploy.yml`) automates the following steps:
1. **Step 2**:
   - Creates a VPC, subnet, Ubuntu VM, and firewall rules.
   - Outputs the service account email for use in Step 3.
2. **Step 3**:
   - Creates a GCS bucket, KMS key, and IAM roles.
   - References the service account email from Step 2.

---

### **4. Debugging**
If the workflow fails:
1. Check the logs in the **Actions** tab.
2. Common issues include:
   - **Permission errors**: Ensure the service account has the required permissions.
   - **Invalid configuration**: Check the Terraform configuration for errors.
   - **Resource conflicts**: Delete conflicting resources manually in the GCP Console.

---