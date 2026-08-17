# google_sql_database_instance → cree le serveur Postgres lui-meme.
# google_sql_database → cree une base nommee "keycloak" dessus.
# google_sql_user → cree l'utilisateur app_user avec un mot de passe, pour s'y connecter.
# google_project_iam_member → donne au compte qui fait tourner Keycloak (et les futurs services) le droit de s'y connecter.

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

    # AJOUT : corrige GCP-0014, GCP-0016, GCP-0020, GCP-0022 (logging)
    database_flags {
      name  = "log_temp_files"
      value = "0"
    }
    database_flags {
      name  = "log_connections"
      value = "on"
    }
    database_flags {
      name  = "log_disconnections"
      value = "on"
    }
    database_flags {
      name  = "log_lock_waits"
      value = "on"
    }

    # trivy:ignore:AVD-GCP-0017
    # IP publique acceptee pour ce lab (evite la mise en place d'un VPC peering complet
    # pour l'acces prive Cloud SQL). Connexion protegee par ssl_mode ci-dessous.
    ip_configuration {
      ipv4_enabled = true

      # AJOUT : corrige GCP-0015. ssl_mode remplace require_ssl (deprecie) pour Postgres.
      ssl_mode = "ENCRYPTED_ONLY"
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

# trivy:ignore:AVD-GCP-0006
# SA Compute par defaut utilise volontairement pour ce lab (tous les services Cloud Run
# actuels tournent dessus, faute de SA dedies par service). A revoir si le projet evolue
# vers une vraie mise en prod.
resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_info.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:80844171008-compute@developer.gserviceaccount.com"
}