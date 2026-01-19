-- MERGE with LOG ERRORS clause (10g R2+)
-- Tests error logging for constraint violations during MERGE operations

-- Basic MERGE with LOG ERRORS
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = u.salary,
               e.department_id = u.department_id
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, last_name, salary, department_id)
    VALUES (u.employee_id, u.first_name, u.last_name, u.salary, u.department_id)
LOG ERRORS REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS and specific reject limit
MERGE INTO products p
USING product_updates pu
ON (p.product_id = pu.product_id)
WHEN MATCHED THEN
    UPDATE SET p.price = pu.price,
               p.quantity = pu.quantity
WHEN NOT MATCHED THEN
    INSERT (product_id, product_name, price, quantity)
    VALUES (pu.product_id, pu.product_name, pu.price, pu.quantity)
LOG ERRORS REJECT LIMIT 100;

-- MERGE with LOG ERRORS into specific error table
MERGE INTO customers c
USING customer_updates cu
ON (c.customer_id = cu.customer_id)
WHEN MATCHED THEN
    UPDATE SET c.email = cu.email,
               c.phone = cu.phone
WHEN NOT MATCHED THEN
    INSERT (customer_id, customer_name, email, phone)
    VALUES (cu.customer_id, cu.customer_name, cu.email, cu.phone)
LOG ERRORS INTO customer_merge_errors REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS and error tag
MERGE INTO employees e
USING employee_staging es
ON (e.employee_id = es.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = es.salary,
               e.commission_pct = es.commission_pct
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, last_name, salary, department_id, hire_date)
    VALUES (es.employee_id, es.first_name, es.last_name, es.salary, es.department_id, SYSDATE)
LOG ERRORS INTO emp_merge_errors ('STAGING_LOAD_2024_Q1') REJECT LIMIT UNLIMITED;

-- Query error log
SELECT ora_err_number$, ora_err_mesg$, ora_err_tag$, employee_id, salary
FROM emp_merge_errors
WHERE ora_err_tag$ = 'STAGING_LOAD_2024_Q1';

-- MERGE with LOG ERRORS - numeric reject limit
MERGE INTO orders o
USING order_staging os
ON (o.order_id = os.order_id)
WHEN MATCHED THEN
    UPDATE SET o.order_status = os.order_status,
               o.order_total = os.order_total
WHEN NOT MATCHED THEN
    INSERT (order_id, customer_id, order_date, order_total)
    VALUES (os.order_id, os.customer_id, os.order_date, os.order_total)
LOG ERRORS REJECT LIMIT 50;

-- MERGE with LOG ERRORS - testing unique constraint violations
MERGE INTO employees e
USING (
    SELECT 100 as employee_id, 'john.doe@company.com' as email, 50000 as salary
    FROM DUAL
    UNION ALL
    SELECT 101, 'john.doe@company.com', 55000 FROM DUAL  -- Duplicate email
) u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.email = u.email
WHEN NOT MATCHED THEN
    INSERT (employee_id, email, salary)
    VALUES (u.employee_id, u.email, u.salary)
LOG ERRORS INTO emp_email_errors REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - testing foreign key constraint violations
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.department_id = u.department_id  -- May violate FK if dept doesn't exist
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, department_id)
    VALUES (u.employee_id, u.first_name, u.department_id)
LOG ERRORS INTO emp_fk_errors ('FK_VIOLATION_TEST') REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - testing check constraint violations
MERGE INTO employees e
USING salary_updates su
ON (e.employee_id = su.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = su.new_salary  -- May violate check constraint if salary < 0
LOG ERRORS INTO emp_check_errors ('SALARY_CHECK_TEST') REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - testing NOT NULL constraint violations
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.email = u.email  -- May violate NOT NULL if email is NULL
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, email)
    VALUES (u.employee_id, u.first_name, u.email)
LOG ERRORS INTO emp_null_errors REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS from complex source
MERGE INTO product_summary ps
USING (
    SELECT p.product_id,
           p.product_name,
           SUM(s.quantity) as total_sold,
           SUM(s.amount) as total_revenue
    FROM products p
    LEFT JOIN sales s ON p.product_id = s.product_id
    WHERE s.sale_date >= TRUNC(SYSDATE, 'MM')
    GROUP BY p.product_id, p.product_name
) src
ON (ps.product_id = src.product_id)
WHEN MATCHED THEN
    UPDATE SET ps.total_sold = src.total_sold,
               ps.total_revenue = src.total_revenue
WHEN NOT MATCHED THEN
    INSERT (product_id, product_name, total_sold, total_revenue)
    VALUES (src.product_id, src.product_name, src.total_sold, src.total_revenue)
LOG ERRORS INTO product_summary_errors ('MONTHLY_SUMMARY') REJECT LIMIT 500;

-- MERGE with LOG ERRORS and WHERE clauses
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = u.salary
    WHERE u.salary > 0  -- Additional validation
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, salary)
    VALUES (u.employee_id, u.first_name, u.salary)
    WHERE u.salary >= 30000
LOG ERRORS INTO emp_merge_errors ('CONDITIONAL_UPDATE') REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS and DELETE clause
MERGE INTO customer_accounts ca
USING account_updates au
ON (ca.account_id = au.account_id)
WHEN MATCHED THEN
    UPDATE SET ca.balance = au.balance,
               ca.status = au.status
    DELETE WHERE au.status = 'CLOSED' AND au.balance = 0
WHEN NOT MATCHED THEN
    INSERT (account_id, account_name, balance, status)
    VALUES (au.account_id, au.account_name, au.balance, au.status)
LOG ERRORS INTO account_merge_errors REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - handling trigger exceptions
-- Triggers might raise exceptions that will be logged
MERGE INTO orders o
USING order_updates ou
ON (o.order_id = ou.order_id)
WHEN MATCHED THEN
    UPDATE SET o.order_status = ou.order_status,
               o.updated_date = SYSDATE
WHEN NOT MATCHED THEN
    INSERT (order_id, customer_id, order_date, order_total)
    VALUES (ou.order_id, ou.customer_id, ou.order_date, ou.order_total)
LOG ERRORS INTO order_trigger_errors ('TRIGGER_TEST') REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - batch processing
MERGE INTO transaction_summary ts
USING (
    SELECT account_id,
           SUM(CASE WHEN transaction_type = 'DEBIT' THEN amount ELSE 0 END) as total_debits,
           SUM(CASE WHEN transaction_type = 'CREDIT' THEN amount ELSE 0 END) as total_credits
    FROM transactions
    WHERE transaction_date >= TRUNC(SYSDATE)
    GROUP BY account_id
) t
ON (ts.account_id = t.account_id AND ts.summary_date = TRUNC(SYSDATE))
WHEN MATCHED THEN
    UPDATE SET ts.total_debits = t.total_debits,
               ts.total_credits = t.total_credits
WHEN NOT MATCHED THEN
    INSERT (account_id, summary_date, total_debits, total_credits)
    VALUES (t.account_id, TRUNC(SYSDATE), t.total_debits, t.total_credits)
LOG ERRORS INTO transaction_summary_errors ('DAILY_SUMMARY') REJECT LIMIT 1000;

-- Check error count
SELECT COUNT(*) as error_count,
       ora_err_number$,
       ora_err_mesg$,
       COUNT(DISTINCT account_id) as affected_accounts
FROM transaction_summary_errors
WHERE ora_err_tag$ = 'DAILY_SUMMARY'
GROUP BY ora_err_number$, ora_err_mesg$;

-- MERGE with LOG ERRORS - multiple constraint types
MERGE INTO employees e
USING employee_staging es
ON (e.employee_id = es.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.email = es.email,           -- May violate unique constraint
               e.department_id = es.department_id,  -- May violate FK
               e.salary = es.salary          -- May violate check constraint
WHEN NOT MATCHED THEN
    INSERT (employee_id, email, department_id, salary)
    VALUES (es.employee_id, es.email, es.department_id, es.salary)
LOG ERRORS INTO emp_multi_errors ('MULTI_CONSTRAINT_TEST') REJECT LIMIT UNLIMITED;

-- Analyze specific error types
SELECT CASE ora_err_number$
           WHEN 1 THEN 'Unique constraint violation'
           WHEN 2291 THEN 'Foreign key constraint violation (parent not found)'
           WHEN 2292 THEN 'Foreign key constraint violation (child exists)'
           WHEN 1400 THEN 'NOT NULL constraint violation'
           WHEN 2290 THEN 'Check constraint violation'
           ELSE 'Other error: ' || ora_err_number$
       END as error_type,
       COUNT(*) as error_count,
       MIN(ora_err_mesg$) as sample_message
FROM emp_multi_errors
WHERE ora_err_tag$ = 'MULTI_CONSTRAINT_TEST'
GROUP BY ora_err_number$
ORDER BY error_count DESC;

-- MERGE with LOG ERRORS using CTE
WITH updated_salaries AS (
    SELECT employee_id, salary * 1.1 as new_salary
    FROM employees
    WHERE performance_rating >= 4
)
MERGE INTO employees e
USING updated_salaries us
ON (e.employee_id = us.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = us.new_salary
LOG ERRORS INTO salary_update_errors ('PERFORMANCE_RAISE') REJECT LIMIT 100;

-- MERGE with LOG ERRORS - handling data type mismatches
MERGE INTO numeric_data nd
USING staging_data sd
ON (nd.record_id = sd.record_id)
WHEN MATCHED THEN
    UPDATE SET nd.numeric_value = TO_NUMBER(sd.text_value)
WHEN NOT MATCHED THEN
    INSERT (record_id, numeric_value)
    VALUES (sd.record_id, TO_NUMBER(sd.text_value))
LOG ERRORS INTO numeric_conversion_errors REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - handling date format issues
MERGE INTO events e
USING event_staging es
ON (e.event_id = es.event_id)
WHEN MATCHED THEN
    UPDATE SET e.event_date = TO_DATE(es.event_date_str, 'YYYY-MM-DD')
WHEN NOT MATCHED THEN
    INSERT (event_id, event_name, event_date)
    VALUES (es.event_id, es.event_name, TO_DATE(es.event_date_str, 'YYYY-MM-DD'))
LOG ERRORS INTO event_date_errors REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - complex business rules
MERGE INTO account_balances ab
USING balance_updates bu
ON (ab.account_id = bu.account_id)
WHEN MATCHED THEN
    UPDATE SET ab.balance = ab.balance + bu.transaction_amount,
               ab.last_transaction_date = SYSDATE
    DELETE WHERE ab.balance + bu.transaction_amount < 0
              AND bu.account_type = 'SAVINGS'
WHEN NOT MATCHED THEN
    INSERT (account_id, balance, account_type, last_transaction_date)
    VALUES (bu.account_id, bu.transaction_amount, bu.account_type, SYSDATE)
LOG ERRORS INTO balance_errors ('TRANSACTION_PROCESSING') REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - handling LOB columns
MERGE INTO documents d
USING document_updates du
ON (d.doc_id = du.doc_id)
WHEN MATCHED THEN
    UPDATE SET d.content = du.content,
               d.last_modified = SYSDATE
WHEN NOT MATCHED THEN
    INSERT (doc_id, title, content, created_date)
    VALUES (du.doc_id, du.title, du.content, SYSDATE)
LOG ERRORS INTO document_merge_errors REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - handling JSON data (12c+)
MERGE INTO products_json pj
USING product_updates pu
ON (pj.product_id = pu.product_id)
WHEN MATCHED THEN
    UPDATE SET pj.product_data = pu.product_data
WHEN NOT MATCHED THEN
    INSERT (product_id, product_data)
    VALUES (pu.product_id, pu.product_data)
LOG ERRORS INTO product_json_errors REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - handling XML data
MERGE INTO xml_documents xd
USING xml_updates xu
ON (xd.doc_id = xu.doc_id)
WHEN MATCHED THEN
    UPDATE SET xd.xml_data = xu.xml_data
WHEN NOT MATCHED THEN
    INSERT (doc_id, xml_data)
    VALUES (xu.doc_id, xu.xml_data)
LOG ERRORS INTO xml_merge_errors REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - parallel execution
MERGE /*+ PARALLEL(employees, 4) */ INTO employees e
USING employee_staging es
ON (e.employee_id = es.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = es.salary,
               e.department_id = es.department_id
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, last_name, salary, department_id)
    VALUES (es.employee_id, es.first_name, es.last_name, es.salary, es.department_id)
LOG ERRORS INTO emp_parallel_errors ('PARALLEL_LOAD') REJECT LIMIT 5000;

-- MERGE with LOG ERRORS - partitioned table
MERGE INTO sales_history PARTITION (sales_2024_q1) sh
USING sales_staging ss
ON (sh.sale_id = ss.sale_id)
WHEN MATCHED THEN
    UPDATE SET sh.sale_amount = ss.sale_amount
WHEN NOT MATCHED THEN
    INSERT (sale_id, product_id, sale_date, sale_amount)
    VALUES (ss.sale_id, ss.product_id, ss.sale_date, ss.sale_amount)
LOG ERRORS INTO sales_partition_errors ('Q1_2024_LOAD') REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - recovery pattern
-- First attempt
MERGE INTO master_data md
USING staging_data sd
ON (md.record_id = sd.record_id)
WHEN MATCHED THEN
    UPDATE SET md.data_value = sd.data_value
WHEN NOT MATCHED THEN
    INSERT (record_id, data_value)
    VALUES (sd.record_id, sd.data_value)
LOG ERRORS INTO merge_errors ('ATTEMPT_1') REJECT LIMIT UNLIMITED;

-- Identify problem records
SELECT record_id, ora_err_number$, ora_err_mesg$
FROM merge_errors
WHERE ora_err_tag$ = 'ATTEMPT_1';

-- Fix issues in staging table
UPDATE staging_data sd
SET data_value = 'CORRECTED'
WHERE record_id IN (
    SELECT record_id
    FROM merge_errors
    WHERE ora_err_tag$ = 'ATTEMPT_1'
);

-- Retry merge
MERGE INTO master_data md
USING staging_data sd
ON (md.record_id = sd.record_id)
WHEN MATCHED THEN
    UPDATE SET md.data_value = sd.data_value
WHEN NOT MATCHED THEN
    INSERT (record_id, data_value)
    VALUES (sd.record_id, sd.data_value)
LOG ERRORS INTO merge_errors ('ATTEMPT_2') REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - monitoring and reporting
MERGE INTO inventory_master im
USING inventory_staging ist
ON (im.item_id = ist.item_id)
WHEN MATCHED THEN
    UPDATE SET im.quantity = ist.quantity,
               im.location = ist.location
WHEN NOT MATCHED THEN
    INSERT (item_id, item_name, quantity, location)
    VALUES (ist.item_id, ist.item_name, ist.quantity, ist.location)
LOG ERRORS INTO inventory_merge_errors ('DAILY_INVENTORY_UPDATE') REJECT LIMIT 1000;

-- Generate merge report
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') as merge_time,
       (SELECT COUNT(*) FROM inventory_master) as total_records,
       (SELECT COUNT(*) FROM inventory_merge_errors WHERE ora_err_tag$ = 'DAILY_INVENTORY_UPDATE') as error_count,
       (SELECT COUNT(DISTINCT ora_err_number$) FROM inventory_merge_errors WHERE ora_err_tag$ = 'DAILY_INVENTORY_UPDATE') as distinct_errors
FROM DUAL;

-- MERGE with LOG ERRORS - handling complex types
MERGE INTO customers c
USING customer_updates cu
ON (c.customer_id = cu.customer_id)
WHEN MATCHED THEN
    UPDATE SET c.address = cu.address,
               c.contact_numbers = cu.contact_numbers
WHEN NOT MATCHED THEN
    INSERT (customer_id, customer_name, address, contact_numbers)
    VALUES (cu.customer_id, cu.customer_name, cu.address, cu.contact_numbers)
LOG ERRORS INTO customer_object_errors REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - handling NULL violations in complex scenarios
MERGE INTO order_details od
USING (
    SELECT o.order_id,
           o.customer_id,
           c.customer_name,
           o.order_date,
           o.order_total
    FROM orders o
    LEFT JOIN customers c ON o.customer_id = c.customer_id
) src
ON (od.order_id = src.order_id)
WHEN MATCHED THEN
    UPDATE SET od.customer_name = src.customer_name,
               od.order_total = src.order_total
WHEN NOT MATCHED THEN
    INSERT (order_id, customer_id, customer_name, order_date, order_total)
    VALUES (src.order_id, src.customer_id, src.customer_name, src.order_date, src.order_total)
LOG ERRORS INTO order_detail_errors ('ORDER_SYNC') REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - cleanup and archival
-- Archive old error logs before new merge
INSERT INTO archived_merge_errors
SELECT * FROM product_merge_errors
WHERE ora_err_timestamp$ < ADD_MONTHS(SYSDATE, -3);

DELETE FROM product_merge_errors
WHERE ora_err_timestamp$ < ADD_MONTHS(SYSDATE, -3);

-- Perform merge with fresh error logging
MERGE INTO products p
USING product_staging ps
ON (p.product_id = ps.product_id)
WHEN MATCHED THEN
    UPDATE SET p.price = ps.price,
               p.quantity = ps.quantity
WHEN NOT MATCHED THEN
    INSERT (product_id, product_name, price, quantity)
    VALUES (ps.product_id, ps.product_name, ps.price, ps.quantity)
LOG ERRORS INTO product_merge_errors ('CURRENT_LOAD') REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - handling cascading constraints
MERGE INTO parent_records pr
USING parent_staging ps
ON (pr.parent_id = ps.parent_id)
WHEN MATCHED THEN
    UPDATE SET pr.parent_value = ps.parent_value
WHEN NOT MATCHED THEN
    INSERT (parent_id, parent_value)
    VALUES (ps.parent_id, ps.parent_value)
LOG ERRORS INTO parent_merge_errors REJECT LIMIT UNLIMITED;

-- MERGE with LOG ERRORS - final summary query
SELECT ora_err_tag$,
       COUNT(*) as total_errors,
       MIN(ora_err_timestamp$) as first_error,
       MAX(ora_err_timestamp$) as last_error,
       COUNT(DISTINCT ora_err_number$) as distinct_error_codes
FROM emp_merge_errors
GROUP BY ora_err_tag$
ORDER BY MAX(ora_err_timestamp$) DESC;
