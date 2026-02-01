variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Firestore region"
  type        = string
  
  # Firestore multi-region options
  validation {
    condition = contains([
      "asia-northeast1",    # 東京
      "us-central1",       # アイオワ 
      "europe-west1",      # ベルギー
      "asia-south1"        # ムンバイ
    ], var.region)
    error_message = "Region must be a valid Firestore location."
  }
}

variable "environment" {
  description = "Environment (dev/prod)"
  type        = string
  default     = "dev"
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}