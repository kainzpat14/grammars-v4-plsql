-- DELETE with LOG ERRORS clause (10g R2+)
-- Tests error logging for constraint violations during bulk deletes
-- Note: DELETE with LOG ERRORS is less common than INSERT/UPDATE with LOG ERRORS
-- since delete operations typically fail due to foreign key constraints

-- Basic DELETE with LOG ERRORS
-- Useful when deleting with cascading constraints that might fail
DELETE FROM parent_table
WHERE status = 'INACTIVE'
LOG ERRORS REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS and specific reject limit
DELETE FROM orders
WHERE order_date < ADD_MONTHS(SYSDATE, -60)
LOG ERRORS REJECT LIMIT 100;

-- DELETE with LOG ERRORS into specific error table
DELETE FROM products
WHERE discontinued = 'Y'
LOG ERRORS INTO product_delete_errors REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS and error tag
DELETE FROM customers
WHERE account_status = 'CLOSED'
  AND last_order_date < ADD_MONTHS(SYSDATE, -36)
LOG ERRORS INTO customer_errors ('INACTIVE_CLEANUP_2024') REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - numeric reject limit
DELETE FROM staging_data
WHERE processed_flag = 'Y'
  AND created_date < TRUNC(SYSDATE) - 7
LOG ERRORS REJECT LIMIT 50;

-- DELETE with LOG ERRORS and zero reject limit (fail on first error)
DELETE FROM temp_records
WHERE session_id != SYS_CONTEXT('USERENV', 'SESSIONID')
LOG ERRORS REJECT LIMIT 0;

-- DELETE with LOG ERRORS for foreign key constraint violations
-- This will log errors when child records exist
DELETE FROM departments
WHERE department_id NOT IN (10, 20, 30)
LOG ERRORS INTO dept_delete_errors ('FK_VIOLATION_TEST') REJECT LIMIT UNLIMITED;

-- Query error log to see FK violations
SELECT ora_err_number$, ora_err_mesg$, ora_err_tag$, department_id
FROM dept_delete_errors
WHERE ora_err_tag$ = 'FK_VIOLATION_TEST';

-- DELETE with LOG ERRORS - handling trigger exceptions
-- Triggers might raise exceptions that will be logged
DELETE FROM employees
WHERE status = 'TERMINATED'
LOG ERRORS INTO emp_delete_errors ('TRIGGER_TEST') REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS using complex WHERE clause
DELETE FROM order_items
WHERE order_id IN (
    SELECT order_id
    FROM orders
    WHERE order_date < ADD_MONTHS(SYSDATE, -24)
      AND order_status = 'CANCELLED'
)
LOG ERRORS REJECT LIMIT 100;

-- DELETE with LOG ERRORS and subquery
DELETE FROM employees
WHERE employee_id IN (
    SELECT e.employee_id
    FROM employees e
    LEFT JOIN departments d ON e.department_id = d.department_id
    WHERE d.department_id IS NULL
)
LOG ERRORS INTO emp_orphan_errors ('ORPHAN_CLEANUP') REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - testing referential integrity
DELETE FROM categories
WHERE category_id > 1000
LOG ERRORS INTO category_errors REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - batch processing
DELETE FROM audit_log
WHERE log_date < ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -6)
  AND ROWNUM <= 10000
LOG ERRORS INTO audit_cleanup_errors ('MONTHLY_CLEANUP') REJECT LIMIT 500;

-- DELETE with LOG ERRORS - complex join pattern
DELETE FROM order_history oh
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.order_id = oh.order_id
      AND o.order_status = 'CANCELLED'
      AND o.cancelled_date < ADD_MONTHS(SYSDATE, -12)
)
LOG ERRORS REJECT LIMIT 100;

-- DELETE with LOG ERRORS - monitoring errors during execution
DELETE FROM product_reviews
WHERE product_id IN (
    SELECT product_id
    FROM products
    WHERE discontinued = 'Y'
)
LOG ERRORS INTO review_delete_errors ('DISCONTINUED_PRODUCTS') REJECT LIMIT UNLIMITED;

-- Check error count
SELECT COUNT(*) as error_count,
       ora_err_number$,
       ora_err_mesg$,
       COUNT(DISTINCT product_id) as affected_products
FROM review_delete_errors
WHERE ora_err_tag$ = 'DISCONTINUED_PRODUCTS'
GROUP BY ora_err_number$, ora_err_mesg$;

-- DELETE with LOG ERRORS - partitioned table
DELETE FROM sales_history PARTITION (sales_2020_q1)
WHERE processed = 'Y'
LOG ERRORS INTO sales_delete_errors ('PARTITION_CLEANUP') REJECT LIMIT 100;

-- DELETE with LOG ERRORS - handling cascade constraints
DELETE FROM projects
WHERE status = 'CANCELLED'
  AND end_date < ADD_MONTHS(SYSDATE, -24)
LOG ERRORS INTO project_delete_errors ('CASCADE_DELETE') REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - with hint
DELETE /*+ PARALLEL(logs, 4) */ FROM logs
WHERE log_level = 'DEBUG'
  AND log_timestamp < SYSTIMESTAMP - INTERVAL '7' DAY
LOG ERRORS REJECT LIMIT 1000;

-- DELETE with LOG ERRORS - global temporary table
DELETE FROM global_temp_data
WHERE session_id = SYS_CONTEXT('USERENV', 'SESSIONID')
  AND processed = 'Y'
LOG ERRORS INTO temp_delete_errors REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - using CTE
WITH old_orders AS (
    SELECT order_id
    FROM orders
    WHERE order_date < ADD_MONTHS(SYSDATE, -60)
      AND order_status IN ('COMPLETED', 'CANCELLED')
)
DELETE FROM order_items
WHERE order_id IN (SELECT order_id FROM old_orders)
LOG ERRORS INTO order_item_errors ('OLD_ORDER_CLEANUP') REJECT LIMIT 500;

-- DELETE with LOG ERRORS - handling trigger-based constraints
-- Some business rules might be enforced via triggers
DELETE FROM inventory_locations
WHERE quantity_on_hand = 0
  AND last_movement_date < ADD_MONTHS(SYSDATE, -12)
LOG ERRORS INTO inventory_delete_errors ('EMPTY_LOCATION_CLEANUP') REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - complex business logic
DELETE FROM customer_preferences cp
WHERE NOT EXISTS (
    SELECT 1
    FROM customers c
    WHERE c.customer_id = cp.customer_id
      AND c.account_status = 'ACTIVE'
)
LOG ERRORS INTO pref_delete_errors ('INACTIVE_CUSTOMER_PREFS') REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - archival pattern
DELETE FROM transaction_log
WHERE transaction_date < ADD_MONTHS(TRUNC(SYSDATE, 'YYYY'), -24)
LOG ERRORS INTO transaction_archive_errors ('ARCHIVE_2024') REJECT LIMIT 1000;

-- DELETE with LOG ERRORS - handling delete restrictions
-- Some records might have delete restrictions enforced by triggers
DELETE FROM master_data
WHERE status = 'OBSOLETE'
  AND last_updated < ADD_MONTHS(SYSDATE, -36)
LOG ERRORS INTO master_data_errors ('OBSOLETE_CLEANUP') REJECT LIMIT UNLIMITED;

-- Analyze errors
SELECT ora_err_number$,
       ora_err_mesg$,
       COUNT(*) as error_count,
       MIN(ora_err_timestamp$) as first_error,
       MAX(ora_err_timestamp$) as last_error
FROM master_data_errors
WHERE ora_err_tag$ = 'OBSOLETE_CLEANUP'
GROUP BY ora_err_number$, ora_err_mesg$
ORDER BY error_count DESC;

-- DELETE with LOG ERRORS - handling materialized view dependencies
-- Deletes might fail if MViews have dependencies
DELETE FROM base_table
WHERE archive_flag = 'Y'
LOG ERRORS INTO base_table_errors ('MVIEW_DEP_TEST') REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - handling check constraints on related tables
DELETE FROM price_list
WHERE effective_date < ADD_MONTHS(SYSDATE, -24)
  AND superseded = 'Y'
LOG ERRORS INTO price_list_errors REJECT LIMIT 100;

-- DELETE with LOG ERRORS - complex cascade scenario
DELETE FROM parent_records pr
WHERE NOT EXISTS (
    SELECT 1
    FROM child_records cr
    WHERE cr.parent_id = pr.parent_id
)
AND pr.status = 'INACTIVE'
LOG ERRORS INTO parent_record_errors ('ORPHAN_PARENT_CLEANUP') REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - time-based cleanup with constraints
DELETE FROM event_log
WHERE event_timestamp < SYSTIMESTAMP - INTERVAL '90' DAY
  AND event_type NOT IN ('CRITICAL', 'ERROR')
LOG ERRORS INTO event_log_errors ('QUARTERLY_CLEANUP') REJECT LIMIT 500;

-- DELETE with LOG ERRORS - handling delete triggers that might fail
DELETE FROM account_transactions
WHERE transaction_date < ADD_MONTHS(SYSDATE, -84)
  AND reconciled = 'Y'
LOG ERRORS INTO transaction_delete_errors ('7YEAR_CLEANUP') REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - multi-table dependency scenario
DELETE FROM shipping_addresses sa
WHERE NOT EXISTS (
    SELECT 1
    FROM customers c
    WHERE c.customer_id = sa.customer_id
)
AND NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.shipping_address_id = sa.address_id
)
LOG ERRORS INTO address_errors ('UNUSED_ADDRESS_CLEANUP') REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - handling complex FK chains
DELETE FROM level1_table
WHERE status = 'DELETED'
LOG ERRORS INTO level1_errors ('FK_CHAIN_TEST') REJECT LIMIT UNLIMITED;

-- Check specific error types
SELECT CASE ora_err_number$
           WHEN 2292 THEN 'Child record exists (FK violation)'
           WHEN 20001 THEN 'Custom trigger error'
           ELSE 'Other error: ' || ora_err_number$
       END as error_type,
       COUNT(*) as count,
       MIN(ora_err_mesg$) as sample_message
FROM level1_errors
WHERE ora_err_tag$ = 'FK_CHAIN_TEST'
GROUP BY ora_err_number$;

-- DELETE with LOG ERRORS - handling delete that might violate check constraints
-- (via trigger-enforced business rules)
DELETE FROM employee_assignments
WHERE assignment_date < ADD_MONTHS(SYSDATE, -12)
  AND assignment_status = 'COMPLETED'
LOG ERRORS INTO assignment_errors ('COMPLETED_CLEANUP') REJECT LIMIT 100;

-- DELETE with LOG ERRORS - handling LOB dependencies
DELETE FROM documents
WHERE doc_type = 'TEMP'
  AND created_date < TRUNC(SYSDATE) - 1
LOG ERRORS INTO document_errors REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - cleanup with multiple conditions
DELETE FROM notification_queue
WHERE (status = 'SENT' AND sent_date < ADD_MONTHS(SYSDATE, -1))
   OR (status = 'FAILED' AND retry_count >= 5)
   OR (status = 'CANCELLED')
LOG ERRORS INTO notification_errors ('QUEUE_CLEANUP') REJECT LIMIT 1000;

-- DELETE with LOG ERRORS - recovery pattern
-- First attempt
DELETE FROM staging_table
WHERE batch_id = 'BATCH_001'
LOG ERRORS INTO staging_errors ('BATCH_001_ATTEMPT_1') REJECT LIMIT UNLIMITED;

-- Analyze errors
CREATE TABLE batch_001_problem_ids AS
SELECT record_id
FROM staging_errors
WHERE ora_err_tag$ = 'BATCH_001_ATTEMPT_1';

-- Fix the problems (example: remove FK references)
DELETE FROM child_references
WHERE parent_id IN (SELECT record_id FROM batch_001_problem_ids);

-- Retry original delete
DELETE FROM staging_table
WHERE batch_id = 'BATCH_001'
LOG ERRORS INTO staging_errors ('BATCH_001_ATTEMPT_2') REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - handling index-organized table constraints
DELETE FROM iot_table
WHERE key_value < 1000
LOG ERRORS INTO iot_errors REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - handling object type dependencies
DELETE FROM object_table
WHERE status = 'OBSOLETE'
LOG ERRORS INTO object_errors REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - cleanup with subquery conditions
DELETE FROM user_sessions us
WHERE us.session_id IN (
    SELECT session_id
    FROM session_activity
    WHERE last_activity < SYSTIMESTAMP - INTERVAL '24' HOUR
    GROUP BY session_id
    HAVING COUNT(*) = 0
)
LOG ERRORS INTO session_errors ('INACTIVE_SESSION_CLEANUP') REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - handling XMLType constraints
DELETE FROM xml_store
WHERE XMLEXISTS('$p/root/archived[text()="true"]' PASSING xml_data AS "p")
LOG ERRORS INTO xml_delete_errors REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - handling JSON constraints (12c+)
DELETE FROM json_store
WHERE JSON_VALUE(data, '$.status') = 'deleted'
LOG ERRORS INTO json_delete_errors REJECT LIMIT UNLIMITED;

-- DELETE with LOG ERRORS - final cleanup and reporting
DELETE FROM temp_processing_data
WHERE processing_date < TRUNC(SYSDATE)
LOG ERRORS INTO temp_cleanup_errors ('DAILY_CLEANUP') REJECT LIMIT UNLIMITED;

-- Generate cleanup report
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') as cleanup_time,
       (SELECT COUNT(*) FROM temp_processing_data) as remaining_records,
       (SELECT COUNT(*) FROM temp_cleanup_errors WHERE ora_err_tag$ = 'DAILY_CLEANUP') as error_count,
       (SELECT COUNT(DISTINCT ora_err_number$) FROM temp_cleanup_errors WHERE ora_err_tag$ = 'DAILY_CLEANUP') as distinct_errors
FROM DUAL;

-- DELETE with LOG ERRORS - parallel execution
DELETE /*+ PARALLEL(archive_data, 8) */ FROM archive_data
WHERE archive_year < EXTRACT(YEAR FROM SYSDATE) - 7
LOG ERRORS INTO archive_delete_errors ('7YEAR_RETENTION') REJECT LIMIT 10000;

-- DELETE with LOG ERRORS - handling external table constraints
-- (External tables don't support DML, but this pattern for regular tables with similar structure)
DELETE FROM imported_data
WHERE import_status = 'PROCESSED'
  AND import_date < ADD_MONTHS(SYSDATE, -3)
LOG ERRORS INTO import_cleanup_errors REJECT LIMIT UNLIMITED;
