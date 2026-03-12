# Output the bucket name
output "connection_name" {
    description = "The name of the storage bucket"
    value = google_sql_database_instance.instance.name
}