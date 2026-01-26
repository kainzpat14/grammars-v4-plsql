-- ALTER JSON RELATIONAL DUALITY VIEW statement examples
-- This statement is not currently supported by the PlSql grammar
-- JSON Relational Duality Views were introduced in Oracle 23ai

-- Note: To redefine a duality view, you typically use CREATE OR REPLACE
-- However, ALTER can be used for specific operations like enabling logical replication

-- Enable logical replication
ALTER JSON RELATIONAL DUALITY VIEW departments_dv ENABLE LOGICAL REPLICATION;

-- Disable logical replication
ALTER JSON RELATIONAL DUALITY VIEW customer_orders_dv DISABLE LOGICAL REPLICATION;

-- Compile view - COMPILE not supported for JSON DUALITY VIEWS
-- Use CREATE OR REPLACE instead to recompile
-- ALTER JSON RELATIONAL DUALITY VIEW products_dv COMPILE;
