-- SSDM9 Service Master Schema Correction Script
-- Generated automatically on 2025-10-25 04:44:15

-- Purpose: Ensure serv_dely_location and serv_special_instr are correctly defined as text fields.
-- These columns were previously created as double precision but should store textual information.

ALTER TABLE ssdm9.ssdm9_service_master
ALTER COLUMN serv_dely_location TYPE text USING serv_dely_location::text,
ALTER COLUMN serv_special_instr TYPE text USING serv_special_instr::text;

-- Verification command to confirm applied changes:
-- SELECT column_name, data_type FROM information_schema.columns
-- WHERE table_schema = 'ssdm9' AND table_name = 'ssdm9_service_master';
