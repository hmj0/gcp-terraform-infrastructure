




resource "google_cloud_run_v2_service" "minio_hmj01" {
  name                = "minio-service-hmj01"
  location            = var.project_info.project_region
  deletion_protection = false

  description = "MinIO on Cloud Run. Port 9000 is exposed to provide the S3 API. The administration console on port 9001 is not directly exposed because Cloud Run supports one public container port per service."

  ingress = "INGRESS_TRAFFIC_ALL"

  template {


    scaling {
      min_instance_count = 1 # evite de re-telecharger le modele a chaque cold start
      max_instance_count = 1 # chaque instance re-telecharge son propre modele, donc pas de scale-out ici
    }

    containers {
      image = "minio/minio:latest"

      args = [
        "server",
        "/data",
        "--console-address",
        ":9001"
      ]

      ports {
        container_port = 9000
      }

      env {
        name  = "MINIO_ROOT_USER"
        value = var.MINIO_ROOT_USER
      }

      env {
        name  = "MINIO_ROOT_PASSWORD"
        value = var.MINIO_ROOT_PASSWORD
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "minio_public" {
  project  = var.project_info.project_id
  location = var.project_info.project_region
  name     = google_cloud_run_v2_service.minio_hmj01.name

  role   = "roles/run.invoker"
  member = "allUsers"
}


resource "null_resource" "minio_buckets" {
  triggers = {
    minio_uri = google_cloud_run_v2_service.minio_hmj01.uri
  }

  provisioner "local-exec" {
    command = <<-EOT
      mc alias set myminio ${google_cloud_run_v2_service.minio_hmj01.uri} minioadmin "${var.MINIO_ROOT_PASSWORD}"
      mc mb --ignore-existing myminio/concat
      mc mb --ignore-existing myminio/rawdata
      mc mb --ignore-existing myminio/processeddata
      mc mb --ignore-existing myminio/export
    EOT
  }

  depends_on = [google_cloud_run_v2_service.minio_hmj01]
}
