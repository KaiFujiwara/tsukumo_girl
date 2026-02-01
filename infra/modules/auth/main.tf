# Firebase Authentication（無料枠活用）
# 注意: FirebaseはTerraformで完全管理困難な部分あり
# 主要設定はFirebase Consoleで手動設定推奨

# Firebase project（既存プロジェクトを使用する場合）
data "google_firebase_project" "default" {
  provider = google-beta
  project  = var.project_id
}

# Firebase Authentication有効化
resource "google_identity_platform_config" "auth" {
  provider = google-beta
  project  = var.project_id
  
  # 匿名認証有効化（個人開発向け）
  sign_in {
    anonymous {
      enabled = true
    }
    
    # 将来的にEmail認証も追加可能
    email {
      enabled           = true
      password_required = true
    }
  }
  
  # ブロック機能（スパム対策）
  blocking_functions {
    triggers {
      event_type = "beforeSignIn"
      function_uri = "" # Cloud Functionsで実装可能
    }
  }
}

# Firebase Auth設定
resource "google_identity_platform_project_default_config" "default" {
  provider = google-beta
  project  = var.project_id
  
  sign_in {
    anonymous {
      enabled = true
    }
  }
  
  depends_on = [google_identity_platform_config.auth]
}