terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "~> 3.0"
    }
  }

  backend "gcs" {
    bucket = "terraform-bucket-state-hmj01"
    prefix = "terraform/state"
    
  }
}

provider "google" {
  project = var.project_info.project_id
  region  = var.project_info.project_region
  zone    = var.project_info.project_zone
}

provider "minio" {
  // required
  minio_server   = trimprefix(google_cloud_run_v2_service.minio_hmj01.uri, "https://")
  minio_user     = var.MINIO_ROOT_USER
  minio_password = var.MINIO_ROOT_PASSWORD
  minio_region   = var.project_info.project_region
  minio_ssl      = true
}


