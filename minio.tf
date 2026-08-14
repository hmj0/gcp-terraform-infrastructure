




resource "google_cloud_run_v2_service" "minio_hmj01" {
  name                = "minio-service-hmj01"
  location            = var.project_info.project_region
  deletion_protection = false

  description = "MinIO on Cloud Run. Port 9000 is exposed to provide the S3 API. The administration console on port 9001 is not directly exposed because Cloud Run supports one public container port per service."

  ingress = "INGRESS_TRAFFIC_ALL"

  template {

    scaling {
      min_instance_count = 1
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


resource "minio_s3_bucket" "temporary_data" {
  for_each = toset(var.buckets_name)

  bucket        = each.value
  acl           = "private"
  force_destroy = true
}