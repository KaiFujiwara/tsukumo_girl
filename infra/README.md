# インフラ構成（Terraform）

## 構成概要

Google Cloud Always Free Tierを最大活用した激安構成：

```
月額コスト: $2-8（個人開発規模）

┌─────────────────┐
│   Cloud Run     │  ← $0（200万リクエスト/月無料）
│  (Go API)       │
│  + SQLite       │
└─────────────────┘
         ↓
┌─────────────────┐
│ Cloud Storage   │  ← $0-2（5GB無料+α）  
│  - SQLite DB    │
│  - 画像キャッシュ │
└─────────────────┘
         ↓
┌─────────────────┐
│ Firebase Auth   │  ← $0（10万ユーザー無料）
└─────────────────┘
```

## セットアップ手順

### 1. 前提条件
```bash
# Terraform インストール
brew install terraform

# Google Cloud SDK
brew install --cask google-cloud-sdk
gcloud auth login
gcloud auth application-default login

# プロジェクト作成（GCP Console）
gcloud projects create your-project-id
gcloud config set project your-project-id
```

### 2. 設定ファイル編集
```bash
# プロジェクトID設定
cd infra/environments/dev
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars の project_id を実際の値に変更
```

### 3. Terraform実行
```bash
cd infra

# 初期化
terraform init

# プラン確認
terraform plan -var-file=environments/dev/terraform.tfvars

# 適用
terraform apply -var-file=environments/dev/terraform.tfvars
```

### 4. API デプロイ
```bash
# Container image build & push
cd ../api
gcloud builds submit --tag asia-northeast1-docker.pkg.dev/YOUR_PROJECT_ID/barcode-ai-kanojo-dev-repo/api:latest .

# Cloud Run デプロイは自動実行される
```

## 環境管理

### 開発環境
```bash
terraform apply -var-file=environments/dev/terraform.tfvars
```

### 本番環境（将来）
```bash
terraform apply -var-file=environments/prod/terraform.tfvars
```

## 運用

### SQLite管理
```bash
# データベースバックアップ
gsutil cp gs://barcode-ai-kanojo-dev-database/main.db ./backup/

# データベース復元
gsutil cp ./backup/main.db gs://barcode-ai-kanojo-dev-database/
```

### モニタリング
- Cloud Run メトリクス（無料）
- Cloud Storage使用量
- Firebase Authentication統計

## セキュリティ

### IAM設定
- Cloud Run: パブリックアクセス（API用）
- Storage: 適切な権限分離
- Firebase: 匿名認証＋将来的にEmail認証

### データ保護
- Cloud Storage暗号化（自動）
- HTTPS強制
- CORS適切設定

## トラブルシューティング

### よくある問題
1. **API有効化エラー**: `terraform plan`前にAPI有効化要確認
2. **権限エラー**: `gcloud auth application-default login`実行
3. **プロジェクトID**: terraform.tfvarsの設定確認