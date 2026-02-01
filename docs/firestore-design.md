# Firestore データベース設計

## NoSQL設計アプローチ

FirestoreはNoSQLのため、正規化よりも**クエリ最適化**を重視した設計にします。

## コレクション構造

### 1. **users** - ユーザー情報
```javascript
// ドキュメントID: user_id（Firebase Auth UID）
{
  username: "player123",
  email: "user@example.com", // optional
  created_at: Timestamp,
  last_login_at: Timestamp,
  is_active: true,
  
  // ゲーム統計（非正規化）
  stats: {
    total_characters: 5,
    total_scan_count: 120,
    owned_characters: 2
  }
}
```

### 2. **characters** - キャラクター情報
```javascript
// ドキュメントID: character_id（自動生成）
{
  barcode: "4901234567890",
  barcode_hash: "abc123...", // インデックス用ハッシュ
  
  // キャラクター基本情報
  name: "桜花ちゃん",
  age: 18,
  personality: {
    cheerfulness: 75,
    shyness: 40,
    intelligence: 85,
    playfulness: 60,
    loyalty: 90,
    independence: 50
  },
  appearance_description: "ピンクの髪で...",
  
  // 画像情報
  image_url: "https://storage.googleapis.com/.../abc123.jpg",
  image_generation_seed: 1234567890,
  generation_status: "completed", // pending/generating/completed/failed
  
  // 所有者情報（非正規化）
  current_owner: {
    user_id: "user123",
    affection_level: 85,
    owned_since: Timestamp
  },
  
  // 統計情報
  stats: {
    first_scanned_at: Timestamp,
    scan_count: 15,
    total_interactions: 250
  },
  
  created_at: Timestamp,
  updated_at: Timestamp
}
```

### 3. **user_characters** - ユーザー・キャラクター関係
```javascript
// ドキュメントID: "{user_id}_{character_id}"
{
  user_id: "user123",
  character_id: "char456",
  
  // 関係性
  is_owner: false, // true: カノジョ, false: 知り合い
  affection_level: 45, // 0-100
  relationship_status: "friend", // stranger/friend/lover/partner
  
  // 相互作用履歴
  first_met_at: Timestamp,
  last_interaction_at: Timestamp,
  total_messages: 127,
  total_time_spent: 3600, // 秒単位
  
  // 最新会話情報（非正規化）
  latest_message: {
    content: "また明日話そうね！",
    timestamp: Timestamp,
    sender: "character"
  },
  
  created_at: Timestamp,
  updated_at: Timestamp
}
```

### 4. **messages** - 会話履歴
```javascript
// ドキュメントID: 自動生成
// サブコレクション: conversations/{user_id}_{character_id}/messages
{
  user_id: "user123",
  character_id: "char456",
  
  content: "こんにちは！",
  sender_type: "user", // "user" | "character"
  message_type: "text", // "text" | "image" | "system"
  
  // ゲーム要素
  affection_change: 2, // このメッセージによる好感度変化
  
  created_at: Timestamp
}
```

### 5. **affection_logs** - 好感度変動履歴
```javascript
// ドキュメントID: 自動生成
// サブコレクション: user_characters/{relation_id}/affection_logs
{
  change_amount: 3,
  previous_level: 42,
  new_level: 45,
  change_reason: "message", // "message" | "daily_bonus" | "event"
  
  // 関連データ
  message_content: "優しい言葉をかけた", // optional
  
  created_at: Timestamp
}
```

### 6. **ownership_history** - 所有権移転履歴
```javascript
// ドキュメントID: 自動生成
// サブコレクション: characters/{character_id}/ownership_history
{
  previous_owner_id: "user123",
  new_owner_id: "user456",
  
  previous_affection: 78,
  winning_affection: 82,
  
  // 移転時のキャラクター状態
  character_snapshot: {
    name: "桜花ちゃん",
    relationship_status: "lover"
  },
  
  transferred_at: Timestamp
}
```

## クエリパターンと最適化

### 頻繁なクエリ
1. **キャラクター検索（バーコード）**
```javascript
// 複合インデックス: barcode_hash (ASC)
db.collection('characters')
  .where('barcode_hash', '==', hash)
  .limit(1)
```

2. **ユーザーの所有キャラクター一覧**
```javascript
// 複合インデックス: user_id (ASC), is_owner (ASC)
db.collection('user_characters')
  .where('user_id', '==', userId)
  .where('is_owner', '==', true)
```

3. **キャラクター別好感度ランキング**
```javascript
// 複合インデックス: character_id (ASC), affection_level (DESC)
db.collection('user_characters')
  .where('character_id', '==', characterId)
  .orderBy('affection_level', 'desc')
  .limit(10)
```

4. **会話履歴取得**
```javascript
// サブコレクション（自動インデックス）
db.collection('conversations')
  .doc(`${userId}_${characterId}`)
  .collection('messages')
  .orderBy('created_at', 'desc')
  .limit(50)
```

## セキュリティルール

### データアクセス制御
- **ユーザーデータ**: 自分のデータのみアクセス可能
- **キャラクターデータ**: 読み取りのみ許可
- **関係データ**: 自分に関連するもののみ
- **メッセージ**: 自分の会話のみ

### API経由制御
- 書き込み操作はAPI経由のみ
- クライアント直接書き込み禁止
- 整合性保証のためサーバーサイド処理

## コスト最適化

### Firestore無料枠（月間）
- **読み取り**: 50,000回
- **書き込み**: 20,000回  
- **削除**: 20,000回
- **ストレージ**: 1GB

### 最適化戦略
1. **クエリ回数削減**: 非正規化でJOIN回避
2. **インデックス最小化**: 必要なもののみ作成
3. **サブコレクション活用**: 大量データは階層化
4. **キャッシュ活用**: 頻繁アクセスデータ

## マイグレーション戦略

### 初期データセットアップ
```javascript
// Firebase Admin SDKでセットアップ
const setupFirestore = async () => {
  // コレクション作成
  // インデックス作成（terraform実行）  
  // セキュリティルール適用
}
```

### データ移行ツール
- **バッチ処理**: 大量データ移行
- **増分同期**: 段階的移行
- **検証ツール**: データ整合性チェック