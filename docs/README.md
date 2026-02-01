# Barcode AI Kanojo (バーコードAI彼女) - プロジェクトドキュメント

## 概要

バーコードAI彼女は、商品のバーコードをスキャンすることで、そのバーコードから決定論的にAI生成された美少女キャラクター画像を生成・表示するモバイルアプリケーションです。

## プロジェクト構成

```
barcode_ai_kanojo/
├── docs/               # プロジェクトドキュメント
├── api/               # Go言語のAPIサーバー
├── native-app/        # React Native/Expoモバイルアプリ
├── compose.yml        # Docker Compose設定
└── README.md         # セットアップ手順
```

## ドキュメント一覧

- [アプリ要件](requirements.md) - 機能要件・非機能要件
- [アーキテクチャ](architecture.md) - システム構成・技術スタック
- [API仕様](api-spec.md) - APIエンドポイント仕様
- [UI/UX設計](ui-design.md) - 画面設計・ユーザー体験
- [開発計画](development-plan.md) - 実装計画・マイルストーン