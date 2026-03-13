# Disaster Recovery Strategy (DR)

## Overview

This document describes the **Disaster Recovery (DR) strategy** for the PHP application deployed on Google Cloud using:

* Terraform
* Cloud Run
* Cloud SQL (MySQL)
* Cloud Storage
* Docker
* GitHub Actions

The goal of this strategy is to ensure **service continuity, minimal downtime, and data protection** in case of infrastructure failure, accidental deletion, or regional outages.

---

# Objectives

The disaster recovery strategy aims to achieve:

* **High availability of the application**
* **Fast infrastructure restoration**
* **Minimal data loss**
* **Automated recovery using Infrastructure as Code**

Key recovery targets:

| Metric                             | Target       |
| ---------------------------------- | ------------ |
| **RTO (Recovery Time Objective)**  | < 30 minutes |
| **RPO (Recovery Point Objective)** | < 5 minutes  |

---

# System Components Covered

The following components are included in the DR plan:

| Component           | Service                   |
| ------------------- | ------------------------- |
| Application runtime | Cloud Run                 |
| Database            | Cloud SQL (MySQL)         |
| File storage        | Cloud Storage             |
| Container image     | Google Container Registry |
| Infrastructure      | Terraform                 |
| CI/CD               | GitHub Actions            |

---

# Potential Failure Scenarios

## 1 Infrastructure Failure

Examples:

* Cloud Run service crash
* Cloud SQL instance failure
* Storage bucket misconfiguration

Mitigation:

* Infrastructure can be **recreated automatically using Terraform**

Recovery command:

```bash
terraform apply
```

---

## 2 Application Deployment Failure

Examples:

* Broken Docker image
* Bad application release
* CI/CD pipeline issues

Mitigation:

Cloud Run keeps **multiple revisions** of the service.

Rollback command:

```bash
gcloud run services update-traffic php-cloudrun \
  --to-revisions PREVIOUS_REVISION=100 \
  --region europe-west1
```

---

## 3 Database Data Loss

Examples:

* Accidental deletion
* Corruption
* Application bug

Mitigation:

Cloud SQL supports:

* **Automated backups**
* **Point-in-time recovery**
* **Cross-region backups**

Recommended configuration:

* Daily automatic backups
* Binary logging enabled

Restore example:

```bash
gcloud sql backups restore BACKUP_ID \
  --restore-instance php-mysql
```

---

## 4 Regional Failure

Examples:

* GCP region outage
* Network routing issues

Mitigation strategy:

* Deploy infrastructure in a **secondary region**
* Maintain container images in **multi-region registry**

Suggested secondary region:

```
europe-west4
```

Recovery process:

1. Update Terraform variables:

```hcl
region = "europe-west4"
```

2. Redeploy infrastructure:

```bash
terraform apply
```

---

# Backup Strategy

## Database Backups

Cloud SQL backups:

* Automated daily backups
* Transaction log backups
* Point-in-time recovery

Retention policy:

```
7–30 days
```

---

## Storage Backups

Cloud Storage supports:

* **Object versioning**
* **Lifecycle rules**

Recommended configuration:

```terraform
versioning {
  enabled = true
}
```

This protects against:

* accidental deletion
* overwritten files

---

# Infrastructure Recovery

Because infrastructure is defined using **Terraform**, it can be fully recreated.

Recovery procedure:

1. Clone repository

```bash
git clone <repository>
cd terraform-devops-test
```

2. Authenticate with Google Cloud

```bash
gcloud auth login
```

3. Initialize Terraform

```bash
terraform init
```

4. Recreate infrastructure

```bash
terraform apply
```

All resources will be restored automatically.

---

# Container Image Recovery

Container images are stored in:

```
gcr.io/<project-id>/php-app
```

Recovery options:

* Pull existing image
* Rebuild from source

Rebuild example:

```bash
docker build -t gcr.io/<project-id>/php-app:latest .
docker push gcr.io/<project-id>/php-app:latest
```

---

# CI/CD Recovery

GitHub Actions workflows control deployment.

Workflows available:

```
.github/workflows/deploy.yml
.github/workflows/destroy.yml
```

If infrastructure is lost:

1. Run Terraform manually
2. Trigger **deploy workflow**

Manual trigger:

```
GitHub → Actions → Deploy → Run Workflow
```

---

# Monitoring and Alerts

Recommended monitoring tools:

* Google Cloud Monitoring
* Cloud Logging
* Uptime checks

Alerts should be configured for:

* Cloud Run errors
* High latency
* Database failures
* HTTP 5xx responses

---

# Security and Secrets Recovery

Secrets used by CI/CD:

* `GCP_PROJECT`
* `GCP_SA_KEY`

Stored securely in:

```
GitHub Secrets
```

Recovery process:

1. Generate new Service Account Key
2. Update GitHub repository secrets

---

# Disaster Recovery Testing

DR strategy should be tested regularly.

Suggested tests:

| Test                    | Frequency |
| ----------------------- | --------- |
| Terraform rebuild test  | Monthly   |
| Database restore test   | Quarterly |
| CI/CD pipeline recovery | Quarterly |

Example test:

```
terraform destroy
terraform apply
```

This validates that the entire system can be recreated automatically.

---

# Summary

The disaster recovery strategy is based on:

* **Infrastructure as Code (Terraform)**
* **Automated backups**
* **Cloud Run revision rollback**
* **Container image versioning**
* **Multi-region recovery capability**

These practices ensure the platform can recover quickly from failures while minimizing service downtime and data loss.

---
