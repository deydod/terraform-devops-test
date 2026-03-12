# Save the state to GCP 
terraform {
    backend "gcs" {
        bucket = "0001-terraform-state-bucket"
        prefix = "terraform-devops-test"
    }
}