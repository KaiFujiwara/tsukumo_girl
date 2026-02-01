# インフラ構成

## Google Cloud Platform構成

### 概要
全てのリソースをGoogle Cloudで統一し、コスト最適化を重視した構成。

## サービス構成

### 1. **Cloud Run** - APIサーバー
```
┌─────────────────┐
│   Cloud Run     │
│  (Go API)       │
│  - auto scaling │
│  - pay per use  │
└─────────────────┘
```

**メリット**:
- サーバーレス（リクエスト時のみ課金）
- 自動スケーリング
- Dockerデプロイ対応
- 低コスト（リクエストベース課金）

### 2. **Cloud SQL (PostgreSQL)** - メインデータベース
```
┌─────────────────┐
│   Cloud SQL     │
│  (PostgreSQL)   │
│  - db-f1-micro  │  ← 最安プラン
│  - 10GB storage │
└─────────────────┘
```

**データモデル**:
- ユーザー情報
- キャラクター情報
- 所有関係
- 好感度データ
- 会話履歴

**コスト最適化**:
- `db-f1-micro` インスタンス（月額約$7）
- 自動バックアップ
- 必要時のスケールアップ対応

### 3. **Cloud Storage** - 画像・アセット保存
```
┌─────────────────┐
│ Cloud Storage   │
│  - Standard     │
│  - CDN enabled  │
└─────────────────┘
```

**用途**:
- AI生成キャラクター画像
- アプリアセット
- バックアップデータ

### 4. **Cloud Memory Store (Redis)** - キャッシュ
```
┌─────────────────┐
│ Memory Store    │
│  (Redis)        │
│  - Basic tier   │  ← 最安プラン
│  - 1GB memory   │
└─────────────────┘
```

**用途**:
- API応答キャッシュ
- セッション管理
- 頻繁アクセスデータ

## 外部サービス連携

### AI画像生成
**候補1: OpenAI DALL-E 3**
- 価格: $0.04/画像 (1024×1024)
- 品質: 非常に高い
- 日本語プロンプト対応

**候補2: Stability AI**
- 価格: $0.004/画像
- 品質: 高い
- コスト重視の場合

**候補3: Google Vertex AI (Imagen)**
- Google Cloud統合
- 価格: 要確認
- 同一プラットフォームのメリット

### AI会話生成
**Claude 3.5 Sonnet (Anthropic)**
- キャラクター別の性格設定
- 自然な日本語会話
- コンテキスト保持

**代替: Gemini Pro (Google)**
- Google Cloud統合
- コスト優位性
- 日本語対応

## Terraform構成

### ディレクトリ構成
```
terraform/
├── main.tf              # メインリソース定義
├── variables.tf         # 変数定義
├── outputs.tf          # 出力値定義
├── versions.tf         # プロバイダー設定
├── environments/       # 環境別設定
│   ├── dev/
│   │   └── terraform.tfvars
│   └── prod/
│       └── terraform.tfvars
└── modules/            # 再利用可能モジュール
    ├── cloud-run/
    ├── cloud-sql/
    └── storage/
```

### 主要リソース
```hcl
# Cloud Run
resource "google_cloud_run_service" "api" {
  name     = "barcode-ai-kanojo-api"
  location = var.region
  
  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/api:latest"
        
        env {
          name  = "DB_CONNECTION_NAME"
          value = google_sql_database_instance.main.connection_name
        }
      }
    }
  }
}

# Cloud SQL
resource "google_sql_database_instance" "main" {
  name             = "barcode-ai-kanojo-db"
  database_version = "POSTGRES_15"
  region           = var.region
  
  settings {
    tier = "db-f1-micro"  # 最安プラン
    
    disk_size = 10
    disk_type = "PD_HDD"  # HDDで更にコスト削減
  }
}
```

## コスト見積もり（月額）

### 開発環境
- **Cloud Run**: $0-5（リクエスト少）
- **Cloud SQL**: $7（db-f1-micro）
- **Cloud Storage**: $1-2
- **Memory Store**: $10（Basic 1GB）
- **AI生成**: $5-20（利用量次第）
- **合計**: 約$25-45/月

### 本番環境（スケール後）
- **Cloud Run**: $20-50（トラフィック増）
- **Cloud SQL**: $50-100（スケールアップ）
- **その他**: $20-30
- **AI生成**: $50-200（利用量次第）
- **合計**: 約$150-400/月

## セキュリティ

### ネットワーク
- VPC内でのサービス間通信
- Cloud SQL Private IP
- Cloud Run専用コネクター

### 認証・認可
- Firebase Authentication（簡易認証）
- IAM適切な権限設定
- API キー管理（Secret Manager）

### データ保護
- 暗号化（保存時・転送時）
- バックアップ戦略
- 個人情報の最小化