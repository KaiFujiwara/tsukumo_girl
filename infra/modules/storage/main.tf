# AI生成画像用 Cloud Storage  
resource "google_storage_bucket" "images" {
  name     = "${var.app_name}-images"
  location = var.region
  
  storage_class = var.storage_class
  
  # パブリック読み取り設定
  uniform_bucket_level_access = true
  
  # CORS設定（Web/モバイルアクセス用）
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
  
  labels = var.labels
}

# 画像バケットのパブリック読み取り許可
resource "google_storage_bucket_iam_binding" "images_public" {
  bucket = google_storage_bucket.images.name
  role   = "roles/storage.objectViewer"
  members = [
    "allUsers",
  ]
}