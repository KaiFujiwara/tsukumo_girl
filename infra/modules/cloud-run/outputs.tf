output "service_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_v2_service.api.uri
}

output "service_name" {
  description = "Cloud Run service name"
  value       = google_cloud_run_v2_service.api.name
}

output "service_id" {
  description = "Cloud Run service ID"
  value       = google_cloud_run_v2_service.api.id
}