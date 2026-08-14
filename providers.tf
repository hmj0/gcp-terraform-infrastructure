terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
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




