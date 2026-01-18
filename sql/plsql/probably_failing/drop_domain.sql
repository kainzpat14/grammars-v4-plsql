-- DROP DOMAIN statement examples
-- This statement is not currently supported by the PlSql grammar
-- SQL Domains were introduced in Oracle 23ai

-- Simple drop
DROP DOMAIN email_domain;

-- Drop if exists
DROP DOMAIN IF EXISTS status_code;

-- Drop with CASCADE
DROP DOMAIN year_of_birth CASCADE;

-- Drop from another schema
DROP DOMAIN hr.department_code;

-- Drop ENUM domain
DROP DOMAIN order_status;

-- Drop flexible domain
DROP DOMAIN expense_details;

-- Drop multi-column domain
DROP DOMAIN US_city;
