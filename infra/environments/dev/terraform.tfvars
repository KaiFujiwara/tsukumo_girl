# 開発環境設定
project_id  = "barcodegirls-dev"  # 実際のプロジェクトIDに変更
region      = "asia-northeast1"      # 東京リージョン
environment = "dev"

# 最小リソース構成（コスト削減）
cloud_run_cpu        = "1"
cloud_run_memory     = "512Mi"
cloud_run_min_instances = 0  # コールドスタート許容
cloud_run_max_instances = 3  # 開発環境は小規模

# ストレージ設定
storage_class = "STANDARD"  # 5GB無料枠活用

# AI設定
ai_provider = "stability-ai"  # 最安のAI画像生成