resource "google_cloud_run_v2_service" "ollama_hmj01" {
  name        = "ollama-service-hmj01"
  location    = var.project_info.project_region
  project     = var.project_info.project_id
  description = "Serveur Ollama (modele qwen2.5:7b) sur Cloud Run"

  deletion_protection = false

  template {

    scaling {
      min_instance_count = 1 # evite de re-telecharger le modele a chaque cold start
      max_instance_count = 1 # chaque instance re-telecharge son propre modele, donc pas de scale-out ici
    }

    containers {
      image = "ollama/ollama:latest"

      # remplace l'entrypoint par defaut pour lancer le serveur PUIS tirer le modele
      command = ["/bin/sh", "-c"]
      args = [
        "ollama serve & sleep 5 && ollama pull qwen2.5:7b && wait"
      ]

      ports {
        container_port = 11434
      }

      env {
        name  = "OLLAMA_HOST"
        value = "0.0.0.0:11434"
      }

      env {
        name  = "OLLAMA_KEEP_ALIVE"
        value = "-1" # garde le modele charge en memoire, evite de le recharger entre requetes
      }

      resources {
        limits = {
          cpu    = "4"
          memory = "16Gi"
        }
        cpu_idle          = false # CPU alloue en continu (necessaire, le process tourne en tache de fond)
        startup_cpu_boost = true  # CPU max pendant le pull + chargement du modele
      }

      startup_probe {
        initial_delay_seconds = 10
        timeout_seconds       = 5
        period_seconds        = 10
        failure_threshold     = 60 # laisse le temps au pull du modele (~4,7 Go) de finir
        http_get {
          path = "/"
          port = 11434
        }
      }
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

resource "google_cloud_run_v2_service_iam_member" "ollama_public" {
  location = google_cloud_run_v2_service.ollama_hmj01.location
  name     = google_cloud_run_v2_service.ollama_hmj01.name
  project  = google_cloud_run_v2_service.ollama_hmj01.project
  role     = "roles/run.invoker"
  member   = "allUsers"
}