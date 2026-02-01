# データベース設計

## ERD概要

```
[Users] ←→ [User_Characters] ←→ [Characters] ←→ [Messages]
    ↓             ↓                    ↓
[User_Sessions] [Affection_Logs] [Character_Stats]
```

## テーブル設計

### 1. **users** - ユーザー情報
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    
    -- ゲーム関連
    total_characters INTEGER DEFAULT 0,
    total_scan_count INTEGER DEFAULT 0
);
```

### 2. **characters** - キャラクター情報
```sql
CREATE TABLE characters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barcode VARCHAR(50) UNIQUE NOT NULL, -- バーコード文字列
    barcode_hash VARCHAR(64) UNIQUE NOT NULL, -- ハッシュ値（検索用）
    
    -- キャラクター基本情報
    name VARCHAR(100) NOT NULL,
    age INTEGER,
    personality JSONB, -- 性格パラメータ
    appearance_description TEXT,
    
    -- 画像関連
    image_url VARCHAR(500),
    image_generation_seed INTEGER NOT NULL,
    generation_status VARCHAR(20) DEFAULT 'pending', -- pending/generating/completed/failed
    
    -- システム情報
    first_scanned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    scan_count INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_generation_status 
        CHECK (generation_status IN ('pending', 'generating', 'completed', 'failed'))
);
```

### 3. **user_characters** - ユーザー・キャラクター関係
```sql
CREATE TABLE user_characters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    character_id UUID NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    
    -- 所有権・好感度
    is_owner BOOLEAN DEFAULT false, -- 現在の所有者かどうか
    affection_level INTEGER DEFAULT 0, -- 好感度 (0-100)
    relationship_status VARCHAR(20) DEFAULT 'stranger', -- stranger/friend/lover/partner
    
    -- 相互作用履歴
    first_met_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_interaction_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    total_messages INTEGER DEFAULT 0,
    total_time_spent INTEGER DEFAULT 0, -- 秒単位
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, character_id),
    CONSTRAINT valid_relationship_status 
        CHECK (relationship_status IN ('stranger', 'friend', 'lover', 'partner')),
    CONSTRAINT valid_affection_level 
        CHECK (affection_level >= 0 AND affection_level <= 100)
);
```

### 4. **messages** - 会話履歴
```sql
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    character_id UUID NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    
    -- メッセージ内容
    content TEXT NOT NULL,
    sender_type VARCHAR(10) NOT NULL, -- 'user' or 'character'
    message_type VARCHAR(20) DEFAULT 'text', -- text/image/system
    
    -- ゲーム要素
    affection_change INTEGER DEFAULT 0, -- このメッセージによる好感度変化
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT valid_sender_type CHECK (sender_type IN ('user', 'character')),
    CONSTRAINT valid_message_type CHECK (message_type IN ('text', 'image', 'system'))
);
```

### 5. **affection_logs** - 好感度変動履歴
```sql
CREATE TABLE affection_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    character_id UUID NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    
    -- 変動内容
    change_amount INTEGER NOT NULL, -- 変動量（+-）
    previous_level INTEGER NOT NULL,
    new_level INTEGER NOT NULL,
    change_reason VARCHAR(50) NOT NULL, -- 'message', 'daily_bonus', 'event' etc.
    
    -- 関連データ
    message_id UUID REFERENCES messages(id),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 6. **character_ownership_history** - 所有権移転履歴
```sql
CREATE TABLE character_ownership_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    character_id UUID NOT NULL REFERENCES characters(id) ON DELETE CASCADE,
    
    -- 移転情報
    previous_owner_id UUID REFERENCES users(id) ON DELETE SET NULL,
    new_owner_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 移転時の状態
    previous_affection INTEGER,
    winning_affection INTEGER NOT NULL,
    
    transferred_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## インデックス設計

```sql
-- 高頻度クエリ用インデックス
CREATE INDEX idx_characters_barcode_hash ON characters(barcode_hash);
CREATE INDEX idx_user_characters_user_owner ON user_characters(user_id, is_owner);
CREATE INDEX idx_user_characters_character ON user_characters(character_id);
CREATE INDEX idx_messages_conversation ON messages(user_id, character_id, created_at);
CREATE INDEX idx_affection_logs_user_character ON affection_logs(user_id, character_id);

-- 所有者検索用
CREATE INDEX idx_user_characters_owner ON user_characters(character_id) WHERE is_owner = true;

-- 好感度ランキング用
CREATE INDEX idx_user_characters_affection ON user_characters(character_id, affection_level DESC);
```

## データ整合性

### 制約事項
1. **1キャラクター1所有者**: `user_characters`テーブルで`is_owner=true`は1レコードのみ
2. **好感度範囲**: 0-100の範囲内
3. **バーコード一意性**: 同じバーコードのキャラクターは1体のみ

### トリガー
```sql
-- 所有権移転時の自動更新
CREATE OR REPLACE FUNCTION update_character_ownership()
RETURNS TRIGGER AS $$
BEGIN
    -- 新しい所有者設定時、他の所有者を無効化
    IF NEW.is_owner = true THEN
        UPDATE user_characters 
        SET is_owner = false, updated_at = NOW()
        WHERE character_id = NEW.character_id 
        AND user_id != NEW.user_id 
        AND is_owner = true;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_ownership
    BEFORE UPDATE OF is_owner ON user_characters
    FOR EACH ROW
    EXECUTE FUNCTION update_character_ownership();
```

## マイグレーション戦略

### フォルダ構成
```
api/migrations/
├── 001_create_users.up.sql
├── 001_create_users.down.sql
├── 002_create_characters.up.sql
├── 002_create_characters.down.sql
├── 003_create_user_characters.up.sql
├── 003_create_user_characters.down.sql
└── ...
```

### ツール
- **golang-migrate**: Goのマイグレーションツール
- **バージョン管理**: Git + セマンティックバージョニング