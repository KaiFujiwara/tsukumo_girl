# Cloud Run Service
resource "google_cloud_run_v2_service" "api" {
  name     = "${var.app_name}-api"
  location = var.region
  
  template {
    # スケーリング設定（コスト最適化）
    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }
    
    containers {
      # イメージ（CI/CDで更新）
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.app_name}-repo/api:latest"
      
      # リソース設定（最小構成）
      resources {
        limits = {
          cpu    = var.cpu
          memory = var.memory
        }
        cpu_idle = true # アイドル時CPU削減
      }
      
      # ポート設定
      ports {
        container_port = 8080
      }
      
      # 環境変数
      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }
      
      # ヘルスチェック
      startup_probe {
        http_get {
          path = "/health"
        }
        initial_delay_seconds = 10
        timeout_seconds      = 1
        period_seconds       = 3
        failure_threshold    = 5
      }
      
      liveness_probe {
        http_get {
          path = "/health"
        }
        initial_delay_seconds = 15
        timeout_seconds      = 1
        period_seconds       = 15
        failure_threshold    = 3
      }
    }
    
    # タイムアウト設定
    timeout = "300s"
  }
  
  # トラフィック設定
  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
  
  labels = var.labels
}

# Cloud Run IAM（パブリックアクセス許可）
resource "google_cloud_run_service_iam_binding" "public" {
  location = google_cloud_run_v2_service.api.location
  service  = google_cloud_run_v2_service.api.name
  role     = "roles/run.invoker"
  members  = ["allUsers"]
}