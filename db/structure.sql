CREATE TABLE "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "tfstates" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "s3_bucket_uri" varchar, "s3_bucket_key" varchar, "role_arn" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "state_details" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "tfstate_id" integer, "terraform_version" integer, "state_json" text, "json_version" integer, "serial" integer, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE INDEX "index_state_details_on_tfstate_id" ON "state_details" ("tfstate_id");
INSERT INTO schema_migrations (version) VALUES
('20170102043443'),
('20170102045517'),
('20170102045743');
