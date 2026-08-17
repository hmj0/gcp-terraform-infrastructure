resource "google_cloud_run_v2_service" "keyclock_hmj01" {
  name                = "keyclock-service-hmj01"
  location            = var.project_info.project_region
  deletion_protection = false
  description         = "KEYCLOCK"
  ingress             = "INGRESS_TRAFFIC_ALL"

  scaling {
    max_instance_count = 1
    min_instance_count = 1
  }

  template {
    containers {
      name  = "keycloak"
      image = "keycloak/keycloak:26.7"

      depends_on = ["postgres"] # attend que le sidecar postgres soit pret

      args = ["start-dev"]

      ports {
        container_port = 8080
      }

      env {
        name  = "KEYCLOAK_ADMIN"
        value = var.KEYCLOAK_ADMIN
      }
      env {
        name  = "KEYCLOAK_ADMIN_PASSWORD"
        value = var.KEYCLOAK_ADMIN_PASSWORD
      }
      env {
        name  = "KC_PROXY_HEADERS"
        value = "xforwarded"
      }
      env {
        name  = "KC_HEALTH_ENABLED"
        value = "true"
      }
      env {
        name  = "KC_DB"
        value = "postgres"
      }
      env {
        name  = "KC_DB_URL"
        value = "jdbc:postgresql://localhost:5432/keycloak"
      }
      env {
        name  = "KC_DB_USERNAME"
        value = "app_user"
      }
      env {
        name  = "KC_DB_PASSWORD"
        value = var.POSTGRES_PASSWORD
      }

      startup_probe {
        http_get {
          path = "/health/started"
          port = 9000
        }
        timeout_seconds   = 10
        period_seconds    = 10
        failure_threshold = 12
      }

      resources {
        limits = {
          cpu    = "2"
          memory = "4Gi"
        }
      }
    }

    containers {
      name  = "postgres"
      image = "postgres:16-alpine"

      env {
        name  = "POSTGRES_DB"
        value = "keycloak"
      }
      env {
        name  = "POSTGRES_USER"
        value = "app_user"
      }
      env {
        name  = "POSTGRES_PASSWORD"
        value = var.POSTGRES_PASSWORD
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "1Gi"
        }
      }

      # obligatoire : Cloud Run exige qu'un conteneur cible par depends_on ait sa propre startup_probe
      startup_probe {
        tcp_socket {
          port = 5432
        }
        initial_delay_seconds = 2
        period_seconds        = 3
        failure_threshold     = 10
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "keycloak_public" {
  project  = var.project_info.project_id
  location = var.project_info.project_region
  name     = google_cloud_run_v2_service.keyclock_hmj01.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}