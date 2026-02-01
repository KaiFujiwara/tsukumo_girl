terraform {
  required_version = ">= 1.5"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }

  # Terraform Cloudまたはローカル state
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "barcode-ai-kanojo"
  # }
}