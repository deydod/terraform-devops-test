# Save the state to GCP 
terraform {
    backend "gcs" {
        bucket = "0001-terraform-state-bucket"
        prefix = "terraform-devops-test"
        credentials = "../grand-sweep-490023-n2-be46df61520d.json"
    }
}