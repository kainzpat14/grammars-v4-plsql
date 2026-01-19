-- CREATE TABLE AS SELECT with advanced options
-- Tests various combinations with AS SELECT clause

-- Basic CTAS with NOLOGGING
CREATE TABLE emp_backup NOLOGGING
AS SELECT * FROM employees;

-- CTAS with PARALLEL and NOLOGGING
CREATE TABLE sales_summary NOLOGGING PARALLEL 4
AS SELECT
    product_id,
    SUM(quantity) as total_qty,
    SUM(amount) as total_amount
FROM sales
GROUP BY product_id;

-- CTAS with specific tablespace and storage
CREATE TABLE large_data_copy
TABLESPACE users
STORAGE (INITIAL 100M NEXT 100M)
AS SELECT * FROM large_data_table;

-- CTAS with partitioning defined
CREATE TABLE sales_partitioned
PARTITION BY RANGE (sale_date) (
    PARTITION p_2023 VALUES LESS THAN (TO_DATE('2024-01-01', 'YYYY-MM-DD')),
    PARTITION p_2024 VALUES LESS THAN (TO_DATE('2025-01-01', 'YYYY-MM-DD')),
    PARTITION p_max VALUES LESS THAN (MAXVALUE)
)
AS SELECT * FROM sales_history;

-- CTAS with COMPRESS
CREATE TABLE orders_compressed
COMPRESS FOR QUERY HIGH
AS SELECT * FROM orders WHERE order_date >= TRUNC(SYSDATE) - 365;

-- CTAS with INMEMORY
CREATE TABLE hot_data
INMEMORY PRIORITY HIGH
AS SELECT * FROM transactions WHERE trans_date >= TRUNC(SYSDATE) - 30;

-- CTAS with column subset and renamed columns
CREATE TABLE customer_summary (
    cust_id,
    cust_name,
    order_count,
    total_spent
)
AS SELECT
    customer_id,
    customer_name,
    COUNT(*) as order_count,
    SUM(order_total) as total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY customer_id, customer_name;

-- CTAS with PCTFREE, PCTUSED
CREATE TABLE archived_data
PCTFREE 10
PCTUSED 60
TABLESPACE archive_ts
AS SELECT * FROM historical_data WHERE data_year < 2020;

-- CTAS with CACHE/NOCACHE
CREATE TABLE lookup_data CACHE
AS SELECT * FROM reference_tables;

-- CTAS with ROWDEPENDENCIES
CREATE TABLE versioned_data ROWDEPENDENCIES
AS SELECT * FROM source_data;

-- CTAS with multiple storage and physical attributes
CREATE TABLE complex_copy
PCTFREE 20
INITRANS 10
MAXTRANS 255
STORAGE (
    INITIAL 50M
    NEXT 50M
    MINEXTENTS 1
    MAXEXTENTS 500
    PCTINCREASE 0
)
TABLESPACE data_ts
NOLOGGING
PARALLEL (DEGREE 8)
AS SELECT * FROM complex_source;

-- CTAS with ON COMMIT for global temporary table
CREATE GLOBAL TEMPORARY TABLE temp_results (
    id NUMBER,
    result VARCHAR2(100)
)
ON COMMIT DELETE ROWS
AS SELECT id, result FROM processing_queue WHERE status = 'READY';

-- CTAS with segment creation deferred
CREATE TABLE deferred_table
SEGMENT CREATION DEFERRED
AS SELECT * FROM template_table WHERE 1=0;

-- CTAS with LOB storage specifications
CREATE TABLE docs_with_lobs (
    doc_id NUMBER,
    doc_content CLOB
)
LOB (doc_content) STORE AS SECUREFILE (
    TABLESPACE lob_ts
    ENABLE STORAGE IN ROW
    CHUNK 8192
    CACHE
)
AS SELECT doc_id, doc_text FROM documents;
