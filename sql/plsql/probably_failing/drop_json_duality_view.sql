-- DROP JSON RELATIONAL DUALITY VIEW statement examples
-- This statement is not currently supported by the PlSql grammar
-- JSON Relational Duality Views were introduced in Oracle 23ai

-- Note: Duality views are dropped like regular views

-- Simple drop
DROP VIEW departments_dv;

-- Drop if exists
DROP VIEW IF EXISTS customer_orders_dv;

-- Using full syntax (non-standard)
DROP JSON RELATIONAL DUALITY VIEW products_dv;

-- Drop with CASCADE CONSTRAINTS
DROP VIEW order_details_dv CASCADE CONSTRAINTS;
