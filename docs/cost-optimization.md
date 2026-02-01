# コスト最適化戦略

## 個人開発向け激安構成

### 🆓 完全無料構成（Phase 1）

#### Supabase + Vercel
```
月額コスト: $0

┌─────────────────┐
│     Vercel      │  ← API デプロイ（無料）
│  (Edge Functions│     月100万実行無料
│   or Serverless)│
└─────────────────┘
         ↓
┌─────────────────┐
│   Supabase      │  ← $0（無料枠）
│  - PostgreSQL   │     500MB + 5万ユーザー
│  - Auth         │     リアルタイム機能
│  - Storage      │     1GB ストレージ
└─────────────────┘
```

**制限事項**:
- DB容量: 500MB
- ユーザー数: 50,000
- ストレージ: 1GB
- リクエスト: 制限あり

#### 技術スタック変更
- **Go → Node.js/TypeScript**: Vercel対応
- **PostgreSQL**: Supabase提供
- **認証**: Supabase Auth

### 💸 低コスト構成（Phase 2）- 月額$3-8

#### Cloud Run + SQLite
```
┌─────────────────┐
│   Cloud Run     │  ← $0-3（無料枠+α）
│  (Go API)       │     月200万リクエスト無料
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
│ (認証のみ)       │
└─────────────────┘
```

**SQLite構成の利点**:
- サーバー管理不要
- バックアップ簡単（ファイルコピー）
- トランザクション性能良い
- 個人開発規模なら十分

### 🎯 推奨アプローチ: 段階的移行

#### Step 1: Supabase で MVP
```bash
# Supabase セットアップ
npm install @supabase/supabase-js
```

#### Step 2: Cloud Run + SQLite
```bash
# 成長後にCloud Run移行
# SQLiteをCloud Storageでバックアップ
```

#### Step 3: 本格運用
```bash
# ユーザー増加後にCloud SQL移行
```

## AI画像生成コスト削減

### 1. **キャッシュ戦略**
- 生成済み画像の永続保存
- 重複生成の完全回避
- CDN活用（Cloudflare無料）

### 2. **バッチ生成**
- 人気商品の事前生成
- オフピーク時間での生成
- 生成コストの平準化

### 3. **安価なAI サービス**
```
OpenAI DALL-E 3: $0.04/画像
Stability AI:    $0.004/画像  ← 10倍安い
Local Stable Diffusion: ほぼ無料（GPU必要）
```

## 実際のコスト見積もり

### Supabase構成（完全無料）
```
- API: $0
- DB: $0（500MB以下）
- Auth: $0（5万ユーザー以下）
- Storage: $0（1GB以下）
- AI生成: $2-10（100-500キャラクター）
合計: $2-10/月
```

### Cloud Run + SQLite構成
```
- Cloud Run: $0-3（無料枠）
- Cloud Storage: $0-2（無料枠+α）
- Firebase Auth: $0
- AI生成: $2-10
合計: $2-15/月
```

## 開発段階での節約法

### 1. **開発中はローカル**
```bash
# ローカル開発
docker compose up --build
# → クラウドコスト $0
```

### 2. **AI画像はプレースホルダー**
```go
// 開発中はランダム画像
imageURL := "https://picsum.photos/seed/" + barcode + "/800/1200"
// → AI生成コスト $0
```

### 3. **必要最小限の機能から**
- まずバーコード→画像のみ
- チャット機能は後回し
- ユーザー管理は簡易版

どの構成から始めますか？**Supabase完全無料**がおすすめです！

<function_calls>
<invoke name="TodoWrite">
<parameter name="todos">[{"id": "1", "content": "\u30b3\u30b9\u30c8\u6700\u9069\u5316\u6848\u3092\u691c\u8a0e", "status": "completed"}, {"id": "2", "content": "\u7121\u6599\u67a0\u3092\u6d3b\u7528\u3057\u305f\u69cb\u6210\u3092\u63d0\u6848", "status": "completed"}, {"id": "3", "content": "\u30a4\u30f3\u30d5\u30e9\u30c9\u30ad\u30e5\u30e1\u30f3\u30c8\u3092\u66f4\u65b0", "status": "completed"}]