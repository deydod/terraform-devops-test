# Terraform DevOps Test – PHP Application on Google Cloud

## Overview

This project demonstrates a simple **DevOps pipeline and infrastructure setup** using:

* **Terraform** for Infrastructure as Code
* **Google Cloud Platform (GCP)**
* **Cloud Run** for running a containerized PHP application
* **Cloud SQL (MySQL)** for database services
* **Cloud Storage** for object storage
* **Docker** for containerization
* **Nginx + PHP-FPM** for serving the PHP application
* **GitHub Actions** for CI/CD automation

The repository provisions infrastructure, builds a Docker image, deploys it to Cloud Run, and provides automated workflows for deployment and teardown.

---

# Architecture

The application is deployed using the following architecture:

```
                Internet
                    │
                    │
           HTTPS Load Balancing
             (Cloud Run URL)
                    │
                    ▼
               Cloud Run
          (Nginx + PHP-FPM container)
                    │
          ┌─────────┴─────────┐
          │                   │
          ▼                   ▼
      Cloud SQL           Cloud Storage
      (MySQL DB)           (Static files)
```

* **Cloud Run** hosts the PHP application container.
* **Nginx** listens on port `8080` and forwards PHP requests to **PHP-FPM**.
* **Cloud SQL** provides MySQL database services.
* **Cloud Storage** provides a bucket for object storage.
* Cloud Run automatically exposes an **HTTPS endpoint with load balancing**.

---

# Infrastructure Components

## Cloud Run

Terraform resource:

```
google_cloud_run_service
```

Cloud Run runs a Docker container containing:

* **Nginx**
* **PHP-FPM**
* the application (`index.php`)

Nginx listens on:

```
PORT=8080
```

This is required because Cloud Run expects the container to listen on port **8080**.

---

## Cloud SQL

Provisioned using Terraform:

```
google_sql_database_instance
google_sql_database
google_sql_user
```

Provides a **MySQL database** for the application.

Note: If `terraform destroy` fails due to deletion protection:

```
deletion_protection = false
```

must be set.

---

## Cloud Storage

Provisioned via Terraform module:

```
google_storage_bucket
```

Used for storing static files or application assets.

Example module output:

```
output "storage_bucket_name" {
  value = google_storage_bucket.bucket.name
}
```

---

# Docker Container

The container runs:

* **PHP 8.3 FPM**
* **Nginx**

### Dockerfile logic

1. Install Nginx
2. Copy configuration files
3. Copy application code
4. Start PHP-FPM
5. Start Nginx

Container startup command:

```
php-fpm -D && nginx -g "daemon off;"
```

---

# Nginx Configuration

Example server block:

```
server {
    listen 8080;

    root /var/www/html;
    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

---

# Terraform Modules

Two modules are implemented:

## Storage Module

Creates a Cloud Storage bucket.

Example input variable:

```
variable "bucket_name" {
  type = string
}
```

Example output:

```
output "storage_bucket_name" {
  value = google_storage_bucket.bucket.name
}
```

---

## Cloud SQL Module

Creates:

* MySQL instance
* database
* database user

Outputs include the **connection name** used by Cloud Run.

---

# Terraform Outputs

Outputs make infrastructure details visible after deployment.

Example:

```
output "cloud_run_url" {
  value = google_cloud_run_service.php_service.status[0].url
}
```

After running:

```
terraform apply
```

Terraform prints:

```
cloud_run_url = https://php-cloudrun-xxxxx.run.app
```

---

# Running Terraform Locally

To run this project locally you will need **Terraform, GCloud SDK and Docker** installed and configured.

1. Install Tools (if not already)

    Terraform: https://developer.hashicorp.com/terraform/downloads

    Add terraform.exe to your PATH.

    Google Cloud SDK (gcloud): https://cloud.google.com/sdk/docs/install

    Add gcloud to your PATH.

    Docker Desktop: https://www.docker.com/products/docker-desktop

2. Set up GCP credentials locally

    Download a service account key JSON from GCP (the same one you use in GitHub Secrets).

    Go to: GCP Console → IAM & Admin → Service Accounts → Keys → Create Key → JSON

    Save it locally, e.g., ~/keys/gcp-sa-key.json.

    Set environment variables in your terminal (VSCode integrated terminal works):

    Linux: 
    ```
    export GOOGLE_APPLICATION_CREDENTIALS=~/keys/gcp-sa-key.json
    export GCP_PROJECT=<YOUR_PROJECT_ID>
    ```
    
    Windows:
    ```
    set GOOGLE_APPLICATION_CREDENTIALS=C:\<path>\gcp-sa-key.json
    set GCP_PROJECT=<YOUR_PROJECT_ID>
    ```    
    
    Replace <YOUR_PROJECT_ID> with your actual project ID.
    
    Terraform will automatically use this key for authentication.

3. Authenticate with GCP

    Open PowerShell:

    ```
    # Login to Google Cloud
    gcloud auth login

    # Set your GCP project
    gcloud config set project <YOUR_PROJECT_ID>

    # Authenticate Docker to GCR
    gcloud auth configure-docker
    ```

    Replace <YOUR_PROJECT_ID> with your actual project ID.

## Initialize Terraform

```
terraform init
```

## Plan Infrastructure

```
terraform plan
```

## Apply Infrastructure

```
terraform apply
```

## Destroy Infrastructure

```
terraform destroy
```

---

# Docker Build and Push

Build container:

```
docker build -t gcr.io/<PROJECT_ID>/php-app:latest -f Dockerfile .
```

Push container:

```
docker push gcr.io/<PROJECT_ID>/php-app:latest
```

---

# CI/CD with GitHub Actions

Two workflows are defined.

## Deploy Workflow

File:

```
.github/workflows/deploy.yml
```

Triggered automatically on push.

Pipeline steps:

1. Checkout repository
2. Authenticate with GCP
3. Build Docker image
4. Push image to Container Registry
5. Deploy to Cloud Run
6. Apply Terraform infrastructure

---

## Destroy Workflow

File:

```
.github/workflows/destroy.yml
```

Triggered manually:

```
on:
  workflow_dispatch
```

---

# Running Workflows

## Deploy

Push changes to the main branch:

```
git push origin main
```

GitHub Actions automatically runs the deployment pipeline.

---

## Destroy

1. Open the repository in GitHub
2. Go to **Actions**
3. Select **Destroy Infrastructure**
4. Click **Run workflow**

This will destroy all Terraform-managed resources.

---

# Security Considerations

Sensitive values are stored as **GitHub Secrets**:

* `GCP_PROJECT`
* `GCP_SA_KEY`

These are used in GitHub Actions workflows for authentication.

---

# Summary

This project demonstrates:

* Infrastructure provisioning with Terraform
* Containerized PHP application deployment
* CI/CD automation with GitHub Actions
* Integration with Google Cloud services
* Full lifecycle management (deploy + destroy)

It provides a reproducible infrastructure and automated deployment pipeline suitable for DevOps workflows.

---

# Notes

This project is provided "as-is". 
