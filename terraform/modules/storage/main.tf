# Create a Google Cloud Storage bucket
resource "google_storage_bucket" "bucket" {
    name = var.bucket_name
    location = var.region
    force_destroy = true

    versioning {
        enabled = true
    }

    uniform_bucket_level_access = true
}