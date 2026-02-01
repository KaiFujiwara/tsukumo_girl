variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
  default     = "asia-northeast1" # 東京リージョン
}

variable "environment" {
  description = "Environment (dev/prod)"
  type        = string
  default     = "dev"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "barcode-ai-kanojo"
}

# Cloud Run設定
variable "cloud_run_cpu" {
  description = "Cloud Run CPU allocation"
  type        = string
  default     = "1" # 最小構成
}

variable "cloud_run_memory" {
  description = "Cloud Run Memory allocation"
  type        = string
  default     = "512Mi" # 最小構成
}

variable "cloud_run_min_instances" {
  description = "Cloud Run minimum instances"
  type        = number
  default     = 0 # コスト削減のため0（コールドスタート許容）
}

variable "cloud_run_max_instances" {
  description = "Cloud Run maximum instances"
  type        = number
  default     = 10
}

# Storage設定
variable "storage_class" {
  description = "Cloud Storage class"
  type        = string
  default     = "STANDARD" # 5GB無料枠
}

# Firebase設定
variable "firebase_project_id" {
  description = "Firebase Project ID (usually same as project_id)"
  type        = string
  default     = ""
}

# AI設定
variable "ai_provider" {
  description = "AI Image generation provider"
  type        = string
  default     = "stability-ai" # コスト重視
  
  validation {
    condition = contains(["openai", "stability-ai", "vertex-ai"], var.ai_provider)
    error_message = "AI provider must be one of: openai, stability-ai, vertex-ai"
  }
}