# novel-recommender

AIによる小説推薦システム。

複数のAPIから小説情報を収集してデータベースに保存し、
キーワード検索とAIによる意味的な推薦（ベクトル検索）を行う。

## 技術スタック

- バックエンド: Hono on Cloudflare Workers
- データベース: Neon (PostgreSQL) + pgvector
- ORM: Drizzle ORM
- Embedding: Gemini embedding-001 (768次元)
- 定期実行: Cloudflare Workers Cron Trigger

## 開発状況

現在、技術選定を終えて環境構築中。

## 開発フロー

Issue → ブランチ作成 → PR作成 → merge の流れで開発する。
mainブランチは常に動作する状態を保ち、作業は必ずブランチ上で行う。
