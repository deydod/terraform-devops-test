resource "google_sql_database_instance" "instance" {
    name = var.db_instance
    database_version = "MYSQL_8_4"
    region = "europe-west1"

    deletion_protection = false

    settings {
        tier = "db-f1-micro"
        backup_configuration {
            enabled = false                 # enable on production
            binary_log_enabled = false
        }
    }
}

resource "google_sql_database" "database" {
    name = var.db_name
    instance = google_sql_database_instance.instance.name
}