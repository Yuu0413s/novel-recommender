-- pgvector拡張の有効化
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE "novels" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "novels_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"source" text NOT NULL,
	"source_id" text NOT NULL,
	"title" text NOT NULL,
	"author" text,
	"description" text,
	"url" text,
	"genre" text,
	"keywords" text[],
	"length" integer,
	"episode_count" integer,
	"is_completed" boolean,
	"global_point" integer,
	"metadata" jsonb,
	"embedding" vector(768),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sync_logs" (
	"id" integer PRIMARY KEY GENERATED ALWAYS AS IDENTITY (sequence name "sync_logs_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START WITH 1 CACHE 1),
	"source" text NOT NULL,
	"status" text NOT NULL,
	"created" integer DEFAULT 0 NOT NULL,
	"updated" integer DEFAULT 0 NOT NULL,
	"errors" text,
	"started_at" timestamp with time zone NOT NULL,
	"ended_at" timestamp with time zone
);
--> statement-breakpoint
CREATE UNIQUE INDEX "novels_source_source_id_unique" ON "novels" USING btree ("source","source_id");--> statement-breakpoint
CREATE INDEX "novels_genre_idx" ON "novels" USING btree ("genre");--> statement-breakpoint
CREATE INDEX "novels_keywords_gin_idx" ON "novels" USING gin ("keywords");--> statement-breakpoint
CREATE INDEX "novels_embedding_null_idx" ON "novels" USING btree ("id") WHERE "novels"."embedding" IS NULL;--> statement-breakpoint
CREATE INDEX "sync_logs_started_at_desc_idx" ON "sync_logs" USING btree ("started_at" DESC NULLS LAST);--> statement-breakpoint
CREATE INDEX "sync_logs_source_status_idx" ON "sync_logs" USING btree ("source","status");

-- updated_at 自動更新用のトリガー
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
	NEW.updated_at = now();
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- novels テーブルへのトリガー適用
CREATE TRIGGER novels_set_updated_at
	BEFORE UPDATE ON novels
	FOR EACH ROW
	EXECUTE FUNCTION set_updated_at();
