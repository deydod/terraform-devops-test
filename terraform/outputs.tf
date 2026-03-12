# Output project URL
output "CloudRun_URL" {
    description = "Public URL of the Cloud Run service"
    value = google_cloud_run_service.php_service.status[0].url
}

# Output the bucket name
output "Storage_BucketName" {
    description = "The name of the storage bucket (from storage module)"
    value = module.storage.storage_bucket_name
}

output "CloudSQL_ConnectionName" {
    description = "Cloud SQL instance connection name"
    value = module.cloudsql.connection_name
}