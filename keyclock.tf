


resource "google_cloud_run_v2_service" "keyclock_hmj01" {
  name                = "keyclock-service-hmj01"
  location            = var.project_info.project_region
  deletion_protection = false

  description = "KEYCLOCK"

  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "keycloak/keycloak:26.7"

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
        name  = "KC_HEALTH_ENABLED" # autorise l'ausage de ces healths les health possibles /health /health/live /health/ready /health/started
        value = "true"
      }

      # Vérifie que Keycloak a terminé son démarrage avant que Cloud Run
      # considère le conteneur comme opérationnel. La sonde tolère les
      # démarrages longs en effectuant une vérification HTTP toutes les 10s,
      # pendant environ 2 minutes maximum.
      # la startup probe permet à Cloud Run de vérifier que Keycloak est réellement démarré et prêt à fonctionner,
      # plutôt que de considérer le conteneur comme opérationnel dès son lancement.
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
  }
}

resource "google_cloud_run_v2_service_iam_member" "keycloak_public" {
  project  = var.project_info.project_id
  location = var.project_info.project_region
  name     = google_cloud_run_v2_service.keyclock_hmj01.name

  role   = "roles/run.invoker"
  member = "allUsers"
}

