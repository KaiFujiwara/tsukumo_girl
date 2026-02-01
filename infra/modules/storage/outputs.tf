output "images_bucket_name" {
  description = "Images bucket name"
  value       = google_storage_bucket.images.name
}

output "images_bucket_url" {
  description = "Images bucket URL"  
  value       = google_storage_bucket.images.url
}

output "images_public_url" {
  description = "Public URL for images"
  value       = "https://storage.googleapis.com/${google_storage_bucket.images.name}"
}