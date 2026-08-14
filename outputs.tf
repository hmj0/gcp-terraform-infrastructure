output "project_describe" {
  description = "INFORMATION SUR LE PROJET"

  value = {
    project_id     = var.project_info.project_id
    project_region = var.project_info.project_region
  project_zone = var.project_info.project_zone }
}



