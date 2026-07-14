import { pgTable, text, integer, boolean, jsonb, timestamp, vector, index, uniqueIndex } from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";

export const novels = pgTable(
    "novels",
    {
        id: integer("id").generatedAlwaysAsIdentity().primaryKey(),
        source: text("source").notNull(), // `NAROU` など、将来のソース追加を見越してCHECK制約はつけない
        sourceId: text("source_id").notNull(), //なろうの ncode
        title: text("title").notNull(),
        author: text("author"),
        description: text("description"),
        url: text("url"),
        genre: text("genre"),
        keywords: text("keywords").array(),
        length: integer("length"),
        episodeCount: integer("episode_count"),
        isCompleted: boolean("is_completed"), // Null = 未取得、false にすり替えない
        globalPoint: integer("global_point"),
        metadata: jsonb("metadata").$type<Record<string, unknown>>(),
        embedding: vector("embedding", { dimensions: 768 }), //Phase 3 までは Null
        createdAt: timestamp("created_at", { withTimezone: true})
            .notNull()
            .defaultNow(),
        updatedAt: timestamp("updated_at", { withTimezone: true })
            .notNull()
            .defaultNow(), // 実際の更新はDBトリガー(migration手書きSQL)が担当。novelsのみ適用、sync_logsは対象外
    },
    (table) => [
        uniqueIndex("novels_source_source_id_unique").on(
            table.source,
            table.sourceId
        ),
        index("novels_genre_idx").on(table.genre),
        index("novels_keywords_gin_idx").using("gin", table.keywords),
        index("novels_embedding_null_idx")
            .on(table.id)
            .where(sql`${table.embedding} IS NULL`)
    ],
);

export const syncLogs = pgTable(
    "sync_logs",
    {
        id: integer("id").generatedAlwaysAsIdentity().primaryKey(),
        source: text("source").notNull(),
        status: text("status").notNull(), // `RUNNING` / `SUCCESS` / `FAILED` / `PARTIAL`
        created: integer("created").notNull().default(0),
        updated: integer("updated").notNull().default(0),
        errors: text("errors"),
        startedAt: timestamp("started_at", { withTimezone: true }).notNull(),
        endedAt: timestamp("ended_at", { withTimezone: true }),
    },
    (table) => [
        index("sync_logs_started_at_desc_idx").on(table.startedAt.desc()),
        index("sync_logs_source_status_idx").on(table.source, table.status),
    ],
);

export type InsertNovel = typeof novels.$inferInsert
export type SelectNovel = typeof novels.$inferSelect
export type InsertSyncLog = typeof syncLogs.$inferInsert
export type SelectSyncLog = typeof syncLogs.$inferSelect