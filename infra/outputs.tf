output "api_url" {
  description = "Cloud Run API URL"
  value       = module.cloud_run.service_url
}

output "firestore_database" {
  description = "Firestore database name"
  value       = module.firestore.database_name
}

output "images_bucket" {
  description = "Images bucket name"  
  value       = module.storage.images_bucket_name
}

output "images_public_url" {
  description = "Public URL for images"
  value       = module.storage.images_public_url
}

output "project_info" {
  description = "Project information"
  value = {
    project_id  = var.project_id
    region      = var.region
    environment = var.environment
  }
}