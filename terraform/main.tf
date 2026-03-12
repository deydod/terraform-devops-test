# Define storage
module "storage" {
    source = "./modules/storage"
    bucket_name = var.bucket_name
    region = var.region
}

# Define SQL
module "cloudsql" {
    source = "./modules/cloudsql"
    db_instance = var.db_instance
    db_name = var.db_name
    db_user = var.db_user
    db_password = var.db_password
}

# Define PHP instance
resource "google_cloud_run_service" "php_service" {
    name = "php-cloudrun"
    location = var.region

    template {
        spec {
            containers {
                image = var.container_image
            }
        }
    }

    traffic {
        percent = 100
        latest_revision = true
    }
}

# Make sure the instance has public access
resource "google_cloud_run_service_iam_member" "public_access" {
    service = google_cloud_run_service.php_service.name
    location = google_cloud_run_service.php_service.location
    role = "roles/run.invoker"
    member = "allUsers"
}