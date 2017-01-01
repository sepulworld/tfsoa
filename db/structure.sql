
REATE TABLE "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "tfstates" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "s3_bucket_uri" varchar, "s3_bucket_key" varchar, "role_arn" varchar, "state_json" text, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "terraform_version" decimal, "serial" integer, "json_version" integer);
INSERT INTO schema_migrations (version) VALUES
('20161229194126'),
('20161231042157'),
('20161231234036');
