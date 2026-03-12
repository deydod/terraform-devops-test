variable "key" {

}

variable "project_id" {
    description = "GCP project ID"
    type = string
}

variable "region" {
    description = "GCP region for resources"
    type = string
    default = "europe-west1"
}

variable "bucket_name" {
    type = string
}

variable "container_image" {
    description = "Docker container image for Cloud Run"
    type = string
}


variable "db_instance" {
    description = "Cloud SQL instance name"
    type = string
}

variable "db_name" {
    description = "Database name"
    type = string
}

variable "db_user" {
    description = "Database user"
    type = string
}

variable "db_password" {
    description = "Database password"
    type = string
    sensitive = true
}