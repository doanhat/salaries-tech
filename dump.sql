--
-- PostgreSQL database dump
--

-- Dumped from database version 15.6
-- Dumped by pg_dump version 15.8 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP EVENT TRIGGER IF EXISTS "pgrst_drop_watch";
DROP EVENT TRIGGER IF EXISTS "pgrst_ddl_watch";
DROP EVENT TRIGGER IF EXISTS "issue_pg_net_access";
DROP EVENT TRIGGER IF EXISTS "issue_pg_graphql_access";
DROP EVENT TRIGGER IF EXISTS "issue_pg_cron_access";
DROP EVENT TRIGGER IF EXISTS "issue_graphql_placeholder";
DROP PUBLICATION IF EXISTS "supabase_realtime";
ALTER TABLE IF EXISTS ONLY "storage"."s3_multipart_uploads_parts" DROP CONSTRAINT IF EXISTS "s3_multipart_uploads_parts_upload_id_fkey";
ALTER TABLE IF EXISTS ONLY "storage"."s3_multipart_uploads_parts" DROP CONSTRAINT IF EXISTS "s3_multipart_uploads_parts_bucket_id_fkey";
ALTER TABLE IF EXISTS ONLY "storage"."s3_multipart_uploads" DROP CONSTRAINT IF EXISTS "s3_multipart_uploads_bucket_id_fkey";
ALTER TABLE IF EXISTS ONLY "storage"."objects" DROP CONSTRAINT IF EXISTS "objects_bucketId_fkey";
ALTER TABLE IF EXISTS ONLY "public"."salary_technical_stack" DROP CONSTRAINT IF EXISTS "salary_technical_stack_technical_stack_id_fkey";
ALTER TABLE IF EXISTS ONLY "public"."salary_technical_stack" DROP CONSTRAINT IF EXISTS "salary_technical_stack_salary_id_fkey";
ALTER TABLE IF EXISTS ONLY "public"."salary_job" DROP CONSTRAINT IF EXISTS "salary_job_salary_id_fkey";
ALTER TABLE IF EXISTS ONLY "public"."salary_job" DROP CONSTRAINT IF EXISTS "salary_job_job_id_fkey";
ALTER TABLE IF EXISTS ONLY "public"."salaries" DROP CONSTRAINT IF EXISTS "salaries_company_id_fkey";
ALTER TABLE IF EXISTS ONLY "public"."company_tag" DROP CONSTRAINT IF EXISTS "company_tag_tag_id_fkey";
ALTER TABLE IF EXISTS ONLY "public"."company_tag" DROP CONSTRAINT IF EXISTS "company_tag_company_id_fkey";
ALTER TABLE IF EXISTS ONLY "auth"."sso_domains" DROP CONSTRAINT IF EXISTS "sso_domains_sso_provider_id_fkey";
ALTER TABLE IF EXISTS ONLY "auth"."sessions" DROP CONSTRAINT IF EXISTS "sessions_user_id_fkey";
ALTER TABLE IF EXISTS ONLY "auth"."saml_relay_states" DROP CONSTRAINT IF EXISTS "saml_relay_states_sso_provider_id_fkey";
ALTER TABLE IF EXISTS ONLY "auth"."saml_relay_states" DROP CONSTRAINT IF EXISTS "saml_relay_states_flow_state_id_fkey";
ALTER TABLE IF EXISTS ONLY "auth"."saml_providers" DROP CONSTRAINT IF EXISTS "saml_providers_sso_provider_id_fkey";
ALTER TABLE IF EXISTS ONLY "auth"."refresh_tokens" DROP CONSTRAINT IF EXISTS "refresh_tokens_session_id_fkey";
ALTER TABLE IF EXISTS ONLY "auth"."one_time_tokens" DROP CONSTRAINT IF EXISTS "one_time_tokens_user_id_fkey";
ALTER TABLE IF EXISTS ONLY "auth"."mfa_factors" DROP CONSTRAINT IF EXISTS "mfa_factors_user_id_fkey";
ALTER TABLE IF EXISTS ONLY "auth"."mfa_challenges" DROP CONSTRAINT IF EXISTS "mfa_challenges_auth_factor_id_fkey";
ALTER TABLE IF EXISTS ONLY "auth"."mfa_amr_claims" DROP CONSTRAINT IF EXISTS "mfa_amr_claims_session_id_fkey";
ALTER TABLE IF EXISTS ONLY "auth"."identities" DROP CONSTRAINT IF EXISTS "identities_user_id_fkey";
DROP TRIGGER IF EXISTS "update_objects_updated_at" ON "storage"."objects";
DROP TRIGGER IF EXISTS "tr_check_filters" ON "realtime"."subscription";
DROP INDEX IF EXISTS "storage"."name_prefix_search";
DROP INDEX IF EXISTS "storage"."idx_objects_bucket_id_name";
DROP INDEX IF EXISTS "storage"."idx_multipart_uploads_list";
DROP INDEX IF EXISTS "storage"."bucketid_objname";
DROP INDEX IF EXISTS "storage"."bname";
DROP INDEX IF EXISTS "realtime"."subscription_subscription_id_entity_filters_key";
DROP INDEX IF EXISTS "realtime"."messages_topic_index";
DROP INDEX IF EXISTS "realtime"."ix_realtime_subscription_entity";
DROP INDEX IF EXISTS "public"."ix_technical_stacks_id";
DROP INDEX IF EXISTS "public"."ix_tags_id";
DROP INDEX IF EXISTS "public"."ix_salaries_id";
DROP INDEX IF EXISTS "public"."ix_jobs_id";
DROP INDEX IF EXISTS "public"."ix_companies_id";
DROP INDEX IF EXISTS "public"."idx_salary_technical_stack_composite";
DROP INDEX IF EXISTS "public"."idx_salary_job_composite";
DROP INDEX IF EXISTS "public"."idx_salaries_net_salary_desc";
DROP INDEX IF EXISTS "public"."idx_salaries_location_salary";
DROP INDEX IF EXISTS "public"."idx_salaries_gross_salary_desc";
DROP INDEX IF EXISTS "public"."idx_salaries_experience_salary";
DROP INDEX IF EXISTS "public"."idx_salaries_experience";
DROP INDEX IF EXISTS "public"."idx_salaries_covering";
DROP INDEX IF EXISTS "public"."idx_salaries_composite_2";
DROP INDEX IF EXISTS "public"."idx_salaries_composite_1";
DROP INDEX IF EXISTS "public"."idx_salaries_added_date_desc";
DROP INDEX IF EXISTS "public"."idx_jobs_title_gin";
DROP INDEX IF EXISTS "public"."idx_company_tag_composite";
DROP INDEX IF EXISTS "public"."idx_companies_name_gin";
DROP INDEX IF EXISTS "auth"."users_is_anonymous_idx";
DROP INDEX IF EXISTS "auth"."users_instance_id_idx";
DROP INDEX IF EXISTS "auth"."users_instance_id_email_idx";
DROP INDEX IF EXISTS "auth"."users_email_partial_key";
DROP INDEX IF EXISTS "auth"."user_id_created_at_idx";
DROP INDEX IF EXISTS "auth"."unique_phone_factor_per_user";
DROP INDEX IF EXISTS "auth"."sso_providers_resource_id_idx";
DROP INDEX IF EXISTS "auth"."sso_domains_sso_provider_id_idx";
DROP INDEX IF EXISTS "auth"."sso_domains_domain_idx";
DROP INDEX IF EXISTS "auth"."sessions_user_id_idx";
DROP INDEX IF EXISTS "auth"."sessions_not_after_idx";
DROP INDEX IF EXISTS "auth"."saml_relay_states_sso_provider_id_idx";
DROP INDEX IF EXISTS "auth"."saml_relay_states_for_email_idx";
DROP INDEX IF EXISTS "auth"."saml_relay_states_created_at_idx";
DROP INDEX IF EXISTS "auth"."saml_providers_sso_provider_id_idx";
DROP INDEX IF EXISTS "auth"."refresh_tokens_updated_at_idx";
DROP INDEX IF EXISTS "auth"."refresh_tokens_session_id_revoked_idx";
DROP INDEX IF EXISTS "auth"."refresh_tokens_parent_idx";
DROP INDEX IF EXISTS "auth"."refresh_tokens_instance_id_user_id_idx";
DROP INDEX IF EXISTS "auth"."refresh_tokens_instance_id_idx";
DROP INDEX IF EXISTS "auth"."recovery_token_idx";
DROP INDEX IF EXISTS "auth"."reauthentication_token_idx";
DROP INDEX IF EXISTS "auth"."one_time_tokens_user_id_token_type_key";
DROP INDEX IF EXISTS "auth"."one_time_tokens_token_hash_hash_idx";
DROP INDEX IF EXISTS "auth"."one_time_tokens_relates_to_hash_idx";
DROP INDEX IF EXISTS "auth"."mfa_factors_user_id_idx";
DROP INDEX IF EXISTS "auth"."mfa_factors_user_friendly_name_unique";
DROP INDEX IF EXISTS "auth"."mfa_challenge_created_at_idx";
DROP INDEX IF EXISTS "auth"."idx_user_id_auth_method";
DROP INDEX IF EXISTS "auth"."idx_auth_code";
DROP INDEX IF EXISTS "auth"."identities_user_id_idx";
DROP INDEX IF EXISTS "auth"."identities_email_idx";
DROP INDEX IF EXISTS "auth"."flow_state_created_at_idx";
DROP INDEX IF EXISTS "auth"."factor_id_created_at_idx";
DROP INDEX IF EXISTS "auth"."email_change_token_new_idx";
DROP INDEX IF EXISTS "auth"."email_change_token_current_idx";
DROP INDEX IF EXISTS "auth"."confirmation_token_idx";
DROP INDEX IF EXISTS "auth"."audit_logs_instance_id_idx";
ALTER TABLE IF EXISTS ONLY "supabase_migrations"."seed_files" DROP CONSTRAINT IF EXISTS "seed_files_pkey";
ALTER TABLE IF EXISTS ONLY "supabase_migrations"."schema_migrations" DROP CONSTRAINT IF EXISTS "schema_migrations_pkey";
ALTER TABLE IF EXISTS ONLY "storage"."s3_multipart_uploads" DROP CONSTRAINT IF EXISTS "s3_multipart_uploads_pkey";
ALTER TABLE IF EXISTS ONLY "storage"."s3_multipart_uploads_parts" DROP CONSTRAINT IF EXISTS "s3_multipart_uploads_parts_pkey";
ALTER TABLE IF EXISTS ONLY "storage"."objects" DROP CONSTRAINT IF EXISTS "objects_pkey";
ALTER TABLE IF EXISTS ONLY "storage"."migrations" DROP CONSTRAINT IF EXISTS "migrations_pkey";
ALTER TABLE IF EXISTS ONLY "storage"."migrations" DROP CONSTRAINT IF EXISTS "migrations_name_key";
ALTER TABLE IF EXISTS ONLY "storage"."buckets" DROP CONSTRAINT IF EXISTS "buckets_pkey";
ALTER TABLE IF EXISTS ONLY "realtime"."schema_migrations" DROP CONSTRAINT IF EXISTS "schema_migrations_pkey";
ALTER TABLE IF EXISTS ONLY "realtime"."subscription" DROP CONSTRAINT IF EXISTS "pk_subscription";
ALTER TABLE IF EXISTS ONLY "realtime"."messages" DROP CONSTRAINT IF EXISTS "messages_pkey";
ALTER TABLE IF EXISTS ONLY "public"."technical_stacks" DROP CONSTRAINT IF EXISTS "technical_stacks_name_key";
ALTER TABLE IF EXISTS ONLY "public"."tags" DROP CONSTRAINT IF EXISTS "tags_name_key";
ALTER TABLE IF EXISTS ONLY "public"."jobs" DROP CONSTRAINT IF EXISTS "jobs_title_key";
ALTER TABLE IF EXISTS ONLY "public"."companies" DROP CONSTRAINT IF EXISTS "idx_16423_ix_companies_id";
ALTER TABLE IF EXISTS ONLY "public"."tags" DROP CONSTRAINT IF EXISTS "idx_16415_ix_tags_id";
ALTER TABLE IF EXISTS ONLY "public"."salaries" DROP CONSTRAINT IF EXISTS "idx_16404_ix_salaries_id";
ALTER TABLE IF EXISTS ONLY "public"."technical_stacks" DROP CONSTRAINT IF EXISTS "idx_16399_ix_technical_stacks_id";
ALTER TABLE IF EXISTS ONLY "public"."jobs" DROP CONSTRAINT IF EXISTS "idx_16394_ix_jobs_id";
ALTER TABLE IF EXISTS ONLY "public"."alembic_version" DROP CONSTRAINT IF EXISTS "idx_16389_sqlite_autoindex_alembic_version_1";
ALTER TABLE IF EXISTS ONLY "public"."companies" DROP CONSTRAINT IF EXISTS "companies_name_key";
ALTER TABLE IF EXISTS ONLY "auth"."users" DROP CONSTRAINT IF EXISTS "users_pkey";
ALTER TABLE IF EXISTS ONLY "auth"."users" DROP CONSTRAINT IF EXISTS "users_phone_key";
ALTER TABLE IF EXISTS ONLY "auth"."sso_providers" DROP CONSTRAINT IF EXISTS "sso_providers_pkey";
ALTER TABLE IF EXISTS ONLY "auth"."sso_domains" DROP CONSTRAINT IF EXISTS "sso_domains_pkey";
ALTER TABLE IF EXISTS ONLY "auth"."sessions" DROP CONSTRAINT IF EXISTS "sessions_pkey";
ALTER TABLE IF EXISTS ONLY "auth"."schema_migrations" DROP CONSTRAINT IF EXISTS "schema_migrations_pkey";
ALTER TABLE IF EXISTS ONLY "auth"."saml_relay_states" DROP CONSTRAINT IF EXISTS "saml_relay_states_pkey";
ALTER TABLE IF EXISTS ONLY "auth"."saml_providers" DROP CONSTRAINT IF EXISTS "saml_providers_pkey";
ALTER TABLE IF EXISTS ONLY "auth"."saml_providers" DROP CONSTRAINT IF EXISTS "saml_providers_entity_id_key";
ALTER TABLE IF EXISTS ONLY "auth"."refresh_tokens" DROP CONSTRAINT IF EXISTS "refresh_tokens_token_unique";
ALTER TABLE IF EXISTS ONLY "auth"."refresh_tokens" DROP CONSTRAINT IF EXISTS "refresh_tokens_pkey";
ALTER TABLE IF EXISTS ONLY "auth"."one_time_tokens" DROP CONSTRAINT IF EXISTS "one_time_tokens_pkey";
ALTER TABLE IF EXISTS ONLY "auth"."mfa_factors" DROP CONSTRAINT IF EXISTS "mfa_factors_pkey";
ALTER TABLE IF EXISTS ONLY "auth"."mfa_factors" DROP CONSTRAINT IF EXISTS "mfa_factors_last_challenged_at_key";
ALTER TABLE IF EXISTS ONLY "auth"."mfa_challenges" DROP CONSTRAINT IF EXISTS "mfa_challenges_pkey";
ALTER TABLE IF EXISTS ONLY "auth"."mfa_amr_claims" DROP CONSTRAINT IF EXISTS "mfa_amr_claims_session_id_authentication_method_pkey";
ALTER TABLE IF EXISTS ONLY "auth"."instances" DROP CONSTRAINT IF EXISTS "instances_pkey";
ALTER TABLE IF EXISTS ONLY "auth"."identities" DROP CONSTRAINT IF EXISTS "identities_provider_id_provider_unique";
ALTER TABLE IF EXISTS ONLY "auth"."identities" DROP CONSTRAINT IF EXISTS "identities_pkey";
ALTER TABLE IF EXISTS ONLY "auth"."flow_state" DROP CONSTRAINT IF EXISTS "flow_state_pkey";
ALTER TABLE IF EXISTS ONLY "auth"."audit_log_entries" DROP CONSTRAINT IF EXISTS "audit_log_entries_pkey";
ALTER TABLE IF EXISTS ONLY "auth"."mfa_amr_claims" DROP CONSTRAINT IF EXISTS "amr_id_pk";
ALTER TABLE IF EXISTS "realtime"."messages" ALTER COLUMN "id" DROP DEFAULT;
ALTER TABLE IF EXISTS "public"."technical_stacks" ALTER COLUMN "id" DROP DEFAULT;
ALTER TABLE IF EXISTS "public"."tags" ALTER COLUMN "id" DROP DEFAULT;
ALTER TABLE IF EXISTS "public"."salaries" ALTER COLUMN "id" DROP DEFAULT;
ALTER TABLE IF EXISTS "public"."jobs" ALTER COLUMN "id" DROP DEFAULT;
ALTER TABLE IF EXISTS "public"."companies" ALTER COLUMN "id" DROP DEFAULT;
ALTER TABLE IF EXISTS "auth"."refresh_tokens" ALTER COLUMN "id" DROP DEFAULT;
DROP VIEW IF EXISTS "vault"."decrypted_secrets";
DROP TABLE IF EXISTS "supabase_migrations"."seed_files";
DROP TABLE IF EXISTS "supabase_migrations"."schema_migrations";
DROP TABLE IF EXISTS "storage"."s3_multipart_uploads_parts";
DROP TABLE IF EXISTS "storage"."s3_multipart_uploads";
DROP TABLE IF EXISTS "storage"."objects";
DROP TABLE IF EXISTS "storage"."migrations";
DROP TABLE IF EXISTS "storage"."buckets";
DROP TABLE IF EXISTS "realtime"."subscription";
DROP TABLE IF EXISTS "realtime"."schema_migrations";
DROP SEQUENCE IF EXISTS "realtime"."messages_id_seq";
DROP TABLE IF EXISTS "realtime"."messages";
DROP SEQUENCE IF EXISTS "public"."technical_stacks_id_seq";
DROP TABLE IF EXISTS "public"."technical_stacks";
DROP SEQUENCE IF EXISTS "public"."tags_id_seq";
DROP TABLE IF EXISTS "public"."tags";
DROP TABLE IF EXISTS "public"."salary_technical_stack";
DROP TABLE IF EXISTS "public"."salary_job";
DROP SEQUENCE IF EXISTS "public"."salaries_id_seq";
DROP TABLE IF EXISTS "public"."salaries";
DROP SEQUENCE IF EXISTS "public"."jobs_id_seq";
DROP TABLE IF EXISTS "public"."jobs";
DROP TABLE IF EXISTS "public"."company_tag";
DROP SEQUENCE IF EXISTS "public"."companies_id_seq";
DROP TABLE IF EXISTS "public"."companies";
DROP TABLE IF EXISTS "public"."alembic_version";
DROP TABLE IF EXISTS "auth"."users";
DROP TABLE IF EXISTS "auth"."sso_providers";
DROP TABLE IF EXISTS "auth"."sso_domains";
DROP TABLE IF EXISTS "auth"."sessions";
DROP TABLE IF EXISTS "auth"."schema_migrations";
DROP TABLE IF EXISTS "auth"."saml_relay_states";
DROP TABLE IF EXISTS "auth"."saml_providers";
DROP SEQUENCE IF EXISTS "auth"."refresh_tokens_id_seq";
DROP TABLE IF EXISTS "auth"."refresh_tokens";
DROP TABLE IF EXISTS "auth"."one_time_tokens";
DROP TABLE IF EXISTS "auth"."mfa_factors";
DROP TABLE IF EXISTS "auth"."mfa_challenges";
DROP TABLE IF EXISTS "auth"."mfa_amr_claims";
DROP TABLE IF EXISTS "auth"."instances";
DROP TABLE IF EXISTS "auth"."identities";
DROP TABLE IF EXISTS "auth"."flow_state";
DROP TABLE IF EXISTS "auth"."audit_log_entries";
DROP FUNCTION IF EXISTS "vault"."secrets_encrypt_secret_secret"();
DROP FUNCTION IF EXISTS "storage"."update_updated_at_column"();
DROP FUNCTION IF EXISTS "storage"."search"("prefix" "text", "bucketname" "text", "limits" integer, "levels" integer, "offsets" integer, "search" "text", "sortcolumn" "text", "sortorder" "text");
DROP FUNCTION IF EXISTS "storage"."operation"();
DROP FUNCTION IF EXISTS "storage"."list_objects_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer, "start_after" "text", "next_token" "text");
DROP FUNCTION IF EXISTS "storage"."list_multipart_uploads_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer, "next_key_token" "text", "next_upload_token" "text");
DROP FUNCTION IF EXISTS "storage"."get_size_by_bucket"();
DROP FUNCTION IF EXISTS "storage"."foldername"("name" "text");
DROP FUNCTION IF EXISTS "storage"."filename"("name" "text");
DROP FUNCTION IF EXISTS "storage"."extension"("name" "text");
DROP FUNCTION IF EXISTS "storage"."can_insert_object"("bucketid" "text", "name" "text", "owner" "uuid", "metadata" "jsonb");
DROP FUNCTION IF EXISTS "realtime"."topic"();
DROP FUNCTION IF EXISTS "realtime"."to_regrole"("role_name" "text");
DROP FUNCTION IF EXISTS "realtime"."subscription_check_filters"();
DROP FUNCTION IF EXISTS "realtime"."send"("payload" "jsonb", "event" "text", "topic" "text", "private" boolean);
DROP FUNCTION IF EXISTS "realtime"."quote_wal2json"("entity" "regclass");
DROP FUNCTION IF EXISTS "realtime"."list_changes"("publication" "name", "slot_name" "name", "max_changes" integer, "max_record_bytes" integer);
DROP FUNCTION IF EXISTS "realtime"."is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]);
DROP FUNCTION IF EXISTS "realtime"."check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text");
DROP FUNCTION IF EXISTS "realtime"."cast"("val" "text", "type_" "regtype");
DROP FUNCTION IF EXISTS "realtime"."build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]);
DROP FUNCTION IF EXISTS "realtime"."broadcast_changes"("topic_name" "text", "event_name" "text", "operation" "text", "table_name" "text", "table_schema" "text", "new" "record", "old" "record", "level" "text");
DROP FUNCTION IF EXISTS "realtime"."apply_rls"("wal" "jsonb", "max_record_bytes" integer);
DROP FUNCTION IF EXISTS "pgbouncer"."get_auth"("p_usename" "text");
DROP FUNCTION IF EXISTS "extensions"."set_graphql_placeholder"();
DROP FUNCTION IF EXISTS "extensions"."pgrst_drop_watch"();
DROP FUNCTION IF EXISTS "extensions"."pgrst_ddl_watch"();
DROP FUNCTION IF EXISTS "extensions"."grant_pg_net_access"();
DROP FUNCTION IF EXISTS "extensions"."grant_pg_graphql_access"();
DROP FUNCTION IF EXISTS "extensions"."grant_pg_cron_access"();
DROP FUNCTION IF EXISTS "auth"."uid"();
DROP FUNCTION IF EXISTS "auth"."role"();
DROP FUNCTION IF EXISTS "auth"."jwt"();
DROP FUNCTION IF EXISTS "auth"."email"();
DROP TYPE IF EXISTS "realtime"."wal_rls";
DROP TYPE IF EXISTS "realtime"."wal_column";
DROP TYPE IF EXISTS "realtime"."user_defined_filter";
DROP TYPE IF EXISTS "realtime"."equality_op";
DROP TYPE IF EXISTS "realtime"."action";
DROP TYPE IF EXISTS "auth"."one_time_token_type";
DROP TYPE IF EXISTS "auth"."factor_type";
DROP TYPE IF EXISTS "auth"."factor_status";
DROP TYPE IF EXISTS "auth"."code_challenge_method";
DROP TYPE IF EXISTS "auth"."aal_level";
DROP EXTENSION IF EXISTS "uuid-ossp";
DROP EXTENSION IF EXISTS "supabase_vault";
DROP EXTENSION IF EXISTS "pgjwt";
DROP EXTENSION IF EXISTS "pgcrypto";
DROP EXTENSION IF EXISTS "pg_trgm";
DROP EXTENSION IF EXISTS "pg_stat_statements";
DROP EXTENSION IF EXISTS "pg_graphql";
DROP SCHEMA IF EXISTS "vault";
DROP SCHEMA IF EXISTS "supabase_migrations";
DROP SCHEMA IF EXISTS "storage";
DROP SCHEMA IF EXISTS "realtime";
DROP EXTENSION IF EXISTS "pgsodium";
DROP SCHEMA IF EXISTS "pgsodium";
DROP SCHEMA IF EXISTS "pgbouncer";
DROP SCHEMA IF EXISTS "graphql_public";
DROP SCHEMA IF EXISTS "graphql";
DROP SCHEMA IF EXISTS "extensions";
DROP SCHEMA IF EXISTS "auth";
--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "auth";


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "extensions";


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "graphql";


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "graphql_public";


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "pgbouncer";


--
-- Name: pgsodium; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "pgsodium";


--
-- Name: pgsodium; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";


--
-- Name: EXTENSION "pgsodium"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "pgsodium" IS 'Pgsodium is a modern cryptography library for Postgres.';


--
-- Name: SCHEMA "public"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA "public" IS 'standard public schema';


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "realtime";


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "storage";


--
-- Name: supabase_migrations; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "supabase_migrations";


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA "vault";


--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";


--
-- Name: EXTENSION "pg_graphql"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "pg_graphql" IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";


--
-- Name: EXTENSION "pg_stat_statements"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "pg_stat_statements" IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_trgm" WITH SCHEMA "public";


--
-- Name: EXTENSION "pg_trgm"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "pg_trgm" IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";


--
-- Name: EXTENSION "pgcrypto"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "pgcrypto" IS 'cryptographic functions';


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";


--
-- Name: EXTENSION "pgjwt"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "pgjwt" IS 'JSON Web Token API for Postgresql';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";


--
-- Name: EXTENSION "supabase_vault"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "supabase_vault" IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE "auth"."aal_level" AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE "auth"."code_challenge_method" AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE "auth"."factor_status" AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE "auth"."factor_type" AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE "auth"."one_time_token_type" AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE "realtime"."action" AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE "realtime"."equality_op" AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE "realtime"."user_defined_filter" AS (
	"column_name" "text",
	"op" "realtime"."equality_op",
	"value" "text"
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE "realtime"."wal_column" AS (
	"name" "text",
	"type_name" "text",
	"type_oid" "oid",
	"value" "jsonb",
	"is_pkey" boolean,
	"is_selectable" boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE "realtime"."wal_rls" AS (
	"wal" "jsonb",
	"is_rls_enabled" boolean,
	"subscription_ids" "uuid"[],
	"errors" "text"[]
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION "auth"."email"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION "email"(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION "auth"."email"() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION "auth"."jwt"() RETURNS "jsonb"
    LANGUAGE "sql" STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION "auth"."role"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION "role"(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION "auth"."role"() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION "auth"."uid"() RETURNS "uuid"
    LANGUAGE "sql" STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION "uid"(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION "auth"."uid"() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION "extensions"."grant_pg_cron_access"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


--
-- Name: FUNCTION "grant_pg_cron_access"(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION "extensions"."grant_pg_cron_access"() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION "extensions"."grant_pg_graphql_access"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


--
-- Name: FUNCTION "grant_pg_graphql_access"(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION "extensions"."grant_pg_graphql_access"() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION "extensions"."grant_pg_net_access"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

    REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
    REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

    GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
  END IF;
END;
$$;


--
-- Name: FUNCTION "grant_pg_net_access"(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION "extensions"."grant_pg_net_access"() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION "extensions"."pgrst_ddl_watch"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION "extensions"."pgrst_drop_watch"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION "extensions"."set_graphql_placeholder"() RETURNS "event_trigger"
    LANGUAGE "plpgsql"
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION "set_graphql_placeholder"(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION "extensions"."set_graphql_placeholder"() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth("text"); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION "pgbouncer"."get_auth"("p_usename" "text") RETURNS TABLE("username" "text", "password" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    RAISE WARNING 'PgBouncer auth request: %', p_usename;

    RETURN QUERY
    SELECT usename::TEXT, passwd::TEXT FROM pg_catalog.pg_shadow
    WHERE usename = p_usename;
END;
$$;


--
-- Name: apply_rls("jsonb", integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."apply_rls"("wal" "jsonb", "max_record_bytes" integer DEFAULT (1024 * 1024)) RETURNS SETOF "realtime"."wal_rls"
    LANGUAGE "plpgsql"
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes("text", "text", "text", "text", "text", "record", "record", "text"); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."broadcast_changes"("topic_name" "text", "event_name" "text", "operation" "text", "table_name" "text", "table_schema" "text", "new" "record", "old" "record", "level" "text" DEFAULT 'ROW'::"text") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql("text", "regclass", "realtime"."wal_column"[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."build_prepared_statement_sql"("prepared_statement_name" "text", "entity" "regclass", "columns" "realtime"."wal_column"[]) RETURNS "text"
    LANGUAGE "sql"
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast("text", "regtype"); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."cast"("val" "text", "type_" "regtype") RETURNS "jsonb"
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


--
-- Name: check_equality_op("realtime"."equality_op", "regtype", "text", "text"); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."check_equality_op"("op" "realtime"."equality_op", "type_" "regtype", "val_1" "text", "val_2" "text") RETURNS boolean
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


--
-- Name: is_visible_through_filters("realtime"."wal_column"[], "realtime"."user_defined_filter"[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."is_visible_through_filters"("columns" "realtime"."wal_column"[], "filters" "realtime"."user_defined_filter"[]) RETURNS boolean
    LANGUAGE "sql" IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


--
-- Name: list_changes("name", "name", integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."list_changes"("publication" "name", "slot_name" "name", "max_changes" integer, "max_record_bytes" integer) RETURNS SETOF "realtime"."wal_rls"
    LANGUAGE "sql"
    SET "log_min_messages" TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


--
-- Name: quote_wal2json("regclass"); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."quote_wal2json"("entity" "regclass") RETURNS "text"
    LANGUAGE "sql" IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


--
-- Name: send("jsonb", "text", "text", boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."send"("payload" "jsonb", "event" "text", "topic" "text", "private" boolean DEFAULT true) RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    INSERT INTO realtime.messages (payload, event, topic, private, extension)
    VALUES (payload, event, topic, private, 'broadcast');
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."subscription_check_filters"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


--
-- Name: to_regrole("text"); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."to_regrole"("role_name" "text") RETURNS "regrole"
    LANGUAGE "sql" IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION "realtime"."topic"() RETURNS "text"
    LANGUAGE "sql" STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: can_insert_object("text", "text", "uuid", "jsonb"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."can_insert_object"("bucketid" "text", "name" "text", "owner" "uuid", "metadata" "jsonb") RETURNS "void"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: extension("text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."extension"("name" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
_parts text[];
_filename text;
BEGIN
	select string_to_array(name, '/') into _parts;
	select _parts[array_length(_parts,1)] into _filename;
	-- @todo return the last part instead of 2
	return reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename("text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."filename"("name" "text") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


--
-- Name: foldername("text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."foldername"("name" "text") RETURNS "text"[]
    LANGUAGE "plpgsql"
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[1:array_length(_parts,1)-1];
END
$$;


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."get_size_by_bucket"() RETURNS TABLE("size" bigint, "bucket_id" "text")
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::int) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter("text", "text", "text", integer, "text", "text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."list_multipart_uploads_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer DEFAULT 100, "next_key_token" "text" DEFAULT ''::"text", "next_upload_token" "text" DEFAULT ''::"text") RETURNS TABLE("key" "text", "id" "text", "created_at" timestamp with time zone)
    LANGUAGE "plpgsql"
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


--
-- Name: list_objects_with_delimiter("text", "text", "text", integer, "text", "text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."list_objects_with_delimiter"("bucket_id" "text", "prefix_param" "text", "delimiter_param" "text", "max_keys" integer DEFAULT 100, "start_after" "text" DEFAULT ''::"text", "next_token" "text" DEFAULT ''::"text") RETURNS TABLE("name" "text", "id" "uuid", "metadata" "jsonb", "updated_at" timestamp with time zone)
    LANGUAGE "plpgsql"
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."operation"() RETURNS "text"
    LANGUAGE "plpgsql" STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: search("text", "text", integer, integer, integer, "text", "text", "text"); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."search"("prefix" "text", "bucketname" "text", "limits" integer DEFAULT 100, "levels" integer DEFAULT 1, "offsets" integer DEFAULT 0, "search" "text" DEFAULT ''::"text", "sortcolumn" "text" DEFAULT 'name'::"text", "sortorder" "text" DEFAULT 'asc'::"text") RETURNS TABLE("name" "text", "id" "uuid", "updated_at" timestamp with time zone, "created_at" timestamp with time zone, "last_accessed_at" timestamp with time zone, "metadata" "jsonb")
    LANGUAGE "plpgsql" STABLE
    AS $_$
declare
  v_order_by text;
  v_sort_order text;
begin
  case
    when sortcolumn = 'name' then
      v_order_by = 'name';
    when sortcolumn = 'updated_at' then
      v_order_by = 'updated_at';
    when sortcolumn = 'created_at' then
      v_order_by = 'created_at';
    when sortcolumn = 'last_accessed_at' then
      v_order_by = 'last_accessed_at';
    else
      v_order_by = 'name';
  end case;

  case
    when sortorder = 'asc' then
      v_sort_order = 'asc';
    when sortorder = 'desc' then
      v_sort_order = 'desc';
    else
      v_sort_order = 'asc';
  end case;

  v_order_by = v_order_by || ' ' || v_sort_order;

  return query execute
    'with folders as (
       select path_tokens[$1] as folder
       from storage.objects
         where objects.name ilike $2 || $3 || ''%''
           and bucket_id = $4
           and array_length(objects.path_tokens, 1) <> $1
       group by folder
       order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION "storage"."update_updated_at_column"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


--
-- Name: secrets_encrypt_secret_secret(); Type: FUNCTION; Schema: vault; Owner: -
--

CREATE FUNCTION "vault"."secrets_encrypt_secret_secret"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
		BEGIN
		        new.secret = CASE WHEN new.secret IS NULL THEN NULL ELSE
			CASE WHEN new.key_id IS NULL THEN NULL ELSE pg_catalog.encode(
			  pgsodium.crypto_aead_det_encrypt(
				pg_catalog.convert_to(new.secret, 'utf8'),
				pg_catalog.convert_to((new.id::text || new.description::text || new.created_at::text || new.updated_at::text)::text, 'utf8'),
				new.key_id::uuid,
				new.nonce
			  ),
				'base64') END END;
		RETURN new;
		END;
		$$;


SET default_tablespace = '';

SET default_table_access_method = "heap";

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."audit_log_entries" (
    "instance_id" "uuid",
    "id" "uuid" NOT NULL,
    "payload" "json",
    "created_at" timestamp with time zone,
    "ip_address" character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE "audit_log_entries"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."audit_log_entries" IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."flow_state" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid",
    "auth_code" "text" NOT NULL,
    "code_challenge_method" "auth"."code_challenge_method" NOT NULL,
    "code_challenge" "text" NOT NULL,
    "provider_type" "text" NOT NULL,
    "provider_access_token" "text",
    "provider_refresh_token" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "authentication_method" "text" NOT NULL,
    "auth_code_issued_at" timestamp with time zone
);


--
-- Name: TABLE "flow_state"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."flow_state" IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."identities" (
    "provider_id" "text" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "identity_data" "jsonb" NOT NULL,
    "provider" "text" NOT NULL,
    "last_sign_in_at" timestamp with time zone,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "email" "text" GENERATED ALWAYS AS ("lower"(("identity_data" ->> 'email'::"text"))) STORED,
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


--
-- Name: TABLE "identities"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."identities" IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN "identities"."email"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN "auth"."identities"."email" IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."instances" (
    "id" "uuid" NOT NULL,
    "uuid" "uuid",
    "raw_base_config" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone
);


--
-- Name: TABLE "instances"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."instances" IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."mfa_amr_claims" (
    "session_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "updated_at" timestamp with time zone NOT NULL,
    "authentication_method" "text" NOT NULL,
    "id" "uuid" NOT NULL
);


--
-- Name: TABLE "mfa_amr_claims"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."mfa_amr_claims" IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."mfa_challenges" (
    "id" "uuid" NOT NULL,
    "factor_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "verified_at" timestamp with time zone,
    "ip_address" "inet" NOT NULL,
    "otp_code" "text",
    "web_authn_session_data" "jsonb"
);


--
-- Name: TABLE "mfa_challenges"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."mfa_challenges" IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."mfa_factors" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "friendly_name" "text",
    "factor_type" "auth"."factor_type" NOT NULL,
    "status" "auth"."factor_status" NOT NULL,
    "created_at" timestamp with time zone NOT NULL,
    "updated_at" timestamp with time zone NOT NULL,
    "secret" "text",
    "phone" "text",
    "last_challenged_at" timestamp with time zone,
    "web_authn_credential" "jsonb",
    "web_authn_aaguid" "uuid"
);


--
-- Name: TABLE "mfa_factors"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."mfa_factors" IS 'auth: stores metadata about factors';


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."one_time_tokens" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "token_type" "auth"."one_time_token_type" NOT NULL,
    "token_hash" "text" NOT NULL,
    "relates_to" "text" NOT NULL,
    "created_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp without time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "one_time_tokens_token_hash_check" CHECK (("char_length"("token_hash") > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."refresh_tokens" (
    "instance_id" "uuid",
    "id" bigint NOT NULL,
    "token" character varying(255),
    "user_id" character varying(255),
    "revoked" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "parent" character varying(255),
    "session_id" "uuid"
);


--
-- Name: TABLE "refresh_tokens"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."refresh_tokens" IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE "auth"."refresh_tokens_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE "auth"."refresh_tokens_id_seq" OWNED BY "auth"."refresh_tokens"."id";


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."saml_providers" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "entity_id" "text" NOT NULL,
    "metadata_xml" "text" NOT NULL,
    "metadata_url" "text",
    "attribute_mapping" "jsonb",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "name_id_format" "text",
    CONSTRAINT "entity_id not empty" CHECK (("char_length"("entity_id") > 0)),
    CONSTRAINT "metadata_url not empty" CHECK ((("metadata_url" = NULL::"text") OR ("char_length"("metadata_url") > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK (("char_length"("metadata_xml") > 0))
);


--
-- Name: TABLE "saml_providers"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."saml_providers" IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."saml_relay_states" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "request_id" "text" NOT NULL,
    "for_email" "text",
    "redirect_to" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "flow_state_id" "uuid",
    CONSTRAINT "request_id not empty" CHECK (("char_length"("request_id") > 0))
);


--
-- Name: TABLE "saml_relay_states"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."saml_relay_states" IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."schema_migrations" (
    "version" character varying(255) NOT NULL
);


--
-- Name: TABLE "schema_migrations"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."schema_migrations" IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."sessions" (
    "id" "uuid" NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "factor_id" "uuid",
    "aal" "auth"."aal_level",
    "not_after" timestamp with time zone,
    "refreshed_at" timestamp without time zone,
    "user_agent" "text",
    "ip" "inet",
    "tag" "text"
);


--
-- Name: TABLE "sessions"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."sessions" IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN "sessions"."not_after"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN "auth"."sessions"."not_after" IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."sso_domains" (
    "id" "uuid" NOT NULL,
    "sso_provider_id" "uuid" NOT NULL,
    "domain" "text" NOT NULL,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK (("char_length"("domain") > 0))
);


--
-- Name: TABLE "sso_domains"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."sso_domains" IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."sso_providers" (
    "id" "uuid" NOT NULL,
    "resource_id" "text",
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    CONSTRAINT "resource_id not empty" CHECK ((("resource_id" = NULL::"text") OR ("char_length"("resource_id") > 0)))
);


--
-- Name: TABLE "sso_providers"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."sso_providers" IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN "sso_providers"."resource_id"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN "auth"."sso_providers"."resource_id" IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE "auth"."users" (
    "instance_id" "uuid",
    "id" "uuid" NOT NULL,
    "aud" character varying(255),
    "role" character varying(255),
    "email" character varying(255),
    "encrypted_password" character varying(255),
    "email_confirmed_at" timestamp with time zone,
    "invited_at" timestamp with time zone,
    "confirmation_token" character varying(255),
    "confirmation_sent_at" timestamp with time zone,
    "recovery_token" character varying(255),
    "recovery_sent_at" timestamp with time zone,
    "email_change_token_new" character varying(255),
    "email_change" character varying(255),
    "email_change_sent_at" timestamp with time zone,
    "last_sign_in_at" timestamp with time zone,
    "raw_app_meta_data" "jsonb",
    "raw_user_meta_data" "jsonb",
    "is_super_admin" boolean,
    "created_at" timestamp with time zone,
    "updated_at" timestamp with time zone,
    "phone" "text" DEFAULT NULL::character varying,
    "phone_confirmed_at" timestamp with time zone,
    "phone_change" "text" DEFAULT ''::character varying,
    "phone_change_token" character varying(255) DEFAULT ''::character varying,
    "phone_change_sent_at" timestamp with time zone,
    "confirmed_at" timestamp with time zone GENERATED ALWAYS AS (LEAST("email_confirmed_at", "phone_confirmed_at")) STORED,
    "email_change_token_current" character varying(255) DEFAULT ''::character varying,
    "email_change_confirm_status" smallint DEFAULT 0,
    "banned_until" timestamp with time zone,
    "reauthentication_token" character varying(255) DEFAULT ''::character varying,
    "reauthentication_sent_at" timestamp with time zone,
    "is_sso_user" boolean DEFAULT false NOT NULL,
    "deleted_at" timestamp with time zone,
    "is_anonymous" boolean DEFAULT false NOT NULL,
    CONSTRAINT "users_email_change_confirm_status_check" CHECK ((("email_change_confirm_status" >= 0) AND ("email_change_confirm_status" <= 2)))
);


--
-- Name: TABLE "users"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE "auth"."users" IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN "users"."is_sso_user"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN "auth"."users"."is_sso_user" IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."alembic_version" (
    "version_num" "text" NOT NULL
);


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."companies" (
    "id" integer NOT NULL,
    "name" character varying,
    "type" character varying
);


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "public"."companies_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "public"."companies_id_seq" OWNED BY "public"."companies"."id";


--
-- Name: company_tag; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."company_tag" (
    "company_id" integer NOT NULL,
    "tag_id" integer NOT NULL
);


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."jobs" (
    "id" integer NOT NULL,
    "title" character varying NOT NULL
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "public"."jobs_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "public"."jobs_id_seq" OWNED BY "public"."jobs"."id";


--
-- Name: salaries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."salaries" (
    "id" integer NOT NULL,
    "company_id" integer,
    "location" character varying NOT NULL,
    "net_salary" double precision,
    "gross_salary" double precision NOT NULL,
    "bonus" double precision,
    "gender" character varying,
    "experience_years_company" integer,
    "total_experience_years" integer,
    "level" character varying,
    "work_type" character varying,
    "added_date" "date",
    "leave_days" integer,
    "email_domain" character varying,
    "verification" character varying
);


--
-- Name: salaries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "public"."salaries_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: salaries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "public"."salaries_id_seq" OWNED BY "public"."salaries"."id";


--
-- Name: salary_job; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."salary_job" (
    "salary_id" integer NOT NULL,
    "job_id" integer NOT NULL
);


--
-- Name: salary_technical_stack; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."salary_technical_stack" (
    "salary_id" integer NOT NULL,
    "technical_stack_id" integer NOT NULL
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."tags" (
    "id" integer NOT NULL,
    "name" character varying NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "public"."tags_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "public"."tags_id_seq" OWNED BY "public"."tags"."id";


--
-- Name: technical_stacks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE "public"."technical_stacks" (
    "id" integer NOT NULL,
    "name" character varying NOT NULL
);


--
-- Name: technical_stacks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "public"."technical_stacks_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: technical_stacks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "public"."technical_stacks_id_seq" OWNED BY "public"."technical_stacks"."id";


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE "realtime"."messages" (
    "id" bigint NOT NULL,
    "topic" "text" NOT NULL,
    "extension" "text" NOT NULL,
    "inserted_at" timestamp(0) without time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp(0) without time zone DEFAULT "now"() NOT NULL,
    "payload" "jsonb",
    "event" "text",
    "private" boolean DEFAULT true,
    "uuid" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

CREATE SEQUENCE "realtime"."messages_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: realtime; Owner: -
--

ALTER SEQUENCE "realtime"."messages_id_seq" OWNED BY "realtime"."messages"."id";


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE "realtime"."schema_migrations" (
    "version" bigint NOT NULL,
    "inserted_at" timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE "realtime"."subscription" (
    "id" bigint NOT NULL,
    "subscription_id" "uuid" NOT NULL,
    "entity" "regclass" NOT NULL,
    "filters" "realtime"."user_defined_filter"[] DEFAULT '{}'::"realtime"."user_defined_filter"[] NOT NULL,
    "claims" "jsonb" NOT NULL,
    "claims_role" "regrole" GENERATED ALWAYS AS ("realtime"."to_regrole"(("claims" ->> 'role'::"text"))) STORED NOT NULL,
    "created_at" timestamp without time zone DEFAULT "timezone"('utc'::"text", "now"()) NOT NULL
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE "realtime"."subscription" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "realtime"."subscription_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE "storage"."buckets" (
    "id" "text" NOT NULL,
    "name" "text" NOT NULL,
    "owner" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "public" boolean DEFAULT false,
    "avif_autodetection" boolean DEFAULT false,
    "file_size_limit" bigint,
    "allowed_mime_types" "text"[],
    "owner_id" "text"
);


--
-- Name: COLUMN "buckets"."owner"; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN "storage"."buckets"."owner" IS 'Field is deprecated, use owner_id instead';


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE "storage"."migrations" (
    "id" integer NOT NULL,
    "name" character varying(100) NOT NULL,
    "hash" character varying(40) NOT NULL,
    "executed_at" timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE "storage"."objects" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "bucket_id" "text",
    "name" "text",
    "owner" "uuid",
    "created_at" timestamp with time zone DEFAULT "now"(),
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "last_accessed_at" timestamp with time zone DEFAULT "now"(),
    "metadata" "jsonb",
    "path_tokens" "text"[] GENERATED ALWAYS AS ("string_to_array"("name", '/'::"text")) STORED,
    "version" "text",
    "owner_id" "text",
    "user_metadata" "jsonb"
);


--
-- Name: COLUMN "objects"."owner"; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN "storage"."objects"."owner" IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE "storage"."s3_multipart_uploads" (
    "id" "text" NOT NULL,
    "in_progress_size" bigint DEFAULT 0 NOT NULL,
    "upload_signature" "text" NOT NULL,
    "bucket_id" "text" NOT NULL,
    "key" "text" NOT NULL COLLATE "pg_catalog"."C",
    "version" "text" NOT NULL,
    "owner_id" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_metadata" "jsonb"
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE "storage"."s3_multipart_uploads_parts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "upload_id" "text" NOT NULL,
    "size" bigint DEFAULT 0 NOT NULL,
    "part_number" integer NOT NULL,
    "bucket_id" "text" NOT NULL,
    "key" "text" NOT NULL COLLATE "pg_catalog"."C",
    "etag" "text" NOT NULL,
    "owner_id" "text",
    "version" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: supabase_migrations; Owner: -
--

CREATE TABLE "supabase_migrations"."schema_migrations" (
    "version" "text" NOT NULL,
    "statements" "text"[],
    "name" "text"
);


--
-- Name: seed_files; Type: TABLE; Schema: supabase_migrations; Owner: -
--

CREATE TABLE "supabase_migrations"."seed_files" (
    "path" "text" NOT NULL,
    "hash" "text" NOT NULL
);


--
-- Name: decrypted_secrets; Type: VIEW; Schema: vault; Owner: -
--

CREATE VIEW "vault"."decrypted_secrets" AS
 SELECT "secrets"."id",
    "secrets"."name",
    "secrets"."description",
    "secrets"."secret",
        CASE
            WHEN ("secrets"."secret" IS NULL) THEN NULL::"text"
            ELSE
            CASE
                WHEN ("secrets"."key_id" IS NULL) THEN NULL::"text"
                ELSE "convert_from"("pgsodium"."crypto_aead_det_decrypt"("decode"("secrets"."secret", 'base64'::"text"), "convert_to"((((("secrets"."id")::"text" || "secrets"."description") || ("secrets"."created_at")::"text") || ("secrets"."updated_at")::"text"), 'utf8'::"name"), "secrets"."key_id", "secrets"."nonce"), 'utf8'::"name")
            END
        END AS "decrypted_secret",
    "secrets"."key_id",
    "secrets"."nonce",
    "secrets"."created_at",
    "secrets"."updated_at"
   FROM "vault"."secrets";


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."refresh_tokens" ALTER COLUMN "id" SET DEFAULT "nextval"('"auth"."refresh_tokens_id_seq"'::"regclass");


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."companies" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."companies_id_seq"'::"regclass");


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."jobs" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."jobs_id_seq"'::"regclass");


--
-- Name: salaries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."salaries" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."salaries_id_seq"'::"regclass");


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."tags" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."tags_id_seq"'::"regclass");


--
-- Name: technical_stacks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."technical_stacks" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."technical_stacks_id_seq"'::"regclass");


--
-- Name: messages id; Type: DEFAULT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY "realtime"."messages" ALTER COLUMN "id" SET DEFAULT "nextval"('"realtime"."messages_id_seq"'::"regclass");


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY "auth"."audit_log_entries" ("instance_id", "id", "payload", "created_at", "ip_address") FROM stdin;
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY "auth"."flow_state" ("id", "user_id", "auth_code", "code_challenge_method", "code_challenge", "provider_type", "provider_access_token", "provider_refresh_token", "created_at", "updated_at", "authentication_method", "auth_code_issued_at") FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY "auth"."identities" ("provider_id", "user_id", "identity_data", "provider", "last_sign_in_at", "created_at", "updated_at", "id") FROM stdin;
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY "auth"."instances" ("id", "uuid", "raw_base_config", "created_at", "updated_at") FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY "auth"."mfa_amr_claims" ("session_id", "created_at", "updated_at", "authentication_method", "id") FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY "auth"."mfa_challenges" ("id", "factor_id", "created_at", "verified_at", "ip_address", "otp_code", "web_authn_session_data") FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY "auth"."mfa_factors" ("id", "user_id", "friendly_name", "factor_type", "status", "created_at", "updated_at", "secret", "phone", "last_challenged_at", "web_authn_credential", "web_authn_aaguid") FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY "auth"."one_time_tokens" ("id", "user_id", "token_type", "token_hash", "relates_to", "created_at", "updated_at") FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY "auth"."refresh_tokens" ("instance_id", "id", "token", "user_id", "revoked", "created_at", "updated_at", "parent", "session_id") FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY "auth"."saml_providers" ("id", "sso_provider_id", "entity_id", "metadata_xml", "metadata_url", "attribute_mapping", "created_at", "updated_at", "name_id_format") FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY "auth"."saml_relay_states" ("id", "sso_provider_id", "request_id", "for_email", "redirect_to", "created_at", "updated_at", "flow_state_id") FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY "auth"."schema_migrations" ("version") FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY "auth"."sessions" ("id", "user_id", "created_at", "updated_at", "factor_id", "aal", "not_after", "refreshed_at", "user_agent", "ip", "tag") FROM stdin;
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY "auth"."sso_domains" ("id", "sso_provider_id", "domain", "created_at", "updated_at") FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY "auth"."sso_providers" ("id", "resource_id", "created_at", "updated_at") FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY "auth"."users" ("instance_id", "id", "aud", "role", "email", "encrypted_password", "email_confirmed_at", "invited_at", "confirmation_token", "confirmation_sent_at", "recovery_token", "recovery_sent_at", "email_change_token_new", "email_change", "email_change_sent_at", "last_sign_in_at", "raw_app_meta_data", "raw_user_meta_data", "is_super_admin", "created_at", "updated_at", "phone", "phone_confirmed_at", "phone_change", "phone_change_token", "phone_change_sent_at", "email_change_token_current", "email_change_confirm_status", "banned_until", "reauthentication_token", "reauthentication_sent_at", "is_sso_user", "deleted_at", "is_anonymous") FROM stdin;
\.


--
-- Data for Name: key; Type: TABLE DATA; Schema: pgsodium; Owner: -
--

COPY "pgsodium"."key" ("id", "status", "created", "expires", "key_type", "key_id", "key_context", "name", "associated_data", "raw_key", "raw_key_nonce", "parent_key", "comment", "user_data") FROM stdin;
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."alembic_version" ("version_num") FROM stdin;
fecdac2bb7ef
\.


--
-- Data for Name: companies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."companies" ("id", "name", "type") FROM stdin;
3	Scaleway	scale-up
4	S3NS	startup
5	Theodo	scale-up
6	Kapela	startup
7	Leroy Merlin	large-enterprise
8	Pack Solutions	sme
9	Red Hat	large-enterprise
10	Stellar	startup
11	Zetaly	startup
12	Worldline	large-enterprise
13	\N	sme
14	Arolla	sme
15	360Learning	scale-up
16	Qwant	sme
17	U TECH	startup
18	Sopra Steria	large-enterprise
19	Ovrsea	startup
20	Lengow	scale-up
21	Liksi	startup
22	\N	startup
23	Marquetis	startup
24	Zenika	sme
26	Qonto	scale-up
27	Decathlon	large-enterprise
28	Association 42	institution
29	Delia	sme
30	\N	startup
31	Citygo	startup
33	Moha app	startup
34	Groupe-Atlantic	large-enterprise
35	Audensiel	large-enterprise
36	Open	startup
37	Orange	large-enterprise
38	Caldera	startup
40	Rail Europe	large-enterprise
41	Agicap	scale-up
42	BPCE-SI	large-enterprise
43	Sogitec	sme
44	sophiagenetics	scale-up
45	Scalian	large-enterprise
46	SharingCloud	scale-up
47	Oodrive	sme
48	Pass Culture	npo
49	Neverhack	startup
50	Capgemini	large-enterprise
51	Rudder	startup
52	Alpha Networks	sme
53	DataGalaxy	scale-up
54	Sap	large-enterprise
55	Indy	startup
56	Docaposte Agility	large-enterprise
57	Odigo	sme
58	SFEIR	sme
59	Wimova	sme
60	Wattsense	startup
61	Deezer	large-enterprise
62	iObeya	scale-up
63	Atos	large-enterprise
64	Jellysmack	scale-up
65	Ubisoft	large-enterprise
66	Viveris	sme
67	BioSerenity	scale-up
68	La Combe Du Lion Vert (Arolla)	startup
69	lelivrescolaire.fr	sme
70	Meltwater	large-enterprise
71	NANCOMCY	startup
72	VDSYS	startup
73	Ministère de la santé	institution
74	Malt	scale-up
75	Descartes Underwriting	scale-up
76	Lucca	scale-up
77	RiseUp	startup
78	Dassault	large-enterprise
79	Agatha Life	sme
80	LeHibou	startup
81	neo technologies SA	sme
82	SQUAD	scale-up
83	Norsys	sme
84	Zebra SAS	large-enterprise
86	PayFit	scale-up
87	Anaqua	large-enterprise
88	Meteodyn	sme
89	Vroomly	scale-up
90	Bedrock Streaming	startup
91	Economie d'Energie	sme
92	Sarbacane	sme
93	Careprod	startup
94	Carbon IT	startup
95	Arcesi	sme
96	Gojob	scale-up
97	Monext	large-enterprise
98	\N	startup
99	api.video	startup
100	Thales	large-enterprise
101	Yespark	startup
102	UBIKA	scale-up
103	IDnow	scale-up
104	Cloudity	scale-up
105	AWS	large-enterprise
106	Enovacom	large-enterprise
107	Kiln	startup
108	Blue Ortho	sme
109	Alten	large-enterprise
110	Teamwork Solution	sme
111	Amadeus	large-enterprise
112	Yacast	scale-up
113	Raincode	sme
114	Equasens	large-enterprise
115	Enaco	large-enterprise
116	Crédit Agricole Group Infrastructure Platform	large-enterprise
117	Facebook (Meta)	large-enterprise
118	Lydia	startup
119	Capgemini Engineering	large-enterprise
120	Microsoft	large-enterprise
121	OVHcloud	large-enterprise
122	HPE	large-enterprise
123	Ouidou	startup
124	Ledger	scale-up
125	Figaro Classifieds	large-enterprise
126	Rezosocial	startup
127	Silae	sme
128	SERMA SAFETY & SECURITY	sme
129	\N	startup
130	Euro-Information	large-enterprise
131	AG2R La Mondiale	large-enterprise
132	XWiki SAS	sme
133	Pictime-groupe	sme
134	elmy (BCM Energy)	startup
135	Evaneos	scale-up
136	ZestMeUp	startup
137	Backmarket	scale-up
138	Labomode Group	startup
139	CGI	large-enterprise
140	Exomind	startup
141	Métropole Européenne de Lille	institution
142	La Mobilery	startup
143	Publicis Sapient France	large-enterprise
145	WIZBII	startup
146	Agorapulse	scale-up
147	EIS	scale-up
148	Thermcross	sme
149	TeleSoft	large-enterprise
150	Inside Group	scale-up
151	Orange Business Services	large-enterprise
152	Cenareo	scale-up
153	DIMO Software	sme
154	Inarix	startup
156	Algolia	scale-up
157	Hoggo	startup
158	AXA	large-enterprise
159	Waiter.love	startup
160	Valeuriad	startup
161	Pôle Emploi DSI	institution
162	Umanis	large-enterprise
163	Datadog	large-enterprise
164	ENI	large-enterprise
166	Roulenloc	startup
167	Itlink	sme
168	Aircelle	large-enterprise
169	DocuSign	large-enterprise
170	Effy	startup
171	Sogilis	sme
172	Doctolib	scale-up
173	Leboncoin	large-enterprise
174	Webedia	large-enterprise
175	ISAE-Supaero	institution
176	Stormshield	sme
177	Lightspeed	large-enterprise
178	Troopers	startup
179	Medias	sme
180	Niji	scale-up
181	Pennylane	startup
182	DataScientest	startup
183	\N	startup
184	Zol	scale-up
185	Scub	startup
186	Ippon Technologies	sme
187	Worldia	startup
188	Dedalus	large-enterprise
189	\N	sme
190	Claranet	large-enterprise
191	Adot	startup
192	FeelU	startup
194	Sneep	startup
195	Joey	startup
196	Sage	large-enterprise
197	os-concept	sme
198	Associatif	institution
199	Ubble	startup
200	DoiT International	scale-up
201	Prolival	sme
202	Spendesk	scale-up
203	Uppler	startup
204	\N	sme
205	Planisware	large-enterprise
206	Digiwin	large-enterprise
207	Modulotech	startup
208	eLamp (360Learning)	scale-up
209	Freelance	freelance
210	OCTO Technology	large-enterprise
211	MyAlfred	startup
212	Alcyone	sme
213	Arhs Group	sme
214	Ministère des armées	institution
215	Siview	startup
216	Groupe IDEA	sme
217	Mee6	startup
218	Lumao	startup
219	Perfectstay	startup
220	Assurinco	sme
221	Meta	large-enterprise
222	Chanel	large-enterprise
223	Elosi	startup
224	SensioLabs	sme
225	OnePoint	large-enterprise
226	Hyperlex	startup
227	Région Sud - PACA	institution
228	Davidson	large-enterprise
229	Criteo	large-enterprise
230	GDA	large-enterprise
231	Ripple Motion	startup
232	Blackrock	large-enterprise
233	\N	sme
234	Altran	large-enterprise
235	\N	startup
236	Kaizen Solutions	startup
237	Timtek	startup
238	Cat-Amania	sme
239	Gatling	startup
240	Cegedim Santé	large-enterprise
241	Sellsy	scale-up
242	Google	large-enterprise
243	Skeepers	scale-up
244	Continental Digital Services France	scale-up
245	Salesforce	large-enterprise
246	Devoteam Revolve	large-enterprise
248	Obat	startup
249	Harmonie Mutuelle	large-enterprise
250	CY Cergy Paris Université	institution
251	Yoop digital	startup
252	Technology and Strategy	sme
253	Odoo	scale-up
254	Orange France	large-enterprise
255	Lunii	startup
256	La Poste	institution
257	Voip Telecom	sme
258	Safran	large-enterprise
259	Dans le vin	sme
260	La Consigne GreenGo	startup
261	Dailymotion	large-enterprise
262	Cresh	startup
263	Neoxia	scale-up
264	Magnolia.fr	startup
265	SII	large-enterprise
266	Sopra Banking Software	large-enterprise
267	Neo Soft	scale-up
268	Teads	large-enterprise
269	Klaxoon	scale-up
270	NTT	large-enterprise
271	Dashlane	scale-up
272	Thiolat packaging	sme
273	Jaune de mars	startup
274	ASE2I	sme
275	LMC France	sme
276	Illuin Technology	startup
277	Kaliop	sme
278	Quamarep	startup
279	WEB-ATRIO	sme
281	Medisupport Services	sme
282	Astek	large-enterprise
283	Batiweb group	sme
284	Akkodis	large-enterprise
285	PMU	large-enterprise
286	October	scale-up
287	Music	sme
288	Navya	scale-up
290	Enedis	large-enterprise
291	AssessFirst	scale-up
293	Genymobile	scale-up
294	Néovia	sme
295	Unis	sme
296	Société Générale	large-enterprise
297	Philips	large-enterprise
298	ArcelorMittal	large-enterprise
299	Shodo	startup
300	Inria	institution
301	SPC Consultants	sme
302	Amazon	large-enterprise
303	Accenture	large-enterprise
304	Kili Technology	startup
305	Positive Thinking	scale-up
306	Devialet	sme
307	Gamestream	startup
308	Apple	large-enterprise
309	Amaris Consulting	large-enterprise
310	Hilti	large-enterprise
311	Murex	large-enterprise
312	Arsène Innovation	startup
313	EDF	large-enterprise
314	IBM	large-enterprise
315	Partoo	scale-up
316	Gartner	large-enterprise
317	Lumen	scale-up
318	SoundHound	scale-up
319	Squarepoint Capital	large-enterprise
320	Canonical	large-enterprise
321	Contentsquare	scale-up
322	BNP Paribas	large-enterprise
323	Oracle	large-enterprise
324	Okta	large-enterprise
325	Huawei	large-enterprise
326	Airbnb	large-enterprise
327	Talend	scale-up
328	Acronis	large-enterprise
329	Cognizant	large-enterprise
330	Intuit	large-enterprise
331	Adevinta	large-enterprise
332	Airbus	large-enterprise
333	FactSet	large-enterprise
334	Western Digital	large-enterprise
335	Stripe	large-enterprise
336	TripAdvisor	large-enterprise
337	Automaticc	large-enterprise
338	BlaBlaCar	scale-up
339	Randstad Digital	large-enterprise
340	Artelys	sme
341	CircularX	scale-up
342	Edicia	sme
343	Canal Plus	large-enterprise
344	Sogelink	large-enterprise
345	BPCE-IT	large-enterprise
346	Smile	sme
\.


--
-- Data for Name: company_tag; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."company_tag" ("company_id", "tag_id") FROM stdin;
15	21
303	5
328	6
328	22
15	23
328	23
331	13
191	2
131	8
131	16
131	15
79	1
79	24
41	0
41	23
41	16
146	23
146	4
326	9
332	27
332	28
168	27
168	28
284	5
212	24
156	23
156	6
52	25
109	5
109	11
109	27
109	28
234	5
234	11
234	27
234	28
111	29
111	23
111	6
309	5
302	10
302	6
302	13
87	23
99	23
308	10
308	23
298	30
298	31
298	32
15	14
303	6
303	0
303	1
303	7
303	8
303	10
303	11
303	13
303	17
303	22
303	23
331	33
331	34
331	35
191	4
191	34
191	23
146	36
146	37
326	29
326	33
326	35
332	30
332	29
168	30
284	27
284	28
284	38
284	30
284	39
284	40
156	41
156	35
156	39
109	40
109	38
109	39
234	40
234	38
234	39
234	30
111	39
309	39
309	40
309	22
309	6
302	35
302	34
302	33
302	39
87	42
87	43
99	6
99	13
99	21
99	25
308	44
308	45
308	46
308	47
308	48
308	6
308	39
308	35
95	5
213	5
213	45
213	39
213	40
14	5
14	49
312	43
274	5
291	23
291	54
291	52
291	55
291	56
291	57
198	17
28	14
220	8
282	5
63	5
63	6
63	22
63	39
63	47
63	48
63	52
63	53
35	5
35	39
35	40
35	58
35	59
35	38
35	27
35	28
35	16
35	11
35	15
35	50
35	60
337	26
337	23
337	61
337	62
337	35
337	63
105	6
105	23
105	22
105	48
105	47
105	53
105	52
105	35
105	39
105	60
105	58
105	59
158	8
158	16
158	15
158	64
137	35
137	33
137	44
137	65
137	66
283	3
283	33
283	34
283	39
283	23
90	19
90	23
90	6
90	67
90	68
67	1
67	69
67	24
67	15
67	70
67	71
67	72
67	58
338	29
338	33
338	73
338	74
338	65
232	16
232	64
232	65
108	69
108	70
108	15
108	58
322	7
322	16
322	64
322	8
322	9
322	75
42	7
42	16
42	8
42	39
38	76
320	6
320	61
320	45
320	22
320	23
320	58
320	39
50	5
50	6
50	7
50	8
50	9
50	10
50	11
50	13
50	14
50	15
50	16
50	17
50	22
50	23
50	38
50	39
50	40
50	47
50	48
50	50
50	52
50	53
50	54
50	55
50	57
50	58
50	59
50	60
119	5
119	40
119	39
119	27
119	28
119	38
119	58
119	59
94	5
94	77
93	69
238	5
238	7
238	8
238	39
238	49
240	1
240	15
240	45
240	6
240	53
240	52
152	23
152	78
152	34
152	37
152	6
139	5
139	6
139	17
139	15
139	16
139	22
139	23
139	39
139	40
139	45
222	10
222	79
222	80
222	81
222	82
222	83
222	84
222	85
222	86
31	87
31	88
190	6
190	22
190	89
190	39
190	59
104	5
104	6
104	23
104	39
104	59
329	5
329	6
329	7
329	8
329	9
329	10
329	11
329	15
329	16
329	17
329	22
329	23
329	47
329	48
329	52
329	53
329	39
329	89
321	23
321	52
321	39
321	35
321	37
321	51
321	53
244	38
244	90
262	0
262	16
229	2
229	4
229	34
229	35
229	23
229	52
229	53
116	7
116	16
116	6
116	22
116	39
250	14
250	21
250	91
250	92
250	93
250	60
261	13
261	67
261	68
261	34
259	94
259	95
261	39
271	22
271	23
271	45
271	96
271	97
78	27
78	28
78	45
78	40
78	39
163	6
163	23
163	52
163	53
163	98
163	99
163	22
53	100
53	52
182	21
182	53
182	52
182	14
182	48
182	47
182	55
182	58
228	5
27	10
27	35
27	101
27	102
27	65
188	15
188	1
188	70
188	72
188	45
188	39
61	13
61	68
61	103
61	104
61	105
61	23
29	30
75	8
75	0
75	23
75	53
75	52
75	65
75	106
75	107
306	44
306	104
306	58
306	79
306	108
306	109
246	5
246	6
246	39
246	58
246	59
206	45
206	39
206	5
206	110
206	6
153	45
153	23
153	30
153	51
153	52
56	39
56	5
56	17
56	15
56	6
56	22
56	23
56	58
56	59
56	60
56	89
172	1
172	23
172	33
172	15
172	39
172	111
172	112
169	23
169	6
169	43
169	39
169	45
200	6
200	5
200	59
200	51
200	52
200	53
200	89
91	50
91	65
91	76
91	39
91	58
313	50
313	65
313	76
313	77
313	113
313	114
313	115
170	76
170	116
147	0
147	117
208	21
208	23
208	119
208	120
134	50
134	33
134	115
134	76
134	113
134	65
223	5
115	121
115	122
115	123
290	50
290	113
290	115
290	88
290	60
290	39
164	50
164	124
164	65
164	115
164	125
106	15
106	45
106	126
106	127
106	1
106	23
106	22
114	1
114	0
130	0
130	7
130	8
130	6
130	22
130	39
135	29
135	33
140	128
140	21
140	47
117	129
117	34
117	35
117	37
117	45
117	47
117	48
117	52
117	53
117	67
117	68
117	130
117	131
117	25
117	33
333	0
333	16
333	52
333	53
333	64
333	95
333	23
192	69
125	33
125	34
125	9
125	132
125	38
125	14
233	0
235	133
307	128
307	6
307	68
307	67
316	5
316	91
316	52
316	53
316	59
316	58
316	23
239	45
239	61
239	99
239	51
239	52
230	134
293	45
293	6
293	135
293	136
293	137
293	61
96	33
96	54
96	55
96	132
242	41
242	34
242	6
242	45
242	46
242	47
242	48
242	135
242	136
242	39
242	35
242	67
242	68
242	138
242	52
242	53
242	44
242	139
242	140
242	141
242	142
242	143
242	144
216	30
216	145
216	40
216	58
216	31
216	50
34	30
34	50
34	146
34	147
34	148
34	149
34	150
34	65
34	115
249	8
249	1
249	15
310	30
310	151
310	40
310	152
310	153
310	45
310	46
310	154
310	95
157	117
157	23
157	8
157	54
122	6
122	22
122	23
122	47
122	48
122	53
122	110
122	89
122	155
122	156
122	157
122	158
122	159
122	39
122	160
122	59
325	11
325	44
325	45
325	46
325	47
325	48
325	6
325	22
325	161
325	136
325	137
325	156
325	157
226	43
226	47
226	23
226	162
226	163
314	5
314	6
314	47
314	48
314	22
314	23
314	45
314	46
314	52
314	53
314	59
314	89
314	91
314	100
314	110
314	134
314	137
314	142
314	157
314	159
314	160
314	161
103	0
103	23
103	7
103	8
103	164
103	97
103	22
103	47
103	48
103	165
103	166
103	167
103	168
276	47
276	48
276	53
276	58
276	91
276	45
276	5
154	20
55	0
55	169
300	91
300	92
300	58
300	47
300	48
300	22
300	61
300	15
300	170
300	45
300	53
150	5
150	6
330	0
330	23
330	6
330	169
330	45
330	171
330	172
330	173
62	23
62	39
62	49
62	58
62	45
62	137
62	143
186	39
186	49
186	58
186	59
186	6
186	53
186	52
175	27
175	28
175	14
175	91
175	92
175	93
175	40
175	58
167	174
273	45
64	13
64	19
64	36
64	67
64	68
64	175
64	176
64	177
195	21
236	0
236	45
236	100
277	39
277	5
277	26
277	61
277	45
277	35
277	49
6	178
304	47
304	48
304	23
304	53
304	179
304	180
107	181
107	45
269	21
269	119
269	182
269	23
269	183
269	143
68	5
68	49
260	65
260	76
260	77
260	184
260	185
260	186
142	1
142	187
256	17
256	188
256	7
256	8
256	35
256	145
256	187
138	189
138	190
173	33
173	35
173	34
173	132
173	9
173	38
173	44
124	0
124	22
124	23
124	44
124	46
124	134
124	191
124	97
80	100
80	54
69	21
69	62
69	14
69	176
69	190
20	35
20	23
20	4
20	33
20	34
20	39
20	10
20	126
7	10
7	192
7	151
7	193
7	35
7	65
7	33
177	23
177	35
177	10
177	6
177	194
177	52
177	195
177	196
21	61
21	197
21	174
275	26
275	198
76	54
76	23
218	199
218	200
317	11
317	6
317	23
317	22
317	137
317	159
317	89
317	25
317	156
317	158
255	21
255	201
255	202
255	104
255	203
255	204
118	0
118	136
118	205
118	206
118	207
264	0
74	33
74	208
74	55
74	54
23	34
23	37
179	13
281	15
217	23
217	36
217	128
217	209
217	210
217	211
217	212
217	213
70	13
70	23
70	52
70	53
70	36
70	37
70	199
70	98
70	214
221	129
221	34
221	35
221	130
221	131
221	47
221	48
221	25
221	13
221	37
221	141
221	142
221	175
221	176
221	177
88	50
88	51
88	52
88	53
88	116
88	115
88	45
88	40
88	91
120	6
120	45
120	46
120	47
120	48
120	128
120	215
120	144
120	137
120	22
120	23
120	39
120	58
120	59
120	44
120	110
120	183
120	142
120	14
120	141
120	129
120	130
120	131
120	53
120	52
120	216
120	217
120	67
120	138
120	41
120	143
120	60
120	139
120	174
120	158
120	160
120	156
120	157
120	218
120	219
73	17
73	15
73	60
214	17
214	28
214	60
214	220
214	27
214	22
207	45
33	15
97	0
97	7
97	221
97	39
97	5
97	23
311	0
311	16
311	7
311	45
311	23
311	222
311	223
311	224
311	225
287	226
211	33
211	136
211	227
211	228
211	229
141	17
141	60
141	88
141	65
141	230
141	231
71	25
71	199
288	38
288	140
288	232
288	88
288	90
288	233
288	234
267	0
267	21
267	15
267	190
267	10
81	5
81	6
263	6
263	58
49	22
49	47
180	235
180	236
83	190
83	40
270	11
270	25
270	6
270	22
270	159
270	89
270	58
270	59
270	53
270	47
270	88
270	91
294	20
294	237
294	238
294	65
294	58
248	151
248	23
210	5
210	39
210	58
210	59
210	49
286	239
286	240
286	241
286	242
286	243
286	244
286	245
57	23
57	246
57	247
57	25
57	6
253	23
253	110
253	248
253	169
253	57
253	249
253	61
253	35
253	45
324	22
324	23
324	6
324	164
324	250
324	97
225	5
225	39
225	251
47	6
47	23
47	22
47	39
47	45
47	53
47	183
36	0
36	7
36	23
323	6
323	110
323	23
323	252
323	45
323	46
323	53
323	52
323	22
323	47
323	48
323	58
323	59
37	11
37	198
37	253
37	6
37	22
37	58
37	39
151	11
151	6
151	22
151	39
151	89
151	5
151	58
151	25
151	156
151	137
151	126
151	159
254	11
254	198
254	142
254	25
254	6
254	22
197	151
123	54
123	100
121	6
121	26
121	160
121	254
121	255
121	89
121	157
121	158
121	159
121	22
121	23
19	145
19	39
19	256
19	257
19	23
8	186
315	23
315	39
315	37
315	258
315	259
48	21
48	260
48	261
48	136
48	262
86	0
86	23
86	54
86	263
86	57
86	55
181	0
181	23
181	169
181	172
181	173
219	264
297	15
297	70
297	44
297	265
297	58
297	65
133	39
133	35
133	15
133	10
133	5
133	6
133	23
205	110
205	23
205	266
205	267
205	268
205	269
205	270
13	23
285	271
285	272
285	273
285	128
285	274
305	5
201	5
143	5
143	39
143	37
143	34
143	35
143	58
143	59
161	17
161	60
161	132
161	57
161	55
161	39
26	0
26	7
26	23
26	16
26	172
26	173
278	133
16	41
16	26
16	275
16	276
16	277
40	29
40	35
40	278
40	279
40	280
113	45
113	281
113	282
113	283
113	51
339	54
339	55
339	57
339	39
339	58
339	59
9	6
9	61
9	45
9	137
9	159
9	160
9	157
9	158
9	144
126	5
231	0
77	0
166	38
166	16
51	0
51	47
227	17
227	60
227	231
227	65
227	58
227	280
227	14
227	15
227	284
227	285
227	260
227	286
227	287
4	6
4	22
4	47
4	48
4	59
258	27
258	28
258	30
258	40
258	58
196	23
196	110
196	169
196	16
196	6
196	263
196	57
196	173
245	6
245	23
245	248
245	288
245	37
245	289
245	290
245	52
245	47
245	45
245	39
245	110
245	36
245	200
245	291
54	110
54	23
54	6
54	45
54	52
54	53
54	57
54	292
54	256
54	217
54	16
54	30
54	10
54	154
92	23
92	138
92	37
92	199
92	293
92	294
3	6
3	23
3	160
3	157
3	158
3	159
3	53
3	89
45	5
45	39
45	40
45	27
45	28
45	50
45	51
45	52
45	53
45	58
45	59
45	89
185	5
241	23
241	248
241	295
241	169
241	296
241	288
241	6
224	45
224	61
224	26
224	23
224	49
224	58
224	59
128	22
128	5
128	40
128	28
128	27
58	5
58	6
58	47
58	48
58	49
58	58
58	59
58	61
58	45
58	39
46	143
46	23
46	78
46	183
46	297
46	298
46	299
299	54
299	5
265	40
265	5
265	27
265	28
265	7
265	11
265	50
265	39
127	54
127	23
127	6
127	263
127	57
215	1
243	300
243	301
194	302
194	303
296	7
296	16
296	64
296	95
296	8
296	75
171	45
171	40
171	27
171	58
171	5
43	27
43	28
43	40
43	304
43	305
44	1
44	24
44	52
44	53
44	23
44	47
44	48
44	6
44	72
44	306
44	307
266	0
266	7
266	308
266	45
266	23
266	39
266	6
18	5
18	39
18	6
18	22
18	7
18	8
18	60
18	27
18	28
18	15
18	16
18	17
18	159
18	89
318	47
318	48
318	104
318	103
318	309
318	45
301	310
301	311
202	0
202	23
202	16
202	312
202	172
202	45
82	6
82	22
319	16
319	64
319	95
319	53
319	52
319	313
319	314
319	315
22	316
10	134
10	191
10	0
10	317
10	318
10	319
176	22
176	23
176	320
176	6
176	17
176	28
176	321
335	0
335	23
335	35
335	205
335	308
335	45
335	322
335	323
335	324
335	325
335	221
327	126
327	100
327	6
327	23
327	52
327	53
268	2
268	34
268	141
268	67
268	13
268	4
110	37
252	5
252	16
149	0
149	100
100	27
100	28
100	22
100	284
100	97
100	17
100	58
100	40
100	91
100	23
100	326
100	327
5	39
5	49
5	45
5	26
5	58
5	59
148	76
148	150
272	30
272	186
272	123
237	0
336	29
336	33
336	328
336	195
336	198
336	199
178	54
17	145
17	284
199	164
199	165
199	166
199	167
199	168
102	22
102	23
65	128
65	68
65	45
65	39
65	47
65	130
65	131
162	5
162	53
162	100
162	6
162	39
162	47
162	217
162	52
129	1
295	5
203	329
203	33
203	23
203	35
160	5
160	100
160	6
72	198
66	40
66	5
66	39
66	58
66	59
257	11
257	25
257	6
257	89
89	38
89	33
89	23
89	331
159	332
159	333
60	3
60	23
60	174
60	50
60	88
60	334
60	335
279	45
174	13
174	68
174	187
174	62
174	34
174	67
174	128
174	336
174	175
334	44
334	46
334	155
334	337
334	6
59	77
59	145
189	338
145	21
145	132
145	339
145	55
145	119
187	264
12	0
12	221
12	39
12	35
12	308
12	340
132	23
132	61
132	45
132	183
132	341
132	342
112	13
112	226
101	3
101	33
101	136
101	74
251	5
251	198
251	39
84	77
84	100
24	5
24	49
24	58
24	59
24	343
24	344
24	39
136	54
11	345
11	346
184	77
184	347
341	77
342	326
342	88
343	13
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."jobs" ("id", "title") FROM stdin;
1	software engineer
2	data science consultant
4	devops engineer
5	site reliability engineer
6	fullstack developer
7	ops engineer
9	support technician
15	backend software engineer
19	backend developer
20	it consultant
23	qa engineer
25	mobile software architect
27	data analyst
29	software designer-developer
32	tech lead
39	solution architect
42	data engineer
45	analyst developer
46	mobile developer
47	frontend developer
52	cloud engineer
53	cloud developer
54	cybersecurity engineer
55	web developer
58	it engineer
60	sap developer
63	programmer analyst
66	frontend tech lead
67	project manager
73	software developer
74	sap consultant
75	cloud solution architect
78	cybersecurity consultant
79	sofware development engineer in test (sdet)
80	r&d engineer
81	web engineer
83	tech lead android/flutter
85	cloud ops
91	infrastructure architect
93	system/network trainer
95	phd
97	staff engineer
102	system administrator
103	network administrator
104	network engineer
105	lead developer
106	software architect
110	data scientist
111	software designer & developer
\.


--
-- Data for Name: salaries; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."salaries" ("id", "company_id", "location", "net_salary", "gross_salary", "bonus", "gender", "experience_years_company", "total_experience_years", "level", "work_type", "added_date", "leave_days", "email_domain", "verification") FROM stdin;
2	\N	paris	\N	50000	\N	\N	2	4	mid	hybrid	2024-10-11	\N	\N	verified
3	\N	paris	\N	52000	\N	\N	4	7	lead	remote	2024-09-09	\N	\N	verified
4	3	paris	\N	55000	\N	\N	1	11	mid	hybrid	2024-09-09	\N	\N	verified
5	4	paris	\N	52000	\N	\N	0	3	junior	hybrid	2024-09-08	\N	\N	verified
6	5	paris	\N	46000	\N	\N	1	1	junior	hybrid	2024-09-08	\N	\N	verified
7	6	lille	\N	44000	\N	\N	2	6	mid	hybrid	2024-09-06	\N	\N	verified
8	7	lille	\N	44000	\N	\N	3	3	junior	hybrid	2024-09-06	\N	\N	verified
9	\N	paris	\N	54000	\N	\N	1	8	senior	hybrid	2024-09-06	\N	\N	verified
10	8	avignon	\N	29000	\N	\N	2	2	junior	hybrid	2024-09-06	\N	\N	verified
11	9	remote	\N	100000	\N	\N	12	20	senior	remote	2024-09-06	\N	\N	verified
12	3	lille	\N	61000	\N	\N	15	\N	mid	hybrid	2024-09-06	\N	\N	verified
13	10	bruxelles	\N	63000	\N	\N	17	\N	senior	hybrid	2024-09-06	\N	\N	verified
14	11	nantes	\N	42000	\N	\N	3	5	mid	hybrid	2024-09-06	\N	\N	verified
15	12	lyon	\N	55000	\N	\N	11	11	senior	hybrid	2024-07-27	\N	\N	verified
16	13	remote	\N	105000	\N	\N	5	20	lead	remote	2024-07-12	\N	\N	verified
17	14	paris	\N	70000	\N	\N	3	17	senior	hybrid	2024-07-09	\N	\N	verified
18	15	remote	\N	68000	\N	\N	3	5	senior	remote	2024-07-01	\N	\N	verified
19	16	remote	\N	63000	\N	\N	3	8	mid	remote	2024-06-20	\N	\N	verified
20	17	nantes	\N	45000	\N	\N	3	4	junior	hybrid	2024-06-17	\N	\N	verified
21	18	luxembourg	\N	49884	\N	\N	\N	\N	junior	hybrid	2024-06-12	\N	\N	verified
22	19	paris	\N	68000	\N	\N	2	5	lead	\N	2024-06-05	\N	\N	verified
23	20	nantes	\N	65000	\N	\N	0	7	senior	hybrid	2024-06-04	\N	\N	verified
24	21	nantes	\N	36000	\N	\N	0	3	junior	hybrid	2024-05-31	\N	\N	verified
25	22	paris	\N	40000	\N	\N	3	3	junior	remote	2024-05-30	\N	\N	verified
26	23	levallois-perret	\N	54600	\N	\N	8	9	senior	hybrid	2024-05-29	\N	\N	verified
27	24	bordeaux	\N	49800	\N	\N	7	10	mid	hybrid	2024-05-29	\N	\N	verified
28	42	aix-en-provence	\N	47000	\N	\N	1	3	junior	remote	2024-05-28	\N	\N	verified
29	26	paris	\N	44000	\N	\N	2	2	junior	\N	2024-05-24	\N	\N	verified
30	13	annecy	\N	49100	\N	\N	1	5	mid	\N	2024-05-24	\N	\N	verified
31	27	nantes	\N	56000	\N	\N	1	9	senior	\N	2024-05-24	\N	\N	verified
32	28	paris	\N	41000	\N	\N	3	\N	mid	\N	2024-05-18	\N	\N	verified
33	29	rennes	\N	42500	\N	\N	2	6	mid	\N	2024-05-17	\N	\N	verified
34	30	rennes	\N	70000	\N	\N	2	12	mid	remote	2024-05-16	\N	\N	verified
35	31	paris	\N	65000	\N	\N	2	5	mid	\N	2024-05-13	\N	\N	verified
36	86	paris	\N	62000	\N	\N	2	8	senior	\N	2024-05-13	\N	\N	verified
37	33	lille	\N	49000	\N	\N	1	7	senior	\N	2024-05-12	\N	\N	verified
38	34	nantes	\N	58000	\N	\N	1	7	senior	\N	2024-05-12	\N	\N	verified
39	35	tours	\N	39000	\N	\N	3	3	mid	\N	2024-05-10	\N	\N	verified
40	36	nantes	\N	37500	\N	\N	\N	3	junior	\N	2024-05-09	\N	\N	verified
41	37	rennes	\N	37800	\N	\N	3	4	junior	\N	2024-05-09	\N	\N	verified
42	86	remote	\N	80000	\N	\N	1	9	senior	remote	2024-05-08	\N	\N	verified
43	38	strasbourg	\N	36900	\N	\N	2	3	mid	\N	2024-05-08	\N	\N	verified
44	225	nantes	\N	37000	\N	\N	2	2	junior	\N	2024-05-08	\N	\N	verified
45	27	nantes	\N	56000	\N	\N	1	10	senior	\N	2024-05-08	\N	\N	verified
46	40	nantes	\N	50000	\N	\N	2	7	mid	\N	2024-05-01	\N	\N	verified
47	18	paris	\N	56000	\N	\N	6	6	mid	\N	2024-04-27	\N	\N	verified
48	41	lyon	\N	65000	\N	\N	2	8	senior	remote	2024-04-24	\N	\N	verified
49	16	paris	\N	60000	\N	\N	7	8	senior	remote	2024-04-24	\N	\N	verified
50	42	toulouse	\N	48500	\N	\N	2	5	mid	\N	2024-04-19	\N	\N	verified
51	43	rennes	\N	56000	\N	\N	12	15	mid	\N	2024-03-21	\N	\N	verified
52	44	bidart	\N	68000	\N	\N	3	15	senior	\N	2024-03-03	\N	\N	verified
53	16	remote	\N	110000	\N	\N	3	13	senior	remote	2024-02-20	\N	\N	verified
54	45	paris	\N	47000	\N	\N	2	5	mid	\N	2024-02-12	\N	\N	verified
55	46	nantes	\N	42000	\N	\N	15	15	mid	\N	2024-02-07	\N	\N	verified
56	37	caen	\N	52000	\N	\N	11	12	senior	\N	2024-01-22	\N	\N	verified
57	47	marseille	\N	70000	\N	\N	0	25	senior	\N	2024-01-14	\N	\N	verified
58	48	paris	\N	48000	\N	\N	1	3	mid	\N	2024-01-09	\N	\N	verified
59	49	toulouse	\N	46000	\N	\N	4	4	mid	\N	2024-01-08	\N	\N	verified
60	50	paris	\N	65000	\N	\N	1	6	senior	\N	2024-01-07	\N	\N	verified
61	12	seclin	\N	42000	\N	\N	2	2	junior	\N	2024-01-06	\N	\N	verified
62	51	paris	\N	58000	\N	\N	11	11	lead	\N	2024-01-05	\N	\N	verified
63	52	paris	\N	45000	\N	\N	2	12	senior	\N	2024-01-03	\N	\N	verified
64	15	remote	\N	64100	\N	\N	3	5	mid	remote	2024-01-01	\N	\N	verified
65	27	lyon	\N	54000	\N	\N	1	6	senior	\N	2023-12-13	\N	\N	verified
66	225	nantes	\N	53000	\N	\N	5	11	lead	\N	2023-12-05	\N	\N	verified
67	225	bordeaux	\N	49000	\N	\N	6	7	lead	\N	2023-11-24	\N	\N	verified
68	50	rennes	\N	43000	\N	\N	4	4	lead	\N	2023-11-21	\N	\N	verified
69	53	saint-sulpice-laurière	\N	41000	\N	\N	2	2	junior	remote	2023-11-20	\N	\N	verified
70	54	paris	\N	45000	\N	\N	1	3	mid	\N	2023-11-14	\N	\N	verified
71	55	lyon	\N	65000	\N	\N	0	9	senior	\N	2023-11-12	\N	\N	verified
72	225	paris	\N	40000	\N	\N	1	2	junior	\N	2023-10-26	\N	\N	verified
73	56	rouen	\N	34000	\N	\N	2	2	junior	\N	2023-10-12	\N	\N	verified
74	37	caen	\N	54000	\N	\N	9	17	senior	\N	2023-10-09	\N	\N	verified
75	\N	nantes	\N	38000	\N	\N	5	7	mid	\N	2023-09-29	\N	\N	verified
76	50	toulouse	\N	38000	\N	\N	8	10	senior	\N	2023-09-28	\N	\N	verified
77	57	rouen	\N	43000	\N	\N	\N	4	junior	\N	2023-09-21	\N	\N	verified
78	58	nantes	\N	50000	\N	\N	3	5	mid	\N	2023-09-20	\N	\N	verified
79	59	lyon	\N	35000	\N	\N	3	3	mid	\N	2023-09-19	\N	\N	verified
80	60	lyon	\N	60000	\N	\N	\N	8	senior	\N	2023-09-12	\N	\N	verified
81	225	nantes	\N	53000	\N	\N	3	14	lead	\N	2023-08-30	\N	\N	verified
82	58	paris	\N	50000	\N	\N	2	8	mid	\N	2023-08-29	\N	\N	verified
83	61	paris	\N	80000	\N	\N	7	17	mid	remote	2023-08-21	\N	\N	verified
84	225	nantes	\N	40000	\N	\N	2	4	mid	\N	2023-08-08	\N	\N	verified
85	62	remote	\N	72000	\N	\N	2	16	senior	remote	2023-07-07	\N	\N	verified
86	63	sophia-antipolis	\N	44000	\N	\N	1	10	mid	\N	2023-06-27	\N	\N	verified
87	64	paris	\N	46300	\N	\N	1	3	junior	remote	2023-06-27	\N	\N	verified
88	61	bordeaux	\N	69000	\N	\N	2	14	senior	\N	2023-06-22	\N	\N	verified
89	65	bordeaux	\N	72000	\N	\N	2	12	senior	\N	2023-06-20	\N	\N	verified
90	65	saint-mandé	\N	59400	\N	\N	1	6	mid	\N	2023-06-18	\N	\N	verified
91	61	bordeaux	\N	68000	\N	\N	7	15	senior	\N	2023-06-17	\N	\N	verified
92	61	bordeaux	\N	70000	\N	\N	5	11	senior	\N	2023-06-16	\N	\N	verified
93	61	bordeaux	\N	73000	\N	\N	7	10	mid	\N	2023-06-12	\N	\N	verified
94	65	bordeaux	\N	72000	\N	\N	2	11	senior	\N	2023-06-10	\N	\N	verified
95	66	toulouse	\N	29000	\N	\N	2	2	junior	\N	2023-06-09	\N	\N	verified
96	67	paris	\N	65000	\N	\N	0	3	mid	\N	2023-06-06	\N	\N	verified
97	68	paris	\N	51000	\N	\N	4	8	mid	remote	2023-05-10	\N	\N	verified
98	69	lyon	\N	56500	\N	\N	4	9	senior	\N	2023-05-07	\N	\N	verified
99	70	paris	\N	59000	\N	\N	11	16	senior	remote	2023-05-03	\N	\N	verified
100	71	nancy	\N	35000	\N	\N	1	7	mid	\N	2023-05-02	\N	\N	verified
101	72	la farlède	\N	27600	\N	\N	3	\N	mid	\N	2023-04-27	\N	\N	verified
102	73	paris	\N	90000	\N	\N	6	7	senior	\N	2023-04-27	\N	\N	verified
103	74	remote	\N	75000	\N	\N	\N	11	lead	remote	2023-04-26	\N	\N	verified
104	75	paris	\N	51000	\N	\N	2	0	junior	\N	2023-04-25	\N	\N	verified
105	76	nantes	\N	64000	\N	\N	2	13	senior	\N	2023-04-11	\N	\N	verified
106	68	paris	\N	62000	\N	\N	5	10	senior	\N	2023-04-04	\N	\N	verified
107	77	paris	\N	51000	\N	\N	6	6	mid	\N	2023-03-28	\N	\N	verified
108	78	paris	\N	53000	\N	\N	4	0	junior	\N	2023-03-09	\N	\N	verified
109	225	bordeaux	\N	73000	\N	\N	8	20	lead	\N	2023-02-22	\N	\N	verified
110	79	lyon	\N	44000	\N	\N	1	12	senior	remote	2023-02-20	\N	\N	verified
111	80	ile maurice	\N	45000	\N	\N	1	3	mid	\N	2023-02-18	\N	\N	verified
112	81	suisse	\N	140000	\N	\N	11	18	senior	\N	2023-02-18	\N	\N	verified
113	9	remote	\N	110000	\N	\N	12	20	principal	remote	2023-02-18	\N	\N	verified
114	82	paris	\N	50000	\N	\N	1	2	mid	\N	2023-02-18	\N	\N	verified
115	83	nantes	\N	45850	\N	\N	4	8	lead	\N	2023-02-17	\N	\N	verified
116	50	pau	\N	34000	\N	\N	1	4	junior	\N	2023-02-17	\N	\N	verified
117	50	pau	\N	34000	\N	\N	1	4	junior	\N	2023-02-17	\N	\N	verified
118	84	toulouse	\N	64000	\N	\N	3	20	senior	\N	2023-02-17	\N	\N	verified
119	83	nantes	\N	38500	\N	\N	1	5	mid	\N	2023-02-17	\N	\N	verified
120	86	paris	\N	68000	\N	\N	\N	4	senior	\N	2023-02-17	\N	\N	verified
121	16	remote	\N	70000	\N	\N	0	10	senior	remote	2023-02-17	\N	\N	verified
122	87	pau	\N	33000	\N	\N	0	3	junior	\N	2023-02-17	\N	\N	verified
123	88	nantes	\N	36200	\N	\N	5	8	mid	\N	2023-02-15	\N	\N	verified
124	18	toulouse	\N	37000	\N	\N	2	5	mid	\N	2023-02-15	\N	\N	verified
125	89	paris	\N	69400	\N	\N	0	7	lead	remote	2023-02-15	\N	\N	verified
126	18	toulouse	\N	37000	\N	\N	2	5	mid	\N	2023-02-15	\N	\N	verified
127	90	lyon	\N	55000	\N	\N	5	7	senior	\N	2023-02-15	\N	\N	verified
128	91	paris	\N	40000	\N	\N	3	3	mid	\N	2023-02-13	\N	\N	verified
129	92	lille	\N	40000	\N	\N	2	5	mid	\N	2023-02-13	\N	\N	verified
130	37	province	\N	44000	\N	\N	5	7	mid	\N	2023-02-13	\N	\N	verified
131	93	montpellier	\N	37000	\N	\N	2	2	mid	\N	2023-02-13	\N	\N	verified
132	94	paris	\N	58000	\N	\N	4	4	mid	\N	2023-02-12	\N	\N	verified
133	95	nantes	\N	30000	\N	\N	2	2	mid	\N	2023-02-12	\N	\N	verified
134	96	aix-en-provence	\N	40000	\N	\N	1	1	mid	\N	2023-02-12	\N	\N	verified
135	97	aix-en-provence	\N	44000	\N	\N	2	\N	mid	\N	2023-02-12	\N	\N	verified
136	98	toulouse	\N	39500	\N	\N	1	4	mid	\N	2023-02-12	\N	\N	verified
137	99	toulouse	\N	69000	\N	\N	0	7	mid	\N	2023-02-12	\N	\N	verified
138	100	paris	\N	52000	\N	\N	3	4	mid	\N	2023-02-11	\N	\N	verified
139	101	paris	\N	51000	\N	\N	2	5	mid	\N	2023-02-11	\N	\N	verified
140	102	brest	\N	47000	\N	\N	1	5	mid	remote	2023-02-11	\N	\N	verified
141	103	rennes	\N	38000	\N	\N	2	2	mid	\N	2023-02-11	\N	\N	verified
142	104	paris	\N	45000	\N	\N	5	5	mid	\N	2023-02-11	\N	\N	verified
143	105	paris	\N	60000	\N	\N	0	2	mid	\N	2023-02-11	\N	\N	verified
144	106	marseille	\N	57000	\N	\N	7	\N	senior	\N	2023-02-11	\N	\N	verified
145	107	paris	\N	90000	\N	\N	1	10	senior	\N	2023-02-11	\N	\N	verified
146	108	meylan	\N	41500	\N	\N	3	3	mid	\N	2023-02-11	\N	\N	verified
147	109	toulouse	\N	34500	\N	\N	1	1	mid	\N	2023-02-11	\N	\N	verified
148	110	lille	\N	50000	\N	\N	1	4	mid	\N	2023-02-11	\N	\N	verified
149	75	paris	\N	51000	\N	\N	0	0	mid	\N	2023-02-11	\N	\N	verified
150	111	sophia-antipolis	\N	54000	\N	\N	3	3	mid	\N	2023-02-11	\N	\N	verified
151	112	remote	\N	102336	\N	\N	4	21	lead	remote	2023-02-11	\N	\N	verified
152	113	bruxelles	\N	45000	\N	\N	2	2	mid	\N	2023-02-11	\N	\N	verified
153	114	nancy	\N	37000	\N	\N	4	4	mid	\N	2023-02-11	\N	\N	verified
154	115	lille	\N	43000	\N	\N	2	6	mid	\N	2023-02-11	\N	\N	verified
155	116	paris	\N	57000	\N	\N	7	7	mid	\N	2023-02-11	\N	\N	verified
156	36	grenoble	\N	43000	\N	\N	0	5	mid	\N	2023-02-11	\N	\N	verified
157	117	londres	\N	105000	\N	\N	1	5	mid	\N	2023-02-11	\N	\N	verified
158	118	remote	\N	50000	\N	\N	1	3	mid	remote	2023-02-11	\N	\N	verified
159	119	lyon	\N	39000	\N	\N	1	9	lead	\N	2023-02-11	\N	\N	verified
160	120	paris	\N	102500	\N	\N	1	7	mid	\N	2023-02-11	\N	\N	verified
161	121	nantes	\N	53000	\N	\N	4	4	mid	\N	2023-02-11	\N	\N	verified
162	63	grenoble	\N	40000	\N	\N	4	4	mid	\N	2023-02-11	\N	\N	verified
163	122	grenoble	\N	50000	\N	\N	3	9	mid	\N	2023-02-11	\N	\N	verified
164	123	paris	\N	40000	\N	\N	1	2	junior	\N	2023-02-11	\N	\N	verified
165	124	paris	\N	63000	\N	\N	1	8	mid	\N	2023-02-11	\N	\N	verified
166	125	paris	\N	50000	\N	\N	\N	\N	mid	\N	2023-02-07	\N	\N	verified
167	126	paris	\N	30000	\N	\N	2	2	mid	\N	2023-02-02	\N	\N	verified
168	127	nantes	\N	45000	\N	\N	\N	8	mid	\N	2023-02-01	\N	\N	verified
169	66	toulouse	\N	38000	\N	\N	2	2	mid	\N	2023-01-31	\N	\N	verified
170	128	paris	\N	50000	\N	\N	2	8	mid	\N	2023-01-28	\N	\N	verified
171	121	nantes	\N	57000	\N	\N	5	15	mid	\N	2023-01-27	\N	\N	verified
172	15	paris	\N	52000	\N	\N	0	0	junior	remote	2023-01-26	\N	\N	verified
173	129	paris	\N	55000	\N	\N	0	9	mid	remote	2023-01-23	\N	\N	verified
174	130	strasbourg	\N	42000	\N	\N	6	12	mid	\N	2023-01-20	\N	\N	verified
175	131	esvres	\N	42000	\N	\N	3	8	mid	\N	2023-01-20	\N	\N	verified
176	132	remote	\N	45000	\N	\N	3	12	mid	remote	2023-01-20	\N	\N	verified
177	133	lille	\N	37000	\N	\N	2	2	mid	\N	2023-01-20	\N	\N	verified
178	50	toulouse	\N	39500	\N	\N	2	6	lead	\N	2023-01-20	\N	\N	verified
179	134	lyon	\N	48000	\N	\N	2	6	mid	\N	2023-01-17	\N	\N	verified
180	135	paris	\N	58000	\N	\N	4	6	mid	remote	2023-01-13	\N	\N	verified
181	135	paris	\N	65000	\N	\N	7	9	mid	\N	2023-01-13	\N	\N	verified
182	18	rennes	\N	34000	\N	\N	2	6	lead	\N	2023-01-09	\N	\N	verified
183	136	paris	\N	60000	\N	\N	5	22	lead	remote	2023-01-06	\N	\N	verified
184	137	paris	\N	67000	\N	\N	2	11	senior	remote	2023-01-04	\N	\N	verified
185	138	strasbourg	\N	32000	\N	\N	1	2	mid	\N	2023-01-03	\N	\N	verified
186	139	toulouse	\N	37000	\N	\N	4	4	mid	\N	2023-01-01	\N	\N	verified
187	140	rennes	\N	45000	\N	\N	1	10	mid	\N	2022-12-30	\N	\N	verified
188	141	lille	\N	29000	\N	\N	2	14	mid	\N	2022-12-22	\N	\N	verified
189	15	paris	\N	52000	\N	\N	0	3	junior	remote	2022-12-14	\N	\N	verified
190	142	tours	\N	52000	\N	\N	10	\N	lead	\N	2022-12-08	\N	\N	verified
191	143	paris	\N	58700	\N	\N	3	6	mid	\N	2022-10-31	\N	\N	verified
192	\N	strasbourg	\N	29000	\N	\N	2	2	mid	\N	2022-10-27	\N	\N	verified
193	145	grenoble	\N	55000	\N	\N	5	6	mid	\N	2022-10-27	\N	\N	verified
194	15	nantes	\N	52000	\N	\N	1	4	junior	\N	2022-10-19	\N	\N	verified
195	15	remote	\N	48000	\N	\N	0	1	junior	remote	2022-10-18	\N	\N	verified
196	15	rennes	\N	55000	\N	\N	\N	5	mid	remote	2022-10-18	\N	\N	verified
197	146	paris	\N	60000	\N	\N	0	5	mid	\N	2022-10-17	\N	\N	verified
198	61	bordeaux	\N	70000	\N	\N	2	12	mid	\N	2022-10-12	\N	\N	verified
199	147	montargis	\N	31200	\N	\N	3	3	mid	\N	2022-10-12	\N	\N	verified
200	148	lyon	\N	29000	\N	\N	2	2	mid	\N	2022-10-11	\N	\N	verified
201	149	paris	\N	54000	\N	\N	8	8	lead	\N	2022-10-02	\N	\N	verified
202	150	toulouse	\N	38000	\N	\N	3	4	mid	\N	2022-10-02	\N	\N	verified
203	151	toulouse	\N	36500	\N	\N	0	2	mid	\N	2022-09-25	\N	\N	verified
204	152	toulouse	\N	50835	\N	\N	5	7	lead	\N	2022-09-22	\N	\N	verified
205	28	paris	\N	35000	\N	\N	\N	\N	mid	\N	2022-09-22	\N	\N	verified
206	153	bidart	\N	34800	\N	\N	2	2	mid	\N	2022-09-19	\N	\N	verified
207	154	remote	\N	40295	\N	\N	3	5	mid	remote	2022-09-17	\N	\N	verified
208	68	paris	\N	55000	\N	\N	4	9	mid	\N	2022-09-16	\N	\N	verified
209	156	paris	\N	65000	\N	\N	0	5	mid	\N	2022-09-14	\N	\N	verified
210	157	paris	\N	42000	\N	\N	1	1	junior	\N	2022-09-14	\N	\N	verified
211	158	paris	\N	52000	\N	\N	1	4	mid	\N	2022-09-13	\N	\N	verified
212	159	marseille	\N	40000	\N	\N	2	3	mid	\N	2022-09-13	\N	\N	verified
213	160	nantes	\N	40000	\N	\N	2	9	mid	\N	2022-09-13	\N	\N	verified
214	138	strasbourg	\N	26748	\N	\N	1	2	mid	\N	2022-09-12	\N	\N	verified
215	161	nantes	\N	49000	\N	\N	6	7	mid	\N	2022-09-09	\N	\N	verified
216	162	paris	\N	70000	\N	\N	24	24	mid	\N	2022-09-09	\N	\N	verified
217	24	rennes	\N	46000	\N	\N	7	13	mid	\N	2022-09-08	\N	\N	verified
218	15	paris	\N	59000	\N	\N	2	4	mid	remote	2022-09-06	\N	\N	verified
219	74	remote	\N	57000	\N	\N	0	4	mid	remote	2022-09-02	\N	\N	verified
220	30	rennes	\N	38000	\N	\N	3	7	mid	\N	2022-09-02	\N	\N	verified
221	163	paris	\N	66000	\N	\N	1	4	mid	\N	2022-09-02	\N	\N	verified
222	164	rennes	\N	35000	\N	\N	\N	6	mid	\N	2022-09-01	\N	\N	verified
223	\N	créteil	\N	70000	\N	\N	11	32	mid	\N	2022-08-31	\N	\N	verified
224	166	aix-les-bains	\N	35000	\N	\N	1	5	mid	\N	2022-08-31	\N	\N	verified
225	167	rennes	\N	25000	\N	\N	1	\N	lead	\N	2022-08-31	\N	\N	verified
226	168	le havre	\N	92000	\N	\N	3	10	mid	\N	2022-08-31	\N	\N	verified
227	169	paris	\N	120000	\N	\N	0	22	mid	remote	2022-08-31	\N	\N	verified
228	50	rennes	\N	42000	\N	\N	5	6	mid	\N	2022-08-30	\N	\N	verified
229	170	paris	\N	42000	\N	\N	2	4	mid	\N	2022-08-30	\N	\N	verified
230	171	grenoble	\N	40600	\N	\N	2	8	mid	\N	2022-08-30	\N	\N	verified
231	172	paris	\N	51000	\N	\N	2	2	mid	remote	2022-08-29	\N	\N	verified
232	132	remote	\N	49700	\N	\N	3	8	mid	remote	2022-08-29	\N	\N	verified
233	173	paris	\N	51000	\N	\N	3	5	mid	\N	2022-08-27	\N	\N	verified
234	174	france	\N	60000	\N	\N	5	12	senior	\N	2022-08-26	\N	\N	verified
235	63	grenoble	\N	39000	\N	\N	6	6	mid	\N	2022-08-26	\N	\N	verified
236	175	toulouse	\N	27000	\N	\N	2	2	mid	\N	2022-08-25	\N	\N	verified
237	176	lille	\N	39000	\N	\N	2	3	mid	\N	2022-08-25	\N	\N	verified
238	75	paris	\N	46000	\N	\N	0	0	mid	\N	2022-08-25	\N	\N	verified
239	58	nantes	\N	53000	\N	\N	3	6	staff	\N	2022-08-25	\N	\N	verified
240	\N	paris	\N	78000	\N	\N	4	15	staff	\N	2022-08-25	\N	\N	verified
241	177	new zealand	\N	110000	\N	\N	\N	11	mid	\N	2022-08-25	\N	\N	verified
242	178	nantes	\N	37000	\N	\N	10	10	mid	\N	2022-08-23	\N	\N	verified
243	179	remote	\N	95000	\N	\N	20	25	mid	remote	2022-08-23	\N	\N	verified
244	180	bordeaux	\N	52500	\N	\N	3	8	mid	\N	2022-08-23	\N	\N	verified
245	14	paris	\N	66000	\N	\N	11	14	senior	\N	2022-08-23	\N	\N	verified
246	181	paris	\N	60000	\N	\N	\N	3	mid	remote	2022-08-23	\N	\N	verified
247	182	puteaux	\N	50000	\N	\N	1	4	mid	\N	2022-08-23	\N	\N	verified
248	18	la défense	\N	42000	\N	\N	0	0	mid	\N	2022-08-23	\N	\N	verified
249	183	caen	\N	34000	\N	\N	3	3	mid	\N	2022-08-23	\N	\N	verified
250	184	lyon	\N	54000	\N	\N	2	13	mid	\N	2022-08-23	\N	\N	verified
251	185	bordeaux	\N	42000	\N	\N	0	5	mid	\N	2022-08-23	\N	\N	verified
252	\N	nantes	\N	43000	\N	\N	3	6	mid	\N	2022-08-23	\N	\N	verified
253	186	paris	\N	45000	\N	\N	0	1	mid	\N	2022-08-23	\N	\N	verified
254	\N	lyon	\N	42000	\N	\N	2	2	mid	\N	2022-08-23	\N	\N	verified
255	30	remote	\N	140000	\N	\N	2	16	mid	remote	2022-08-23	\N	\N	verified
256	187	paris	\N	42000	\N	\N	5	7	mid	\N	2022-08-23	\N	\N	verified
257	\N	strasbourg	\N	48000	\N	\N	2	12	mid	\N	2022-08-23	\N	\N	verified
258	65	rennes	\N	75000	\N	\N	\N	8	mid	\N	2022-08-23	\N	\N	verified
259	186	lyon	\N	69000	\N	\N	6	13	mid	\N	2022-08-23	\N	\N	verified
260	18	grenoble	\N	54700	\N	\N	7	7	mid	\N	2022-08-23	\N	\N	verified
261	24	rennes	\N	48000	\N	\N	4	18	mid	\N	2022-08-23	\N	\N	verified
262	188	lille	\N	50000	\N	\N	3	9	mid	\N	2022-08-23	\N	\N	verified
263	189	paris	\N	60000	\N	\N	\N	3	senior	\N	2022-08-23	\N	\N	verified
264	190	rennes	\N	49000	\N	\N	5	10	mid	\N	2022-08-23	\N	\N	verified
265	\N	montpellier	\N	35000	\N	\N	1	1	mid	\N	2022-08-23	\N	\N	verified
266	13	paris	\N	42000	\N	\N	3	3	mid	\N	2022-08-23	\N	\N	verified
267	\N	lille	\N	43000	\N	\N	7	10	mid	\N	2022-08-23	\N	\N	verified
268	74	paris	\N	55000	\N	\N	0	3	mid	\N	2022-08-23	\N	\N	verified
269	18	rennes	\N	34500	\N	\N	1	0	mid	\N	2022-08-23	\N	\N	verified
270	191	paris	\N	46200	\N	\N	1	1	mid	\N	2022-08-23	\N	\N	verified
271	192	montpellier	\N	37000	\N	\N	3	18	senior	\N	2022-08-23	\N	\N	verified
272	80	grand bay	\N	40000	\N	\N	0	2	mid	\N	2022-08-23	\N	\N	verified
273	30	paris	\N	42000	\N	\N	3	5	mid	remote	2022-08-23	\N	\N	verified
274	\N	grenoble	\N	33000	\N	\N	5	5	mid	\N	2022-08-23	\N	\N	verified
275	9	remote	\N	80500	\N	\N	3	14	mid	remote	2022-08-23	\N	\N	verified
276	194	nantes	\N	46000	\N	\N	4	11	mid	\N	2022-08-23	\N	\N	verified
277	195	rennes	\N	16000	\N	\N	1	3	mid	\N	2022-08-23	\N	\N	verified
278	13	paris	\N	80000	\N	\N	2	12	mid	\N	2022-08-23	\N	\N	verified
279	121	toulouse	\N	48000	\N	\N	1	7	mid	\N	2022-08-23	\N	\N	verified
280	70	toulouse	\N	52000	\N	\N	3	10	mid	\N	2022-08-23	\N	\N	verified
281	196	la garenne-colombes	\N	35000	\N	\N	0	0	mid	\N	2022-08-23	\N	\N	verified
282	197	douai	\N	37000	\N	\N	2	8	mid	\N	2022-08-23	\N	\N	verified
283	61	paris	\N	75000	\N	\N	7	16	mid	\N	2022-08-23	\N	\N	verified
284	198	alsace	\N	45000	\N	\N	9	11	mid	\N	2022-08-23	\N	\N	verified
285	199	paris	\N	190000	\N	\N	1	14	mid	\N	2022-08-23	\N	\N	verified
286	86	paris	\N	55000	\N	\N	2	2	mid	\N	2022-08-23	\N	\N	verified
287	200	remote	\N	110000	\N	\N	2	6	mid	remote	2022-08-23	\N	\N	verified
288	201	colombes	\N	73200	\N	\N	3	16	mid	\N	2022-08-23	\N	\N	verified
289	202	nantes	\N	64000	\N	\N	2	7	mid	\N	2022-08-23	\N	\N	verified
290	50	strasbourg	\N	42000	\N	\N	5	6	mid	\N	2022-08-23	\N	\N	verified
291	202	nantes	\N	64000	\N	\N	2	7	mid	\N	2022-08-23	\N	\N	verified
292	174	france	\N	63000	\N	\N	4	11	mid	\N	2022-08-23	\N	\N	verified
293	76	marseille	\N	46000	\N	\N	2	10	mid	\N	2022-08-23	\N	\N	verified
294	203	nancy	\N	27000	\N	\N	3	3	junior	\N	2022-08-23	\N	\N	verified
295	204	angers	\N	40000	\N	\N	3	6	mid	\N	2022-08-23	\N	\N	verified
296	205	valbonne	\N	42000	\N	\N	2	2	mid	\N	2022-08-23	\N	\N	verified
297	206	rouen	\N	44000	\N	\N	6	6	mid	\N	2022-08-23	\N	\N	verified
298	207	paris	\N	42000	\N	\N	1	3	mid	\N	2022-08-23	\N	\N	verified
299	30	remote	\N	133000	\N	\N	2	10	mid	remote	2022-08-23	\N	\N	verified
300	208	lille	\N	34000	\N	\N	5	10	mid	\N	2022-08-23	\N	\N	verified
301	209	nice	\N	120000	\N	\N	0	3	mid	\N	2022-08-23	\N	\N	verified
302	210	paris	\N	53000	\N	\N	3	3	mid	\N	2022-08-23	\N	\N	verified
303	211	mont-saint-aignan	\N	32500	\N	\N	\N	10	mid	\N	2022-08-23	\N	\N	verified
304	109	paris	\N	39000	\N	\N	2	2	mid	\N	2022-08-23	\N	\N	verified
305	\N	lille	\N	30000	\N	\N	2	\N	mid	\N	2022-08-23	\N	\N	verified
306	180	bordeaux	\N	56000	\N	\N	3	8	mid	\N	2022-08-23	\N	\N	verified
307	212	sophia-antipolis	\N	45100	\N	\N	1	3	mid	\N	2022-08-22	\N	\N	verified
308	18	rennes	\N	34500	\N	\N	1	0	mid	\N	2022-08-22	\N	\N	verified
309	213	luxembourg	\N	55300	\N	\N	3	3	mid	\N	2022-08-22	\N	\N	verified
310	214	bordeaux	\N	37000	\N	\N	11	11	mid	\N	2022-08-22	\N	\N	verified
311	183	rennes	\N	36000	\N	\N	10	15	mid	\N	2022-08-22	\N	\N	verified
312	215	paris	\N	47000	\N	\N	1	3	mid	\N	2022-08-22	\N	\N	verified
313	55	lyon	\N	72000	\N	\N	4	10	mid	\N	2022-08-22	\N	\N	verified
314	117	cergy	\N	80600	\N	\N	\N	\N	mid	\N	2022-08-22	\N	\N	verified
315	36	bretagne	\N	28000	\N	\N	0	1	mid	\N	2022-08-22	\N	\N	verified
316	216	saint-nazaire	\N	39000	\N	\N	1	4	mid	\N	2022-08-22	\N	\N	verified
317	217	remote	\N	105000	\N	\N	1	14	senior	remote	2022-08-22	\N	\N	verified
318	76	nantes	\N	57500	\N	\N	1	16	mid	\N	2022-08-22	\N	\N	verified
319	218	remote	\N	43000	\N	\N	4	\N	mid	remote	2022-08-22	\N	\N	verified
320	219	paris	\N	40000	\N	\N	\N	\N	mid	\N	2022-08-22	\N	\N	verified
321	220	nice	\N	96000	\N	\N	\N	6	mid	\N	2022-08-22	\N	\N	verified
322	171	grenoble	\N	38500	\N	\N	3	5	mid	\N	2022-08-22	\N	\N	verified
323	50	nancy	\N	33000	\N	\N	0	3	mid	\N	2022-08-22	\N	\N	verified
324	221	suisse	\N	200000	\N	\N	8	8	mid	\N	2022-08-22	\N	\N	verified
325	174	bidart	\N	33500	\N	\N	\N	3	senior	\N	2022-08-22	\N	\N	verified
326	158	blood	\N	50000	\N	\N	\N	\N	mid	\N	2022-08-22	\N	\N	verified
327	222	neuilly-sur-seine	\N	160000	\N	\N	1	5	senior	\N	2022-08-22	\N	\N	verified
328	223	villeneuve d'ascq	\N	31000	\N	\N	1	3	mid	\N	2022-08-22	\N	\N	verified
329	224	amiens	\N	26000	\N	\N	2	4	mid	\N	2022-08-22	\N	\N	verified
330	225	nantes	\N	42000	\N	\N	4	8	mid	\N	2022-08-22	\N	\N	verified
331	121	paris	\N	60000	\N	\N	4	5	mid	\N	2022-08-22	\N	\N	verified
332	226	remote	\N	70000	\N	\N	\N	7	mid	remote	2022-08-22	\N	\N	verified
333	\N	alsace	\N	40000	\N	\N	\N	\N	mid	\N	2022-08-22	\N	\N	verified
334	227	paris	\N	38000	\N	\N	4	\N	mid	remote	2022-08-22	\N	\N	verified
335	228	bourges	\N	67700	\N	\N	5	\N	mid	\N	2022-08-22	\N	\N	verified
336	229	strasbourg	\N	67400	\N	\N	\N	\N	mid	\N	2022-08-22	\N	\N	verified
337	230	lyon	\N	30000	\N	\N	2	3	mid	\N	2022-08-22	\N	\N	verified
338	231	nantes	\N	33000	\N	\N	0	\N	mid	\N	2022-08-22	\N	\N	verified
339	76	nantes	\N	40700	\N	\N	0	0	mid	\N	2022-08-22	\N	\N	verified
340	232	luxembourg	\N	46100	\N	\N	\N	\N	mid	\N	2022-08-22	\N	\N	verified
341	232	cergy	\N	64100	\N	\N	\N	\N	mid	\N	2022-08-22	\N	\N	verified
342	111	aix-en-provence	\N	76000	\N	\N	\N	\N	senior	\N	2022-08-22	\N	\N	verified
343	233	strasbourg	\N	72900	\N	\N	5	\N	mid	\N	2022-08-22	\N	\N	verified
344	234	paris	\N	51400	\N	\N	1	\N	mid	remote	2022-08-22	\N	\N	verified
345	233	grenoble	\N	64400	\N	\N	2	5	mid	\N	2022-08-22	\N	\N	verified
346	235	lyon	\N	60000	\N	\N	2	12	mid	\N	2022-08-22	\N	\N	verified
347	236	grenoble	\N	61000	\N	\N	\N	\N	mid	\N	2022-08-22	\N	\N	verified
348	237	lyon	\N	37000	\N	\N	1	3	mid	\N	2022-08-22	\N	\N	verified
349	238	tours	\N	40000	\N	\N	1	9	mid	\N	2022-08-22	\N	\N	verified
350	239	nantes	\N	82900	\N	\N	3	8	mid	\N	2022-08-22	\N	\N	verified
351	\N	nantes	\N	32300	\N	\N	\N	3	mid	\N	2022-08-22	\N	\N	verified
352	204	laval	\N	30000	\N	\N	4	9	mid	\N	2022-08-22	\N	\N	verified
353	240	rodez	\N	30000	\N	\N	0	0	mid	\N	2022-08-22	\N	\N	verified
354	\N	lens	\N	32000	\N	\N	7	10	mid	\N	2022-08-22	\N	\N	verified
355	241	la rochelle	\N	38000	\N	\N	3	7	mid	\N	2022-08-22	\N	\N	verified
356	163	remote	\N	92000	\N	\N	3	10	mid	remote	2022-08-22	\N	\N	verified
357	242	amiens	\N	40000	\N	\N	4	4	mid	\N	2022-08-21	\N	\N	verified
358	105	alsace	\N	40000	\N	\N	2	10	mid	\N	2022-08-21	\N	\N	verified
359	243	nantes	\N	40000	\N	\N	1	\N	mid	\N	2022-08-21	\N	\N	verified
360	37	paris	\N	50000	\N	\N	2	\N	mid	\N	2022-08-21	\N	\N	verified
361	244	toulouse	\N	40000	\N	\N	2	4	mid	\N	2022-08-21	\N	\N	verified
362	233	remote	\N	75000	\N	\N	1	20	mid	remote	2022-08-20	\N	\N	verified
363	30	nantes	\N	41200	\N	\N	2	5	mid	\N	2022-08-20	\N	\N	verified
364	245	lyon	\N	100000	\N	\N	4	9	senior	\N	2022-08-20	\N	\N	verified
365	246	paris	\N	50000	\N	\N	3	3	mid	\N	2022-08-19	\N	\N	verified
366	30	bidart	\N	60000	\N	\N	2	25	mid	\N	2022-08-19	\N	\N	verified
367	\N	remote	\N	45000	\N	\N	7	7	mid	remote	2022-08-19	\N	\N	verified
368	248	remote	\N	60000	\N	\N	2	12	mid	remote	2022-08-19	\N	\N	verified
369	9	remote	\N	80000	\N	\N	1	20	mid	remote	2022-08-19	\N	\N	verified
370	13	rennes	\N	34000	\N	\N	2	5	mid	\N	2022-08-19	\N	\N	verified
371	249	tours	\N	52500	\N	\N	10	13	mid	\N	2022-08-19	\N	\N	verified
372	250	cergy	\N	18000	\N	\N	\N	4	mid	\N	2022-08-19	\N	\N	verified
373	212	luxembourg	\N	3100	\N	\N	0	3	mid	\N	2022-08-19	\N	\N	verified
374	\N	remote	\N	36000	\N	\N	1	3	mid	remote	2022-08-19	\N	\N	verified
375	183	remote	\N	75000	\N	\N	2	11	mid	remote	2022-08-19	\N	\N	verified
376	251	toulouse	\N	36000	\N	\N	1	3	mid	\N	2022-08-18	\N	\N	verified
377	118	paris	\N	50000	\N	\N	1	5	mid	\N	2022-08-18	\N	\N	verified
378	252	alsace	\N	35000	\N	\N	\N	\N	mid	\N	2022-08-18	\N	\N	verified
379	37	bretagne	\N	68500	\N	\N	15	21	mid	\N	2022-08-18	\N	\N	verified
380	253	belgique	\N	71500	\N	\N	8	20	mid	\N	2022-08-18	\N	\N	verified
381	18	la défense	\N	42000	\N	\N	1	2	junior	\N	2022-08-18	\N	\N	verified
382	254	marseille	\N	40000	\N	\N	1	4	mid	\N	2022-08-18	\N	\N	verified
383	139	toulouse	\N	42000	\N	\N	6	9	mid	\N	2022-08-18	\N	\N	verified
384	3	remote	\N	150000	\N	\N	0	15	mid	remote	2022-08-18	\N	\N	verified
385	\N	grenoble	\N	47000	\N	\N	\N	17	mid	\N	2022-08-18	\N	\N	verified
386	255	paris	\N	43800	\N	\N	3	4	mid	\N	2022-08-18	\N	\N	verified
387	256	paris	\N	40000	\N	\N	12	20	mid	\N	2022-08-18	\N	\N	verified
388	63	dakar	\N	18000	\N	\N	5	10	mid	\N	2022-08-18	\N	\N	verified
389	50	paris	\N	55000	\N	\N	5	5	mid	\N	2022-08-18	\N	\N	verified
390	257	paris	\N	38000	\N	\N	2	2	mid	\N	2022-08-18	\N	\N	verified
391	258	paris	\N	55000	\N	\N	\N	20	senior	\N	2022-08-18	\N	\N	verified
392	30	lyon	\N	20400	\N	\N	0	1	mid	\N	2022-08-18	\N	\N	verified
393	259	bordeaux	\N	60000	\N	\N	3	20	mid	\N	2022-08-18	\N	\N	verified
394	105	paris	\N	119000	\N	\N	\N	11	mid	\N	2022-08-17	\N	\N	verified
395	260	paris	\N	47000	\N	\N	1	4	mid	\N	2022-08-17	\N	\N	verified
396	261	remote	\N	70000	\N	\N	1	9	mid	remote	2022-08-17	\N	\N	verified
397	181	paris	\N	70000	\N	\N	0	8	mid	\N	2022-08-17	\N	\N	verified
398	225	toulouse	\N	45000	\N	\N	1	7	mid	\N	2022-08-17	\N	\N	verified
399	262	remote	\N	38000	\N	\N	\N	\N	mid	remote	2022-08-17	\N	\N	verified
400	\N	nantes	\N	30000	\N	\N	5	5	mid	\N	2022-08-17	\N	\N	verified
401	41	remote	\N	51000	\N	\N	1	4	mid	remote	2022-08-17	\N	\N	verified
402	263	paris	\N	46000	\N	\N	1	2	mid	\N	2022-08-17	\N	\N	verified
403	24	paris	\N	75000	\N	\N	1	17	mid	\N	2022-08-17	\N	\N	verified
404	183	rennes	\N	30000	\N	\N	\N	\N	mid	\N	2022-08-17	\N	\N	verified
405	264	rouen	\N	46000	\N	\N	2	8	mid	\N	2022-08-17	\N	\N	verified
406	\N	roanne	\N	20000	\N	\N	3	8	mid	\N	2022-08-17	\N	\N	verified
407	265	nantes	\N	48000	\N	\N	\N	\N	mid	\N	2022-08-17	\N	\N	verified
408	15	remote	\N	61000	\N	\N	1	3	mid	remote	2022-08-17	\N	\N	verified
409	238	tours	\N	41000	\N	\N	1	9	mid	\N	2022-07-08	\N	\N	verified
410	266	paris	\N	75000	\N	\N	\N	18	mid	\N	2022-07-05	\N	\N	verified
411	267	bordeaux	\N	38000	\N	\N	6	10	mid	\N	2022-07-05	\N	\N	verified
412	268	montpellier	\N	47000	\N	\N	3	3	mid	\N	2022-07-05	\N	\N	verified
413	121	lyon	\N	48000	\N	\N	1	12	mid	\N	2022-07-05	\N	\N	verified
414	\N	remote	\N	36000	\N	\N	4	4	mid	remote	2022-07-05	\N	\N	verified
415	269	remote	\N	47000	\N	\N	0	5	mid	remote	2022-07-05	\N	\N	verified
416	50	strasbourg	\N	35500	\N	\N	\N	1	mid	\N	2022-07-05	\N	\N	verified
417	224	remote	\N	48000	\N	\N	1	14	mid	remote	2022-07-05	\N	\N	verified
418	\N	aix-en-provence	\N	32000	\N	\N	\N	0	mid	\N	2022-07-05	\N	\N	verified
419	228	strasbourg	\N	34000	\N	\N	\N	2	mid	\N	2022-07-05	\N	\N	verified
420	234	rennes	\N	34000	\N	\N	\N	5	mid	\N	2022-07-05	\N	\N	verified
421	270	paris	\N	50000	\N	\N	\N	\N	mid	\N	2022-07-05	\N	\N	verified
422	271	paris	\N	48000	\N	\N	1	1	mid	\N	2022-07-05	\N	\N	verified
423	37	lannion	\N	52000	\N	\N	5	15	mid	\N	2022-07-05	\N	\N	verified
424	173	paris	\N	60000	\N	\N	\N	9	mid	remote	2022-07-05	\N	\N	verified
425	18	lille	\N	37500	\N	\N	3	3	mid	\N	2022-07-05	\N	\N	verified
426	272	blois	\N	30000	\N	\N	6	6	mid	\N	2022-07-05	\N	\N	verified
427	273	strasbourg	\N	51600	\N	\N	3	9	mid	\N	2022-07-05	\N	\N	verified
428	274	entzheim	\N	30000	\N	\N	0	0	mid	\N	2022-07-05	\N	\N	verified
429	275	paris	\N	38000	\N	\N	1	2	junior	\N	2022-07-05	\N	\N	verified
430	276	paris	\N	46000	\N	\N	0	1	mid	\N	2022-07-05	\N	\N	verified
431	277	montpellier	\N	8500	\N	\N	2	2	mid	\N	2022-07-05	\N	\N	verified
432	111	sophia-antipolis	\N	56000	\N	\N	10	10	mid	\N	2022-07-05	\N	\N	verified
433	27	nantes	\N	58000	\N	\N	1	9	mid	\N	2022-07-05	\N	\N	verified
434	204	bretagne	\N	47000	\N	\N	3	8	mid	\N	2022-07-05	\N	\N	verified
435	161	nantes	\N	37000	\N	\N	6	6	mid	\N	2022-07-05	\N	\N	verified
436	121	toulouse	\N	39000	\N	\N	1	2	mid	\N	2022-07-05	\N	\N	verified
437	278	bourges	\N	22500	\N	\N	1	10	mid	\N	2022-07-05	\N	\N	verified
438	12	blois	\N	39000	\N	\N	10	10	mid	\N	2022-07-05	\N	\N	verified
439	277	montpellier	\N	50000	\N	\N	5	15	senior	\N	2022-07-05	\N	\N	verified
440	158	lille	\N	48000	\N	\N	7	12	mid	\N	2022-07-05	\N	\N	verified
441	279	toulouse	\N	40000	\N	\N	4	10	mid	\N	2022-07-05	\N	\N	verified
442	268	montpellier	\N	44000	\N	\N	2	2	mid	\N	2022-07-05	\N	\N	verified
443	42	paris	\N	62000	\N	\N	10	11	mid	\N	2022-07-05	\N	\N	verified
444	186	lille	\N	52500	\N	\N	3	12	mid	\N	2022-07-05	\N	\N	verified
445	281	genève	\N	87000	\N	\N	3	4	mid	\N	2022-07-05	\N	\N	verified
446	174	levallois-perret	\N	61000	\N	\N	13	15	senior	\N	2022-07-05	\N	\N	verified
447	50	toulouse	\N	38000	\N	\N	4	4	mid	\N	2022-07-05	\N	\N	verified
448	30	remote	\N	60000	\N	\N	6	6	mid	remote	2022-07-05	\N	\N	verified
449	172	lyon	\N	60000	\N	\N	7	\N	mid	\N	2022-07-05	\N	\N	verified
450	282	lyon	\N	37000	\N	\N	1	1	mid	\N	2022-07-05	\N	\N	verified
451	158	paris	\N	203000	\N	\N	9	10	senior	\N	2022-07-05	\N	\N	verified
452	9	bordeaux	\N	90000	\N	\N	5	12	mid	\N	2022-07-05	\N	\N	verified
453	158	paris	\N	52000	\N	\N	6	8	mid	\N	2022-07-05	\N	\N	verified
454	121	roubaix	\N	71000	\N	\N	10	10	mid	\N	2022-07-05	\N	\N	verified
455	283	paris	\N	41000	\N	\N	2	\N	mid	\N	2022-07-05	\N	\N	verified
456	\N	paris	\N	150000	\N	\N	4	25	mid	\N	2022-07-05	\N	\N	verified
457	284	toulouse	\N	37000	\N	\N	5	7	mid	\N	2022-07-05	\N	\N	verified
458	285	paris	\N	47500	\N	\N	1	2	mid	\N	2022-07-05	\N	\N	verified
459	196	paris	\N	89000	\N	\N	10	20	mid	\N	2022-07-05	\N	\N	verified
460	286	paris	\N	60000	\N	\N	2	10	senior	remote	2022-07-05	\N	\N	verified
461	220	toulouse	\N	23000	\N	\N	0	2	mid	\N	2022-07-05	\N	\N	verified
462	\N	remote	\N	42000	\N	\N	0	1	mid	remote	2022-07-05	\N	\N	verified
463	287	lille	\N	42000	\N	\N	5	5	mid	\N	2022-07-05	\N	\N	verified
464	183	remote	\N	75000	\N	\N	1	10	mid	remote	2022-07-05	\N	\N	verified
465	288	lyon	\N	47000	\N	\N	4	7	mid	\N	2022-07-05	\N	\N	verified
466	288	lyon	\N	47000	\N	\N	4	7	mid	\N	2022-07-05	\N	\N	verified
467	158	lille	\N	47000	\N	\N	5	7	mid	\N	2022-07-05	\N	\N	verified
468	290	paris	\N	32000	\N	\N	3	3	mid	\N	2022-07-05	\N	\N	verified
469	239	paris	\N	58000	\N	\N	1	11	mid	\N	2022-07-05	\N	\N	verified
470	291	remote	\N	55000	\N	\N	\N	\N	mid	remote	2022-07-05	\N	\N	verified
471	\N	paris	\N	31500	\N	\N	0	0	mid	\N	2022-07-05	\N	\N	verified
472	121	roubaix	\N	43000	\N	\N	7	7	mid	\N	2022-07-05	\N	\N	verified
473	50	rennes	\N	31000	\N	\N	2	5	mid	\N	2022-07-05	\N	\N	verified
474	293	paris	\N	42000	\N	\N	2	4	mid	\N	2022-07-05	\N	\N	verified
475	12	luxembourg	\N	65000	\N	\N	6	6	mid	\N	2022-07-05	\N	\N	verified
476	294	lyon	\N	70000	\N	\N	10	17	mid	\N	2022-07-05	\N	\N	verified
477	295	villeneuve d'ascq	\N	33000	\N	\N	\N	\N	mid	\N	2022-07-05	\N	\N	verified
478	100	toulouse	\N	47000	\N	\N	6	8	mid	\N	2022-07-05	\N	\N	verified
479	15	remote	\N	105000	\N	\N	4	10	senior	remote	2022-07-05	\N	\N	verified
480	296	paris	\N	58000	\N	\N	2	12	mid	\N	2022-07-05	\N	\N	verified
481	12	villeurbanne	\N	39000	\N	\N	3	3	mid	\N	2022-07-05	\N	\N	verified
482	63	toulouse	\N	40000	\N	\N	3	3	mid	\N	2022-07-05	\N	\N	verified
483	297	remote	\N	115000	\N	\N	\N	10	mid	remote	2022-07-05	\N	\N	verified
484	238	tours	\N	48000	\N	\N	\N	10	mid	\N	2022-07-05	\N	\N	verified
485	298	fos-sur-mer	\N	42000	\N	\N	0	1	mid	\N	2022-07-05	\N	\N	verified
486	299	nantes	\N	54000	\N	\N	1	8	mid	\N	2022-07-05	\N	\N	verified
487	29	nantes	\N	40000	\N	\N	2	5	mid	\N	2022-07-05	\N	\N	verified
488	50	lyon	\N	78000	\N	\N	23	40	mid	\N	2022-07-05	\N	\N	verified
489	12	seclin	\N	36000	\N	\N	2	2	mid	\N	2022-07-05	\N	\N	verified
490	41	remote	\N	58000	\N	\N	1	9	mid	remote	2022-07-05	\N	\N	verified
491	278	bourges	\N	225000	\N	\N	1	10	senior	\N	2022-07-05	\N	\N	verified
492	300	montpellier	\N	42000	\N	\N	\N	7	mid	\N	2022-07-05	\N	\N	verified
493	301	lyon	\N	44000	\N	\N	3	23	mid	\N	2022-07-05	\N	\N	verified
494	227	marseille	\N	160000	\N	\N	\N	\N	mid	\N	2022-07-05	\N	\N	verified
495	302	remote	\N	68000	\N	\N	0	5	mid	remote	2022-07-04	\N	\N	verified
496	303	nice	\N	42000	\N	\N	3	4	mid	\N	2022-07-04	\N	\N	verified
497	304	paris	\N	62000	\N	\N	2	3	mid	\N	2022-06-29	\N	\N	verified
498	124	paris	\N	70000	\N	\N	1	5	mid	\N	2022-06-28	\N	\N	verified
499	305	paris	\N	37000	\N	\N	1	1	mid	\N	2022-06-25	\N	\N	verified
500	50	lyon	\N	34000	\N	\N	3	3	mid	\N	2022-06-24	\N	\N	verified
501	302	lille	\N	50000	\N	\N	7	10	mid	\N	2022-06-22	\N	\N	verified
502	50	sophia-antipolis	\N	38000	\N	\N	5	15	mid	\N	2022-06-16	\N	\N	verified
503	306	paris	\N	51000	\N	\N	4	7	mid	\N	2022-06-16	\N	\N	verified
504	307	nancy	\N	40000	\N	\N	2	8	mid	\N	2022-06-05	\N	\N	verified
505	242	paris	\N	70000	\N	\N	0	0	mid	\N	2022-06-04	\N	\N	verified
506	109	nice	\N	35000	\N	\N	0	0	mid	\N	2022-06-03	\N	\N	verified
507	308	paris	\N	98000	\N	\N	3	6	mid	\N	2022-06-03	\N	\N	verified
508	243	nantes	\N	47000	\N	\N	0	13	mid	\N	2022-06-02	\N	\N	verified
509	111	nice	\N	55000	\N	\N	8	8	mid	\N	2022-05-31	\N	\N	verified
510	302	paris	\N	62000	\N	\N	0	0	mid	\N	2022-05-31	\N	\N	verified
511	309	lyon	\N	38000	\N	\N	0	2	mid	\N	2022-05-31	\N	\N	verified
512	310	paris	\N	54000	\N	\N	0	3	mid	\N	2022-05-24	\N	\N	verified
513	122	grenoble	\N	50000	\N	\N	2	8	mid	\N	2022-05-23	\N	\N	verified
514	242	paris	\N	86000	\N	\N	0	2	mid	\N	2022-05-22	\N	\N	verified
515	117	paris	\N	170000	\N	\N	4	15	mid	\N	2022-05-22	\N	\N	verified
516	63	paris	\N	36000	\N	\N	5	6	mid	\N	2022-05-17	\N	\N	verified
517	311	paris	\N	67000	\N	\N	3	6	mid	\N	2022-05-17	\N	\N	verified
518	312	paris	\N	42000	\N	\N	2	5	junior	\N	2022-05-16	\N	\N	verified
519	313	paris	\N	57000	\N	\N	1	4	mid	\N	2022-05-15	\N	\N	verified
520	314	paris	\N	85000	\N	\N	15	25	mid	\N	2022-05-10	\N	\N	verified
521	117	remote	\N	100000	\N	\N	0	19	mid	remote	2022-05-09	\N	\N	verified
522	315	paris	\N	50000	\N	\N	1	1	mid	\N	2022-05-08	\N	\N	verified
523	313	lyon	\N	42000	\N	\N	2	7	mid	\N	2022-05-08	\N	\N	verified
524	78	paris	\N	44400	\N	\N	2	2	mid	\N	2022-05-07	\N	\N	verified
525	316	remote	\N	95000	\N	\N	1	5	mid	remote	2022-05-07	\N	\N	verified
526	308	paris	\N	125000	\N	\N	1	7	mid	\N	2022-05-06	\N	\N	verified
527	18	toulouse	\N	36500	\N	\N	1	1	mid	\N	2022-05-01	\N	\N	verified
528	229	paris	\N	48000	\N	\N	1	1	mid	\N	2022-05-01	\N	\N	verified
529	317	remote	\N	57800	\N	\N	1	5	mid	remote	2022-04-29	\N	\N	verified
530	173	paris	\N	58000	\N	\N	1	1	mid	\N	2022-04-28	\N	\N	verified
531	139	lille	\N	36000	\N	\N	5	6	mid	\N	2022-04-21	\N	\N	verified
532	117	paris	\N	130000	\N	\N	4	8	mid	\N	2022-04-20	\N	\N	verified
533	163	remote	\N	71000	\N	\N	1	10	mid	remote	2022-04-17	\N	\N	verified
534	156	paris	\N	88200	\N	\N	5	7	mid	\N	2022-04-17	\N	\N	verified
535	163	paris	\N	73000	\N	\N	3	3	mid	\N	2022-04-17	\N	\N	verified
536	111	nice	\N	61000	\N	\N	11	13	mid	\N	2022-04-13	\N	\N	verified
537	318	paris	\N	50000	\N	\N	1	1	mid	\N	2022-04-13	\N	\N	verified
538	308	paris	\N	80000	\N	\N	1	2	mid	\N	2022-04-12	\N	\N	verified
539	319	paris	\N	120000	\N	\N	1	4	mid	\N	2022-04-12	\N	\N	verified
540	9	remote	\N	66000	\N	\N	1	12	mid	remote	2022-04-08	\N	\N	verified
541	308	paris	\N	112000	\N	\N	3	6	mid	\N	2022-04-06	\N	\N	verified
542	308	paris	\N	130000	\N	\N	4	8	mid	\N	2022-04-05	\N	\N	verified
543	229	paris	\N	71000	\N	\N	2	2	mid	\N	2022-04-03	\N	\N	verified
544	117	remote	\N	130000	\N	\N	0	17	mid	remote	2022-03-31	\N	\N	verified
545	320	remote	\N	95000	\N	\N	2	14	mid	remote	2022-03-29	\N	\N	verified
546	111	nice	\N	57000	\N	\N	6	10	mid	\N	2022-03-28	\N	\N	verified
547	320	remote	\N	95000	\N	\N	2	12	mid	remote	2022-03-24	\N	\N	verified
548	156	remote	\N	54500	\N	\N	1	4	junior	remote	2022-03-22	\N	\N	verified
549	163	paris	\N	68000	\N	\N	3	8	mid	\N	2022-03-21	\N	\N	verified
550	26	paris	\N	68000	\N	\N	0	5	senior	\N	2022-03-18	\N	\N	verified
551	163	remote	\N	78600	\N	\N	1	7	mid	remote	2022-03-15	\N	\N	verified
552	50	paris	\N	50000	\N	\N	2	2	mid	\N	2022-03-14	\N	\N	verified
553	156	paris	\N	66000	\N	\N	5	7	mid	\N	2022-03-12	\N	\N	verified
554	302	paris	\N	95000	\N	\N	1	5	mid	\N	2022-03-11	\N	\N	verified
555	163	remote	\N	100800	\N	\N	1	10	senior	remote	2022-03-07	\N	\N	verified
556	296	paris	\N	44000	\N	\N	0	0	junior	\N	2022-03-02	\N	\N	verified
557	229	paris	\N	64300	\N	\N	3	4	mid	\N	2022-03-02	\N	\N	verified
558	111	nice	\N	44000	\N	\N	5	5	mid	\N	2022-03-01	\N	\N	verified
559	163	remote	\N	75000	\N	\N	0	2	mid	remote	2022-02-28	\N	\N	verified
560	229	paris	\N	90000	\N	\N	2	18	mid	\N	2022-02-26	\N	\N	verified
561	321	paris	\N	74400	\N	\N	3	7	mid	\N	2022-02-09	\N	\N	verified
562	322	paris	\N	22700	\N	\N	0	2	junior	\N	2022-02-06	\N	\N	verified
563	323	paris	\N	106000	\N	\N	4	13	mid	\N	2022-02-02	\N	\N	verified
564	296	paris	\N	62000	\N	\N	2	12	mid	\N	2022-02-01	\N	\N	verified
565	324	paris	\N	81100	\N	\N	1	5	senior	\N	2022-01-31	\N	\N	verified
566	325	paris	\N	15200	\N	\N	0	0	mid	\N	2022-01-29	\N	\N	verified
567	326	paris	\N	112000	\N	\N	2	6	mid	\N	2022-01-27	\N	\N	verified
568	327	nantes	\N	62100	\N	\N	4	12	mid	\N	2022-01-23	\N	\N	verified
569	229	paris	\N	93000	\N	\N	2	9	mid	\N	2022-01-23	\N	\N	verified
570	111	nice	\N	44500	\N	\N	1	1	mid	\N	2022-01-14	\N	\N	verified
571	328	paris	\N	60000	\N	\N	0	10	mid	\N	2022-01-10	\N	\N	verified
572	229	paris	\N	74000	\N	\N	0	6	mid	\N	2022-01-10	\N	\N	verified
573	242	paris	\N	128000	\N	\N	1	5	mid	\N	2022-01-05	\N	\N	verified
574	15	remote	\N	55000	\N	\N	1	3	mid	remote	2022-01-01	\N	\N	verified
575	78	paris	\N	46100	\N	\N	1	2	mid	\N	2021-12-30	\N	\N	verified
576	111	sophia-antipolis	\N	46000	\N	\N	6	6	mid	\N	2021-12-24	\N	\N	verified
577	78	paris	\N	43000	\N	\N	3	3	mid	\N	2021-12-23	\N	\N	verified
578	156	paris	\N	65500	\N	\N	3	6	mid	\N	2021-12-21	\N	\N	verified
579	100	aix-en-provence	\N	36000	\N	\N	3	3	mid	\N	2021-12-14	\N	\N	verified
580	232	paris	\N	133000	\N	\N	0	10	mid	\N	2021-12-06	\N	\N	verified
581	242	paris	\N	68800	\N	\N	0	2	mid	\N	2021-12-03	\N	\N	verified
582	26	remote	\N	65000	\N	\N	1	6	mid	remote	2021-12-01	\N	\N	verified
583	163	paris	\N	102000	\N	\N	2	9	senior	\N	2021-11-26	\N	\N	verified
584	329	paris	\N	36000	\N	\N	2	2	mid	\N	2021-11-09	\N	\N	verified
585	111	nice	\N	13000	\N	\N	0	0	junior	\N	2021-11-07	\N	\N	verified
586	172	paris	\N	85000	\N	\N	0	8	mid	\N	2021-11-05	\N	\N	verified
587	169	paris	\N	65400	\N	\N	0	5	mid	\N	2021-11-03	\N	\N	verified
588	26	paris	\N	56000	\N	\N	1	5	senior	\N	2021-10-29	\N	\N	verified
589	330	paris	\N	64000	\N	\N	4	4	mid	\N	2021-10-27	\N	\N	verified
590	229	paris	\N	52000	\N	\N	1	3	mid	\N	2021-10-27	\N	\N	verified
591	308	remote	\N	97600	\N	\N	5	5	mid	remote	2021-10-26	\N	\N	verified
592	308	paris	\N	96000	\N	\N	3	10	mid	\N	2021-10-20	\N	\N	verified
593	331	paris	\N	54200	\N	\N	2	3	mid	\N	2021-10-11	\N	\N	verified
594	65	paris	\N	45000	\N	\N	1	2	junior	\N	2021-10-11	\N	\N	verified
595	121	lille	\N	44700	\N	\N	3	3	mid	\N	2021-09-22	\N	\N	verified
596	121	lille	\N	61000	\N	\N	4	11	mid	\N	2021-09-22	\N	\N	verified
597	302	paris	\N	57000	\N	\N	0	0	mid	\N	2021-09-19	\N	\N	verified
598	121	lyon	\N	63200	\N	\N	4	8	mid	\N	2021-09-15	\N	\N	verified
599	302	paris	\N	65000	\N	\N	1	10	mid	\N	2021-08-31	\N	\N	verified
600	163	paris	\N	85600	\N	\N	0	7	mid	\N	2021-08-26	\N	\N	verified
601	163	paris	\N	58700	\N	\N	0	0	mid	\N	2021-08-20	\N	\N	verified
602	296	paris	\N	36000	\N	\N	0	1	junior	\N	2021-08-18	\N	\N	verified
603	242	paris	\N	70000	\N	\N	0	5	mid	\N	2021-08-10	\N	\N	verified
604	63	paris	\N	51000	\N	\N	1	3	mid	\N	2021-08-08	\N	\N	verified
605	163	paris	\N	66000	\N	\N	1	6	mid	\N	2021-08-01	\N	\N	verified
606	163	paris	\N	66000	\N	\N	0	2	mid	\N	2021-08-01	\N	\N	verified
607	332	valbonne	\N	55200	\N	\N	2	10	mid	\N	2021-07-17	\N	\N	verified
608	15	remote	\N	48000	\N	\N	0	2	junior	remote	2021-07-01	\N	\N	verified
609	314	nice	\N	48000	\N	\N	2	2	mid	\N	2021-05-23	\N	\N	verified
610	163	remote	\N	103000	\N	\N	2	12	senior	remote	2021-05-21	\N	\N	verified
611	163	paris	\N	76100	\N	\N	0	5	mid	\N	2021-05-17	\N	\N	verified
612	169	issy-les-moulineaux	\N	80200	\N	\N	4	12	mid	\N	2021-05-11	\N	\N	verified
613	163	remote	\N	67700	\N	\N	1	3	mid	remote	2021-04-26	\N	\N	verified
614	333	paris	\N	56100	\N	\N	1	3	mid	\N	2021-04-25	\N	\N	verified
615	120	remote	\N	101000	\N	\N	2	12	senior	remote	2021-04-15	\N	\N	verified
616	156	remote	\N	63400	\N	\N	4	4	mid	remote	2021-04-12	\N	\N	verified
617	334	paris	\N	54400	\N	\N	1	4	mid	\N	2021-04-12	\N	\N	verified
618	163	paris	\N	97000	\N	\N	1	8	senior	\N	2021-04-09	\N	\N	verified
619	229	paris	\N	84000	\N	\N	3	8	mid	\N	2021-04-08	\N	\N	verified
620	335	remote	\N	157000	\N	\N	0	10	mid	remote	2021-04-06	\N	\N	verified
621	336	paris	\N	56000	\N	\N	0	1	mid	\N	2021-04-01	\N	\N	verified
622	296	paris	\N	37000	\N	\N	0	0	junior	\N	2021-03-28	\N	\N	verified
623	271	remote	\N	53400	\N	\N	1	3	mid	remote	2021-03-12	\N	\N	verified
624	100	rennes	\N	53500	\N	\N	0	7	mid	\N	2021-03-05	\N	\N	verified
625	308	paris	\N	114000	\N	\N	11	14	mid	\N	2021-02-26	\N	\N	verified
626	337	remote	\N	124000	\N	\N	5	10	mid	remote	2021-02-18	\N	\N	verified
627	242	paris	\N	107000	\N	\N	4	5	mid	\N	2021-02-11	\N	\N	verified
628	15	remote	\N	43000	\N	\N	0	2	junior	remote	2021-02-08	\N	\N	verified
629	302	paris	\N	71500	\N	\N	4	7	mid	\N	2021-01-04	\N	\N	verified
630	302	paris	\N	64000	\N	\N	2	8	mid	\N	2020-12-31	\N	\N	verified
631	311	paris	\N	65000	\N	\N	2	4	mid	\N	2020-12-23	\N	\N	verified
632	111	sophia-antipolis	\N	63500	\N	\N	6	13	mid	\N	2020-10-27	\N	\N	verified
633	331	paris	\N	67400	\N	\N	3	7	mid	\N	2020-10-23	\N	\N	verified
634	229	paris	\N	49000	\N	\N	1	2	mid	\N	2020-10-06	\N	\N	verified
635	229	paris	\N	111000	\N	\N	6	10	mid	\N	2020-09-22	\N	\N	verified
636	314	paris	\N	61000	\N	\N	8	9	mid	\N	2020-09-03	\N	\N	verified
637	314	paris	\N	105200	\N	\N	10	22	senior	\N	2020-08-26	\N	\N	verified
638	308	remote	\N	75800	\N	\N	0	3	mid	remote	2020-08-13	\N	\N	verified
639	229	paris	\N	69000	\N	\N	4	5	mid	\N	2020-06-26	\N	\N	verified
640	338	remote	\N	58000	\N	\N	0	7	mid	remote	2024-10-14	\N	\N	verified
641	339	toulouse	\N	40000	\N	\N	0	1	junior	hybrid	2024-10-13	\N	\N	verified
642	303	nantes	\N	38000	\N	\N	1	4	junior	remote	2024-10-18	\N	\N	verified
643	172	nantes	\N	53500	\N	\N	3	5	mid	hybrid	2024-10-18	\N	\N	verified
644	104	nantes	\N	45000	\N	\N	5	5	mid	hybrid	2024-10-25	\N	\N	verified
645	340	paris	\N	52000	\N	\N	2	2	junior	hybrid	2024-10-22	\N	\N	verified
646	341	nantes	\N	50440	\N	\N	2	6	mid	remote	2024-10-21	\N	\N	verified
647	342	nantes	\N	42000	\N	\N	1	3	mid	remote	2024-10-29	\N	\N	verified
648	344	nantes	\N	38000	\N	male	0	3	mid	hybrid	2024-11-04	\N	\N	no
649	345	paris	\N	70000	\N	male	6	14	senior	hybrid	2024-11-04	\N	\N	no
651	24	nantes	\N	58000	\N	\N	7	16	senior	hybrid	2024-11-05	\N	\N	verified
652	265	ile-de-france	\N	41000	\N	\N	1	1	junior	hybrid	2024-11-04	\N	\N	verified
654	\N	dijon	\N	30000	\N	\N	3	4	junior	remote	2024-11-04	\N	\N	verified
655	282	toulouse	\N	48000	\N	\N	1	10	senior	hybrid	2024-11-04	\N	\N	verified
656	346	nantes	\N	40700	\N	\N	4	4	mid	hybrid	2024-11-03	\N	\N	verified
657	42	nantes	\N	57000	\N	\N	11	19	senior	hybrid	2024-10-31	\N	\N	verified
\.


--
-- Data for Name: salary_job; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."salary_job" ("salary_id", "job_id") FROM stdin;
2	2
3	105
4	4
5	5
6	1
7	6
8	7
9	19
10	9
11	1
12	4
13	19
14	6
15	1
16	105
17	1
18	1
19	15
20	4
21	6
22	1
23	1
24	6
25	6
26	19
27	20
28	55
29	47
30	23
31	1
32	6
33	47
34	4
35	25
36	1
37	6
38	27
39	6
40	29
42	1
41	4
43	47
45	1
44	47
47	1
48	6
49	19
50	32
51	1
52	32
54	1
55	47
56	4
57	5
58	19
60	39
61	6
62	105
63	19
64	1
66	32
67	32
68	32
69	42
72	42
71	6
73	47
74	19
75	45
76	15
77	15
79	46
81	32
82	47
80	47
83	1
85	5
86	80
87	15
88	19
89	52
92	15
94	1
90	53
91	5
93	5
95	54
96	15
98	6
99	55
102	4
103	1
104	1
105	6
106	80
108	58
110	1
111	47
112	60
113	1
114	4
115	105
116	20
117	20
118	32
119	80
120	47
121	5
122	63
123	1
124	1
125	105
126	1
127	66
128	67
130	4
129	55
131	1
132	1
133	6
134	1
135	4
137	5
138	54
139	1
140	15
141	19
142	29
143	1
144	6
145	5
146	73
149	1
148	74
150	1
151	105
152	1
153	32
154	6
155	4
156	29
157	1
158	19
159	105
160	75
162	1
161	32
163	4
164	19
165	1
166	6
167	1
168	19
169	54
172	1
170	78
173	79
174	45
175	29
176	80
177	45
178	105
179	1
180	55
182	105
181	81
183	105
184	47
185	1
186	58
187	32
188	55
189	1
190	105
191	1
192	55
194	1
195	1
197	85
199	6
200	1
202	80
203	1
204	105
205	102
206	1
207	4
208	80
209	15
210	6
211	15
212	6
214	6
213	1
215	1
218	6
219	6
220	6
216	91
221	54
222	93
224	6
226	55
228	6
227	1
229	6
230	1
231	6
232	6
233	1
235	6
234	19
236	95
238	1
237	1
239	6
240	97
408	1
574	1
608	1
628	1
641	102
59	103
100	103
59	102
100	102
201	67
201	105
109	106
109	105
193	106
193	47
84	80
84	42
136	42
198	5
198	32
642	80
643	1
644	111
645	2
646	6
647	1
648	1
648	6
649	42
651	39
652	1
654	6
655	6
656	32
657	4
\.


--
-- Data for Name: salary_technical_stack; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."salary_technical_stack" ("salary_id", "technical_stack_id") FROM stdin;
210	6
229	6
3	7
9	7
9	8
13	7
13	8
164	7
234	8
164	8
234	7
44	9
168	7
51	10
54	1
132	1
206	1
47	1
47	11
139	12
191	12
233	12
203	13
203	10
237	13
237	10
124	1
126	1
185	7
200	7
104	2
149	2
238	2
187	12
187	14
648	18
648	19
652	13
652	10
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."tags" ("id", "name") FROM stdin;
0	fintech
1	healthtech
2	adtech
3	proptech
4	martech
5	consulting
6	cloud services
7	banking
8	insurance
9	real estate
10	retail
11	telecom
12	technology
13	media
14	education
15	healthcare
16	finance
17	government
18	non-profit
19	mediatech
20	agritech
21	edtech
22	cybersecurity
23	saas
24	biotech
25	communication
26	web
27	aerospace
28	defense
29	travel
30	manufacturing
31	steel
32	mining
33	marketplace
34	advertising
35	ecommerce
36	social media management
37	marketing
38	automotive
39	digital transformation
40	engineering
41	search engine
42	intellectual property management
43	legaltech
44	consumer electronics
45	software
46	hardware
47	artificial intelligence
48	machine learning
49	agile coaching
50	energy
51	optimization
52	analytics
53	data science
54	hrtech
55	talent acquisition
56	psychometrics
57	human resources
58	innovation
59	technology consulting
60	public sector
61	open-source
62	publishing
63	wordpress
64	investment management
65	sustainability
66	refurbished electronics
67	video streaming
68	entertainment
69	medtech
70	medical devices
71	wearable technology
72	diagnostics
73	carpooling
74	shared mobility
75	sustainable finance
76	cleantech
77	greentech
78	digital signage
79	luxury
80	fashion
81	beauty
82	fragrance
83	haute couture
84	accessories
85	cosmetics
86	leather goods
87	maas
88	smart city
89	managed it services
90	mobility
91	research
92	higher education
93	university
94	wine investment
95	asset management
96	password management
97	digital identity protection
98	monitoring
99	performance management
100	big data
101	sports equipment
102	athletic apparel
103	music streaming
104	audio content
105	podcast
106	climate risk management
107	catastrophe risk modeling
108	sound engineering
109	high-fidelity audio
110	enterprise resource planning (erp)
111	appointment scheduling
112	telemedicine
113	electricity
114	nuclear power
115	renewable energy
116	climatetech
117	insurtech
119	corporate training
120	talent development]
121	agriculture
122	pharmaceuticals
123	food & beverage
124	oil and gas
125	petrochemicals
126	data integration
127	interoperability
128	gaming
129	social media
130	virtual reality
131	augmented reality
132	jobs
133	foodtech
134	blockchain
135	android
136	mobile application development
137	enterprise mobility
138	email
139	smart home devices
140	autonomous vehicles
141	digital advertising
142	internet services
143	workplace productivity tools
144	operating systems
145	logistics
146	heating solutions
147	ventilation
148	air conditioning
149	climate control
150	hvac
151	construction
152	power tools
153	fastening systems
154	professional services
155	storage solutions
156	networking
157	high-performance computing
158	edge computing
159	it consulting
160	servers
161	5g
162	document management
163	contract analytics
164	identity verification
165	regulatory technology
166	video identification
167	electronic signature
168	compliance
169	accounting
170	robotics
171	tax preparation
172	financial planning
173	small business solutions
174	iot
175	content creation
176	digital media
177	influencer marketing
178	musictech
179	annotation
180	data labeling
181	multimedia
182	talent development
183	collaboration tools
184	circular economy
185	waste management
186	packaging solutions
187	digital services
188	postal services
189	fashiontech
190	e-commerce
191	cryptocurrency
192	home improvement
193	diy
194	point of sale
195	hospitality
196	golf management software
197	softwre
198	mobile
199	digital marketing
200	application development
201	storytelling
202	children's entertainment
203	educational toys
204	interactive learning
205	payment processing
206	digital wallet
207	peer-to-peer payments
208	freelance
209	discord
210	chatbot
211	moderation
212	automation
213	community engagement
214	media intelligence
215	productivity tools
216	developer tools
217	business intelligence
218	mixed reality
219	quantum computing
220	military
221	payment solutions
222	risk management
223	treasury
224	trading systems
225	capital markets
226	music
227	service industry
228	personal assistant
229	errand services
230	urban planning
231	regional development
232	electric vehicles
233	sustainable transport
234	public transportation
235	food products
236	gourmet foods
237	animal nutrition
238	feed management
239	lending
240	sme financing
241	crowdlending
242	investment platform
243	peer-to-peer lending
244	alternative finance
245	business loans
246	customer experience
247	contact center
248	crm
249	inventory management
250	access management
251	management services
252	database management
253	broadband
254	hosting
255	data centers
256	supply chain management
257	freight forwarding
258	local seo
259	online presence management
260	culture
261	youth engagement
262	marketplace]
263	payroll
264	traveltech
265	lighting
266	project management
267	product lifecycle management
268	innovation management
269	portfolio management
270	resource management
271	gambling
272	betting
273	horse racing
274	sports betting
275	privacy
276	data protection
277	european
278	rail transportation
279	ticketing
280	tourism
281	compiler technology
282	mainframe modernization
283	legacy systems
284	transportation
285	infrastructure
286	environment
287	economic development
288	customer relationship management
289	sales
290	customer service
291	platform as a service (paas)
292	customer relationship management (crm)
293	marketing automation
294	sms marketing
295	invoicing
296	sales management
297	room booking
298	video conferencing solutions
299	smart office
300	marketing technology
301	user-generated content (ugc)
302	consumer services
303	repair services
304	simulation
305	training systems
306	genomics
307	precision medicine
308	financial services
309	voice-enabled services
310	lims
311	laboratory
312	expense management
313	quantitative research
314	trading
315	hedge fund
316	sport
317	payment systems
318	digital currency
319	cross-border transactions
320	network security
321	critical infrastructure protection
322	digital payments
323	online payments
324	payment gateway
325	business infrastructure
326	security solutions
327	space
328	reviews
329	b2b
331	ecommerce]
332	social networking
333	application software
334	building automation
335	energy management
336	film production
337	data center
338	winetech
339	career development
340	transaction processing
341	knowledge management
342	enterprise solutions
343	training
344	software development
345	management consulting
346	investment capital
347	telecommunications
348	tech
349	ai
\.


--
-- Data for Name: technical_stacks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY "public"."technical_stacks" ("id", "name") FROM stdin;
1	java
2	python
3	sql
4	snowflake
5	docker
6	ruby
7	php
8	symfony
9	go
10	c++
11	angular
12	android
13	c
14	flutter
16	fastapi
17	airflow
18	reactjs
19	typescript
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY "realtime"."messages" ("id", "topic", "extension", "inserted_at", "updated_at", "payload", "event", "private", "uuid") FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY "realtime"."schema_migrations" ("version", "inserted_at") FROM stdin;
20211116024918	2024-11-04 19:54:22
20211116045059	2024-11-04 19:54:22
20211116050929	2024-11-04 19:54:22
20211116051442	2024-11-04 19:54:22
20211116212300	2024-11-04 19:54:22
20211116213355	2024-11-04 19:54:22
20211116213934	2024-11-04 19:54:22
20211116214523	2024-11-04 19:54:22
20211122062447	2024-11-04 19:54:22
20211124070109	2024-11-04 19:54:23
20211202204204	2024-11-04 19:54:23
20211202204605	2024-11-04 19:54:23
20211210212804	2024-11-04 19:54:23
20211228014915	2024-11-04 19:54:23
20220107221237	2024-11-04 19:54:23
20220228202821	2024-11-04 19:54:23
20220312004840	2024-11-04 19:54:24
20220603231003	2024-11-04 19:54:24
20220603232444	2024-11-04 19:54:24
20220615214548	2024-11-04 19:54:24
20220712093339	2024-11-04 19:54:24
20220908172859	2024-11-04 19:54:24
20220916233421	2024-11-04 19:54:24
20230119133233	2024-11-04 19:54:24
20230128025114	2024-11-04 19:54:25
20230128025212	2024-11-04 19:54:25
20230227211149	2024-11-04 19:54:25
20230228184745	2024-11-04 19:54:25
20230308225145	2024-11-04 19:54:25
20230328144023	2024-11-04 19:54:25
20231018144023	2024-11-04 19:54:25
20231204144023	2024-11-04 19:54:25
20231204144024	2024-11-04 19:54:25
20231204144025	2024-11-04 19:54:26
20240108234812	2024-11-04 19:54:26
20240109165339	2024-11-04 19:54:26
20240227174441	2024-11-04 19:54:26
20240311171622	2024-11-04 19:54:26
20240321100241	2024-11-04 19:54:26
20240401105812	2024-11-04 19:54:27
20240418121054	2024-11-04 19:54:27
20240523004032	2024-11-04 19:54:27
20240618124746	2024-11-04 19:54:27
20240801235015	2024-11-04 19:54:27
20240805133720	2024-11-04 19:54:28
20240827160934	2024-11-04 19:54:28
20240919163303	2024-11-04 19:54:28
20240919163305	2024-11-04 19:54:28
20241019105805	2024-11-04 19:54:28
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY "realtime"."subscription" ("id", "subscription_id", "entity", "filters", "claims", "created_at") FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY "storage"."buckets" ("id", "name", "owner", "created_at", "updated_at", "public", "avif_autodetection", "file_size_limit", "allowed_mime_types", "owner_id") FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY "storage"."migrations" ("id", "name", "hash", "executed_at") FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2024-11-04 19:53:24.843432
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2024-11-04 19:53:24.916726
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2024-11-04 19:53:24.975487
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2024-11-04 19:53:25.060709
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2024-11-04 19:53:25.140821
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2024-11-04 19:53:25.203353
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2024-11-04 19:53:25.263668
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2024-11-04 19:53:25.324074
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2024-11-04 19:53:25.383644
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2024-11-04 19:53:25.443448
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2024-11-04 19:53:25.503904
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2024-11-04 19:53:25.563337
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2024-11-04 19:53:25.623445
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2024-11-04 19:53:25.684061
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2024-11-04 19:53:25.74376
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2024-11-04 19:53:25.823998
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2024-11-04 19:53:25.883404
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2024-11-04 19:53:25.943406
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2024-11-04 19:53:26.003616
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2024-11-04 19:53:26.063385
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2024-11-04 19:53:26.123379
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2024-11-04 19:53:26.187496
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2024-11-04 19:53:26.272194
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2024-11-04 19:53:26.352527
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2024-11-04 19:53:26.411483
25	custom-metadata	67eb93b7e8d401cafcdc97f9ac779e71a79bfe03	2024-11-04 19:53:26.471361
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY "storage"."objects" ("id", "bucket_id", "name", "owner", "created_at", "updated_at", "last_accessed_at", "metadata", "version", "owner_id", "user_metadata") FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY "storage"."s3_multipart_uploads" ("id", "in_progress_size", "upload_signature", "bucket_id", "key", "version", "owner_id", "created_at", "user_metadata") FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY "storage"."s3_multipart_uploads_parts" ("id", "upload_id", "size", "part_number", "bucket_id", "key", "etag", "owner_id", "version", "created_at") FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: supabase_migrations; Owner: -
--

COPY "supabase_migrations"."schema_migrations" ("version", "statements", "name") FROM stdin;
\.


--
-- Data for Name: seed_files; Type: TABLE DATA; Schema: supabase_migrations; Owner: -
--

COPY "supabase_migrations"."seed_files" ("path", "hash") FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: -
--

COPY "vault"."secrets" ("id", "name", "description", "secret", "key_id", "nonce", "created_at", "updated_at") FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('"auth"."refresh_tokens_id_seq"', 1, false);


--
-- Name: key_key_id_seq; Type: SEQUENCE SET; Schema: pgsodium; Owner: -
--

SELECT pg_catalog.setval('"pgsodium"."key_key_id_seq"', 1, false);


--
-- Name: companies_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('"public"."companies_id_seq"', 346, true);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('"public"."jobs_id_seq"', 111, true);


--
-- Name: salaries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('"public"."salaries_id_seq"', 657, true);


--
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('"public"."tags_id_seq"', 349, true);


--
-- Name: technical_stacks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('"public"."technical_stacks_id_seq"', 19, true);


--
-- Name: messages_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('"realtime"."messages_id_seq"', 1, false);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('"realtime"."subscription_id_seq"', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "amr_id_pk" PRIMARY KEY ("id");


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."audit_log_entries"
    ADD CONSTRAINT "audit_log_entries_pkey" PRIMARY KEY ("id");


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."flow_state"
    ADD CONSTRAINT "flow_state_pkey" PRIMARY KEY ("id");


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_pkey" PRIMARY KEY ("id");


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_provider_id_provider_unique" UNIQUE ("provider_id", "provider");


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."instances"
    ADD CONSTRAINT "instances_pkey" PRIMARY KEY ("id");


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "mfa_amr_claims_session_id_authentication_method_pkey" UNIQUE ("session_id", "authentication_method");


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_challenges"
    ADD CONSTRAINT "mfa_challenges_pkey" PRIMARY KEY ("id");


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_last_challenged_at_key" UNIQUE ("last_challenged_at");


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_pkey" PRIMARY KEY ("id");


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."one_time_tokens"
    ADD CONSTRAINT "one_time_tokens_pkey" PRIMARY KEY ("id");


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_pkey" PRIMARY KEY ("id");


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_token_unique" UNIQUE ("token");


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_entity_id_key" UNIQUE ("entity_id");


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_pkey" PRIMARY KEY ("id");


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_pkey" PRIMARY KEY ("id");


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."sessions"
    ADD CONSTRAINT "sessions_pkey" PRIMARY KEY ("id");


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."sso_domains"
    ADD CONSTRAINT "sso_domains_pkey" PRIMARY KEY ("id");


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."sso_providers"
    ADD CONSTRAINT "sso_providers_pkey" PRIMARY KEY ("id");


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."users"
    ADD CONSTRAINT "users_phone_key" UNIQUE ("phone");


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."users"
    ADD CONSTRAINT "users_pkey" PRIMARY KEY ("id");


--
-- Name: companies companies_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "companies_name_key" UNIQUE ("name");


--
-- Name: alembic_version idx_16389_sqlite_autoindex_alembic_version_1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."alembic_version"
    ADD CONSTRAINT "idx_16389_sqlite_autoindex_alembic_version_1" PRIMARY KEY ("version_num");


--
-- Name: jobs idx_16394_ix_jobs_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "idx_16394_ix_jobs_id" PRIMARY KEY ("id");


--
-- Name: technical_stacks idx_16399_ix_technical_stacks_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."technical_stacks"
    ADD CONSTRAINT "idx_16399_ix_technical_stacks_id" PRIMARY KEY ("id");


--
-- Name: salaries idx_16404_ix_salaries_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."salaries"
    ADD CONSTRAINT "idx_16404_ix_salaries_id" PRIMARY KEY ("id");


--
-- Name: tags idx_16415_ix_tags_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."tags"
    ADD CONSTRAINT "idx_16415_ix_tags_id" PRIMARY KEY ("id");


--
-- Name: companies idx_16423_ix_companies_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."companies"
    ADD CONSTRAINT "idx_16423_ix_companies_id" PRIMARY KEY ("id");


--
-- Name: jobs jobs_title_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."jobs"
    ADD CONSTRAINT "jobs_title_key" UNIQUE ("title");


--
-- Name: tags tags_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."tags"
    ADD CONSTRAINT "tags_name_key" UNIQUE ("name");


--
-- Name: technical_stacks technical_stacks_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."technical_stacks"
    ADD CONSTRAINT "technical_stacks_name_key" UNIQUE ("name");


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY "realtime"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY "realtime"."subscription"
    ADD CONSTRAINT "pk_subscription" PRIMARY KEY ("id");


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY "realtime"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."buckets"
    ADD CONSTRAINT "buckets_pkey" PRIMARY KEY ("id");


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."migrations"
    ADD CONSTRAINT "migrations_name_key" UNIQUE ("name");


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."migrations"
    ADD CONSTRAINT "migrations_pkey" PRIMARY KEY ("id");


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."objects"
    ADD CONSTRAINT "objects_pkey" PRIMARY KEY ("id");


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_pkey" PRIMARY KEY ("id");


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads"
    ADD CONSTRAINT "s3_multipart_uploads_pkey" PRIMARY KEY ("id");


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY "supabase_migrations"."schema_migrations"
    ADD CONSTRAINT "schema_migrations_pkey" PRIMARY KEY ("version");


--
-- Name: seed_files seed_files_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY "supabase_migrations"."seed_files"
    ADD CONSTRAINT "seed_files_pkey" PRIMARY KEY ("path");


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "audit_logs_instance_id_idx" ON "auth"."audit_log_entries" USING "btree" ("instance_id");


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "confirmation_token_idx" ON "auth"."users" USING "btree" ("confirmation_token") WHERE (("confirmation_token")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "email_change_token_current_idx" ON "auth"."users" USING "btree" ("email_change_token_current") WHERE (("email_change_token_current")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "email_change_token_new_idx" ON "auth"."users" USING "btree" ("email_change_token_new") WHERE (("email_change_token_new")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "factor_id_created_at_idx" ON "auth"."mfa_factors" USING "btree" ("user_id", "created_at");


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "flow_state_created_at_idx" ON "auth"."flow_state" USING "btree" ("created_at" DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "identities_email_idx" ON "auth"."identities" USING "btree" ("email" "text_pattern_ops");


--
-- Name: INDEX "identities_email_idx"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX "auth"."identities_email_idx" IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "identities_user_id_idx" ON "auth"."identities" USING "btree" ("user_id");


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "idx_auth_code" ON "auth"."flow_state" USING "btree" ("auth_code");


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "idx_user_id_auth_method" ON "auth"."flow_state" USING "btree" ("user_id", "authentication_method");


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "mfa_challenge_created_at_idx" ON "auth"."mfa_challenges" USING "btree" ("created_at" DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "mfa_factors_user_friendly_name_unique" ON "auth"."mfa_factors" USING "btree" ("friendly_name", "user_id") WHERE (TRIM(BOTH FROM "friendly_name") <> ''::"text");


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "mfa_factors_user_id_idx" ON "auth"."mfa_factors" USING "btree" ("user_id");


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "one_time_tokens_relates_to_hash_idx" ON "auth"."one_time_tokens" USING "hash" ("relates_to");


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "one_time_tokens_token_hash_hash_idx" ON "auth"."one_time_tokens" USING "hash" ("token_hash");


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "one_time_tokens_user_id_token_type_key" ON "auth"."one_time_tokens" USING "btree" ("user_id", "token_type");


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "reauthentication_token_idx" ON "auth"."users" USING "btree" ("reauthentication_token") WHERE (("reauthentication_token")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "recovery_token_idx" ON "auth"."users" USING "btree" ("recovery_token") WHERE (("recovery_token")::"text" !~ '^[0-9 ]*$'::"text");


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "refresh_tokens_instance_id_idx" ON "auth"."refresh_tokens" USING "btree" ("instance_id");


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "refresh_tokens_instance_id_user_id_idx" ON "auth"."refresh_tokens" USING "btree" ("instance_id", "user_id");


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "refresh_tokens_parent_idx" ON "auth"."refresh_tokens" USING "btree" ("parent");


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "refresh_tokens_session_id_revoked_idx" ON "auth"."refresh_tokens" USING "btree" ("session_id", "revoked");


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "refresh_tokens_updated_at_idx" ON "auth"."refresh_tokens" USING "btree" ("updated_at" DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "saml_providers_sso_provider_id_idx" ON "auth"."saml_providers" USING "btree" ("sso_provider_id");


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "saml_relay_states_created_at_idx" ON "auth"."saml_relay_states" USING "btree" ("created_at" DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "saml_relay_states_for_email_idx" ON "auth"."saml_relay_states" USING "btree" ("for_email");


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "saml_relay_states_sso_provider_id_idx" ON "auth"."saml_relay_states" USING "btree" ("sso_provider_id");


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "sessions_not_after_idx" ON "auth"."sessions" USING "btree" ("not_after" DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "sessions_user_id_idx" ON "auth"."sessions" USING "btree" ("user_id");


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "sso_domains_domain_idx" ON "auth"."sso_domains" USING "btree" ("lower"("domain"));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "sso_domains_sso_provider_id_idx" ON "auth"."sso_domains" USING "btree" ("sso_provider_id");


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "sso_providers_resource_id_idx" ON "auth"."sso_providers" USING "btree" ("lower"("resource_id"));


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "unique_phone_factor_per_user" ON "auth"."mfa_factors" USING "btree" ("user_id", "phone");


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "user_id_created_at_idx" ON "auth"."sessions" USING "btree" ("user_id", "created_at");


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX "users_email_partial_key" ON "auth"."users" USING "btree" ("email") WHERE ("is_sso_user" = false);


--
-- Name: INDEX "users_email_partial_key"; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX "auth"."users_email_partial_key" IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "users_instance_id_email_idx" ON "auth"."users" USING "btree" ("instance_id", "lower"(("email")::"text"));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "users_instance_id_idx" ON "auth"."users" USING "btree" ("instance_id");


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX "users_is_anonymous_idx" ON "auth"."users" USING "btree" ("is_anonymous");


--
-- Name: idx_companies_name_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_companies_name_gin" ON "public"."companies" USING "gin" ("name" "public"."gin_trgm_ops");


--
-- Name: idx_company_tag_composite; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_company_tag_composite" ON "public"."company_tag" USING "btree" ("company_id", "tag_id");


--
-- Name: idx_jobs_title_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_jobs_title_gin" ON "public"."jobs" USING "gin" ("title" "public"."gin_trgm_ops");


--
-- Name: idx_salaries_added_date_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_salaries_added_date_desc" ON "public"."salaries" USING "btree" ("added_date" DESC);


--
-- Name: idx_salaries_composite_1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_salaries_composite_1" ON "public"."salaries" USING "btree" ("location", "gross_salary", "added_date") WHERE (("verification")::"text" = 'verified'::"text");


--
-- Name: idx_salaries_composite_2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_salaries_composite_2" ON "public"."salaries" USING "btree" ("work_type", "level", "gross_salary");


--
-- Name: idx_salaries_covering; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_salaries_covering" ON "public"."salaries" USING "btree" ("id", "location", "gross_salary", "net_salary", "added_date", "level", "work_type");


--
-- Name: idx_salaries_experience; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_salaries_experience" ON "public"."salaries" USING "btree" ("total_experience_years", "experience_years_company");


--
-- Name: idx_salaries_experience_salary; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_salaries_experience_salary" ON "public"."salaries" USING "btree" ("total_experience_years", "gross_salary", "net_salary");


--
-- Name: idx_salaries_gross_salary_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_salaries_gross_salary_desc" ON "public"."salaries" USING "btree" ("gross_salary" DESC);


--
-- Name: idx_salaries_location_salary; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_salaries_location_salary" ON "public"."salaries" USING "btree" ("location", "gross_salary", "net_salary");


--
-- Name: idx_salaries_net_salary_desc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_salaries_net_salary_desc" ON "public"."salaries" USING "btree" ("net_salary" DESC);


--
-- Name: idx_salary_job_composite; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_salary_job_composite" ON "public"."salary_job" USING "btree" ("salary_id", "job_id");


--
-- Name: idx_salary_technical_stack_composite; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx_salary_technical_stack_composite" ON "public"."salary_technical_stack" USING "btree" ("salary_id", "technical_stack_id");


--
-- Name: ix_companies_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_companies_id" ON "public"."companies" USING "btree" ("id");


--
-- Name: ix_jobs_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_jobs_id" ON "public"."jobs" USING "btree" ("id");


--
-- Name: ix_salaries_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_salaries_id" ON "public"."salaries" USING "btree" ("id");


--
-- Name: ix_tags_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_tags_id" ON "public"."tags" USING "btree" ("id");


--
-- Name: ix_technical_stacks_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "ix_technical_stacks_id" ON "public"."technical_stacks" USING "btree" ("id");


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX "ix_realtime_subscription_entity" ON "realtime"."subscription" USING "hash" ("entity");


--
-- Name: messages_topic_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX "messages_topic_index" ON "realtime"."messages" USING "btree" ("topic");


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX "subscription_subscription_id_entity_filters_key" ON "realtime"."subscription" USING "btree" ("subscription_id", "entity", "filters");


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX "bname" ON "storage"."buckets" USING "btree" ("name");


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX "bucketid_objname" ON "storage"."objects" USING "btree" ("bucket_id", "name");


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX "idx_multipart_uploads_list" ON "storage"."s3_multipart_uploads" USING "btree" ("bucket_id", "key", "created_at");


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX "idx_objects_bucket_id_name" ON "storage"."objects" USING "btree" ("bucket_id", "name" COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX "name_prefix_search" ON "storage"."objects" USING "btree" ("name" "text_pattern_ops");


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER "tr_check_filters" BEFORE INSERT OR UPDATE ON "realtime"."subscription" FOR EACH ROW EXECUTE FUNCTION "realtime"."subscription_check_filters"();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER "update_objects_updated_at" BEFORE UPDATE ON "storage"."objects" FOR EACH ROW EXECUTE FUNCTION "storage"."update_updated_at_column"();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."identities"
    ADD CONSTRAINT "identities_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_amr_claims"
    ADD CONSTRAINT "mfa_amr_claims_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions"("id") ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_challenges"
    ADD CONSTRAINT "mfa_challenges_auth_factor_id_fkey" FOREIGN KEY ("factor_id") REFERENCES "auth"."mfa_factors"("id") ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."mfa_factors"
    ADD CONSTRAINT "mfa_factors_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."one_time_tokens"
    ADD CONSTRAINT "one_time_tokens_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."refresh_tokens"
    ADD CONSTRAINT "refresh_tokens_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "auth"."sessions"("id") ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_providers"
    ADD CONSTRAINT "saml_providers_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_flow_state_id_fkey" FOREIGN KEY ("flow_state_id") REFERENCES "auth"."flow_state"("id") ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."saml_relay_states"
    ADD CONSTRAINT "saml_relay_states_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."sessions"
    ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY "auth"."sso_domains"
    ADD CONSTRAINT "sso_domains_sso_provider_id_fkey" FOREIGN KEY ("sso_provider_id") REFERENCES "auth"."sso_providers"("id") ON DELETE CASCADE;


--
-- Name: company_tag company_tag_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."company_tag"
    ADD CONSTRAINT "company_tag_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE CASCADE;


--
-- Name: company_tag company_tag_tag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."company_tag"
    ADD CONSTRAINT "company_tag_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "public"."tags"("id") ON DELETE CASCADE;


--
-- Name: salaries salaries_company_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."salaries"
    ADD CONSTRAINT "salaries_company_id_fkey" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id");


--
-- Name: salary_job salary_job_job_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."salary_job"
    ADD CONSTRAINT "salary_job_job_id_fkey" FOREIGN KEY ("job_id") REFERENCES "public"."jobs"("id") ON DELETE CASCADE;


--
-- Name: salary_job salary_job_salary_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."salary_job"
    ADD CONSTRAINT "salary_job_salary_id_fkey" FOREIGN KEY ("salary_id") REFERENCES "public"."salaries"("id") ON DELETE CASCADE;


--
-- Name: salary_technical_stack salary_technical_stack_salary_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."salary_technical_stack"
    ADD CONSTRAINT "salary_technical_stack_salary_id_fkey" FOREIGN KEY ("salary_id") REFERENCES "public"."salaries"("id") ON DELETE CASCADE;


--
-- Name: salary_technical_stack salary_technical_stack_technical_stack_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "public"."salary_technical_stack"
    ADD CONSTRAINT "salary_technical_stack_technical_stack_id_fkey" FOREIGN KEY ("technical_stack_id") REFERENCES "public"."technical_stacks"("id") ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."objects"
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads"
    ADD CONSTRAINT "s3_multipart_uploads_bucket_id_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_bucket_id_fkey" FOREIGN KEY ("bucket_id") REFERENCES "storage"."buckets"("id");


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY "storage"."s3_multipart_uploads_parts"
    ADD CONSTRAINT "s3_multipart_uploads_parts_upload_id_fkey" FOREIGN KEY ("upload_id") REFERENCES "storage"."s3_multipart_uploads"("id") ON DELETE CASCADE;


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."audit_log_entries" ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."flow_state" ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."identities" ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."instances" ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."mfa_amr_claims" ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."mfa_challenges" ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."mfa_factors" ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."one_time_tokens" ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."refresh_tokens" ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."saml_providers" ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."saml_relay_states" ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."schema_migrations" ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."sessions" ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."sso_domains" ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."sso_providers" ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE "auth"."users" ENABLE ROW LEVEL SECURITY;

--
-- Name: alembic_version; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."alembic_version" ENABLE ROW LEVEL SECURITY;

--
-- Name: companies; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."companies" ENABLE ROW LEVEL SECURITY;

--
-- Name: company_tag; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."company_tag" ENABLE ROW LEVEL SECURITY;

--
-- Name: jobs; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."jobs" ENABLE ROW LEVEL SECURITY;

--
-- Name: salaries; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."salaries" ENABLE ROW LEVEL SECURITY;

--
-- Name: salary_job; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."salary_job" ENABLE ROW LEVEL SECURITY;

--
-- Name: salary_technical_stack; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."salary_technical_stack" ENABLE ROW LEVEL SECURITY;

--
-- Name: tags; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."tags" ENABLE ROW LEVEL SECURITY;

--
-- Name: technical_stacks; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE "public"."technical_stacks" ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE "realtime"."messages" ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."buckets" ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."migrations" ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."objects" ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."s3_multipart_uploads" ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE "storage"."s3_multipart_uploads_parts" ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION "supabase_realtime" WITH (publish = 'insert, update, delete, truncate');


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "issue_graphql_placeholder" ON "sql_drop"
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION "extensions"."set_graphql_placeholder"();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "issue_pg_cron_access" ON "ddl_command_end"
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION "extensions"."grant_pg_cron_access"();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "issue_pg_graphql_access" ON "ddl_command_end"
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION "extensions"."grant_pg_graphql_access"();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "issue_pg_net_access" ON "ddl_command_end"
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION "extensions"."grant_pg_net_access"();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "pgrst_ddl_watch" ON "ddl_command_end"
   EXECUTE FUNCTION "extensions"."pgrst_ddl_watch"();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER "pgrst_drop_watch" ON "sql_drop"
   EXECUTE FUNCTION "extensions"."pgrst_drop_watch"();


--
-- PostgreSQL database dump complete
--

