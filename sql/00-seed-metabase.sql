-- =============================================================
-- Metabase application database bootstrap
-- This file runs first because of the 00 prefix.
-- It creates the role and database used by Metabase itself.
-- =============================================================

CREATE USER metabase WITH PASSWORD 'metabase_password';
CREATE DATABASE metabaseappdb OWNER metabase;
