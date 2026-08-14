
variable "project_info" {
  description = "INFORMATION SUR LE PROJET"
  type = object({
    project_id     = string
    project_region = string
    project_zone   = string
  })

  default = {
    project_id     = "agentic-ai-learning-486e"
    project_region = "europe-west1"
    project_zone   = "europe-west1-a"
  }

}


variable "MINIO_ROOT_USER" {
  type    = string
  default = "minioadmin"

}

variable "MINIO_ROOT_PASSWORD" {
  type      = string
  sensitive = true

}

variable "buckets_name" {

  type    = list(string)
  default = ["rawdata", "processeddata", "concat", "export"]

}

variable "KEYCLOAK_ADMIN" {
  type    = string
  default = "keycloackadmin"

}

variable "KEYCLOAK_ADMIN_PASSWORD" {
  type      = string
  sensitive = true

}

# DECLARATION DES APIS A ACTIVER
