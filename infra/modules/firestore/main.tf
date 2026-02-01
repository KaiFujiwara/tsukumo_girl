# Firestore Database
resource "google_firestore_database" "database" {
  provider    = google-beta
  project     = var.project_id
  name        = "(default)"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"
  
  # 削除保護（本番環境では有効化推奨）
  deletion_policy = var.environment == "prod" ? "ABANDON" : "DELETE"
}

# Firestore セキュリティルール
resource "google_firestore_document" "security_rules" {
  provider    = google-beta
  project     = var.project_id
  database    = google_firestore_database.database.name
  collection  = "security_rules"
  document_id = "default"
  
  fields = jsonencode({
    rules = {
      stringValue = templatefile("${path.module}/firestore.rules", {
        environment = var.environment
      })
    }
  })
}

# Firestore インデックス設定
resource "google_firestore_index" "user_characters_affection" {
  provider = google-beta
  project  = var.project_id
  database = google_firestore_database.database.name
  
  collection = "user_characters"
  
  fields {
    field_path = "character_id"
    order      = "ASCENDING"
  }
  
  fields {
    field_path = "affection_level"
    order      = "DESCENDING"
  }
  
  query_scope = "COLLECTION"
}

resource "google_firestore_index" "messages_conversation" {
  provider = google-beta
  project  = var.project_id
  database = google_firestore_database.database.name
  
  collection = "messages"
  
  fields {
    field_path = "user_id"
    order      = "ASCENDING"
  }
  
  fields {
    field_path = "character_id" 
    order      = "ASCENDING"
  }
  
  fields {
    field_path = "created_at"
    order      = "DESCENDING"
  }
  
  query_scope = "COLLECTION"
}