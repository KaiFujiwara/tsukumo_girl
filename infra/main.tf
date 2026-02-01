# Provider設定
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# Local values
locals {
  app_name = "${var.app_name}-${var.environment}"
  
  labels = {
    environment = var.environment
    app         = var.app_name
    managed-by  = "terraform"
  }
}

# Google Cloud APIs有効化
resource "google_project_service" "apis" {
  for_each = toset([
    "run.googleapis.com",                # Cloud Run
    "cloudbuild.googleapis.com",         # Cloud Build
    "artifactregistry.googleapis.com",   # Artifact Registry
    "storage.googleapis.com",            # Cloud Storage
    "firebase.googleapis.com",           # Firebase
    "identitytoolkit.googleapis.com",    # Firebase Auth
    "firestore.googleapis.com",          # Firestore
  ])
  
  project = var.project_id
  service = each.value
  
  disable_on_destroy = false
}

# Artifact Registry (コンテナイメージ用)
resource "google_artifact_registry_repository" "main" {
  location      = var.region
  repository_id = "${local.app_name}-repo"
  description   = "Docker repository for ${local.app_name}"
  format        = "DOCKER"
  
  labels = local.labels
  
  depends_on = [google_project_service.apis]
}

# Firestore Database
module "firestore" {
  source = "./modules/firestore"
  
  project_id   = var.project_id
  region       = var.region
  environment  = var.environment
  labels       = local.labels
}

# Cloud Storage (画像保存のみ)
module "storage" {
  source = "./modules/storage"
  
  project_id      = var.project_id
  region          = var.region
  app_name        = local.app_name
  storage_class   = var.storage_class
  labels          = local.labels
}

# Firebase Authentication
module "auth" {
  source = "./modules/auth"
  
  project_id = var.project_id
  app_name   = local.app_name
}

# Cloud Run API
module "cloud_run" {
  source = "./modules/cloud-run"
  
  project_id         = var.project_id
  region            = var.region
  app_name          = local.app_name
  
  # Cloud Run設定
  cpu               = var.cloud_run_cpu
  memory            = var.cloud_run_memory
  min_instances     = var.cloud_run_min_instances
  max_instances     = var.cloud_run_max_instances
  
  # 環境変数
  environment_variables = {
    ENV                 = var.environment
    FIRESTORE_PROJECT_ID = var.project_id
    IMAGES_BUCKET       = module.storage.images_bucket_name
    FIREBASE_PROJECT_ID = var.project_id
  }
  
  labels = local.labels
  
  depends_on = [
    google_project_service.apis,
    google_artifact_registry_repository.main
  ]
}