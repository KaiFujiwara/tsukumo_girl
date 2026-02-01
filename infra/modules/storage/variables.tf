variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "storage_class" {
  description = "Cloud Storage class"
  type        = string
  default     = "STANDARD"
}

variable "cloud_run_service_account" {
  description = "Cloud Run service account email"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}