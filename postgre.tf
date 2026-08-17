
#google_sql_database_instance → crée le serveur Postgres lui-même.
#google_sql_database → crée une base nommée "keycloak" dessus.
#google_sql_user → crée l'utilisateur app_user avec un mot de passe, pour s'y connecter.
#google_project_iam_member → donne au compte qui fait tourner Keycloak (et les futurs services) le droit de s'y connecter.



resource "google_sql_database_instance" "postgres_hmj01" {
  name             = "postgres-instance-hmj01"
  project          = var.project_info.project_id
  region           = var.project_info.project_region
  database_version = "POSTGRES_16"

  settings {
    tier              = "db-f1-micro"
    availability_type = "ZONAL"
    disk_size         = 10
    disk_type         = "PD_SSD"

    backup_configuration {
      enabled = true
    }

    ip_configuration {
      ipv4_enabled = true
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "keycloak_db" {
  name     = "keycloak"
  instance = google_sql_database_instance.postgres_hmj01.name
}

resource "google_sql_user" "postgres_user" {
  name     = "app_user"
  instance = google_sql_database_instance.postgres_hmj01.name
  password = var.POSTGRES_PASSWORD
}

resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_info.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:80844171008-compute@developer.gserviceaccount.com"
}