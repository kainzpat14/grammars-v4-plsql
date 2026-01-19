-- MERGE statement advanced clauses
-- Tests MERGE with WHERE clauses, DELETE clause, and complex patterns

-- MERGE with WHERE clause on UPDATE
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = u.salary
    WHERE u.salary > e.salary;

-- MERGE with WHERE clause on INSERT
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, last_name, salary)
    VALUES (u.employee_id, u.first_name, u.last_name, u.salary)
    WHERE u.salary >= 30000;

-- MERGE with WHERE clauses on both UPDATE and INSERT
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = u.salary,
               e.commission_pct = u.commission_pct
    WHERE u.last_updated >= TRUNC(SYSDATE)
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, last_name, salary, hire_date)
    VALUES (u.employee_id, u.first_name, u.last_name, u.salary, SYSDATE)
    WHERE u.status = 'APPROVED';

-- MERGE with DELETE clause (10g+)
-- Deletes matched rows that meet the condition
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.status = u.status
    DELETE WHERE u.status = 'TERMINATED';

-- MERGE with DELETE and UPDATE
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = u.salary,
               e.status = u.status,
               e.last_modified = SYSDATE
    DELETE WHERE u.status = 'INACTIVE' AND u.last_activity_date < ADD_MONTHS(SYSDATE, -6);

-- MERGE with DELETE clause and complex condition
MERGE INTO products p
USING product_updates pu
ON (p.product_id = pu.product_id)
WHEN MATCHED THEN
    UPDATE SET p.quantity = pu.quantity,
               p.last_updated = SYSDATE
    DELETE WHERE pu.quantity = 0 AND pu.discontinued = 'Y';

-- MERGE with DELETE based on updated value
MERGE INTO inventory i
USING inventory_updates iu
ON (i.item_id = iu.item_id)
WHEN MATCHED THEN
    UPDATE SET i.quantity = i.quantity + iu.adjustment
    DELETE WHERE i.quantity + iu.adjustment <= 0;

-- MERGE with WHERE clause using subquery
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = u.salary
    WHERE u.salary <= (SELECT MAX(salary) FROM employees WHERE department_id = e.department_id);

-- MERGE with WHERE clause using EXISTS
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.manager_id = u.manager_id
    WHERE EXISTS (
        SELECT 1
        FROM employees
        WHERE employee_id = u.manager_id
    );

-- MERGE with WHERE clause using IN
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.department_id = u.department_id
    WHERE u.department_id IN (10, 20, 30, 40);

-- MERGE with WHERE clause and complex boolean logic
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = u.salary,
               e.commission_pct = u.commission_pct
    WHERE (u.salary > e.salary AND u.salary <= e.salary * 1.5)
       OR (u.commission_pct IS NOT NULL AND u.commission_pct > 0)
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, salary)
    VALUES (u.employee_id, u.first_name, u.salary)
    WHERE u.salary >= 30000 AND u.department_id IS NOT NULL;

-- MERGE with DELETE and multiple conditions
MERGE INTO customer_orders co
USING order_updates ou
ON (co.order_id = ou.order_id)
WHEN MATCHED THEN
    UPDATE SET co.order_status = ou.order_status,
               co.updated_date = SYSDATE
    DELETE WHERE ou.order_status = 'CANCELLED'
              AND ou.cancelled_date < ADD_MONTHS(SYSDATE, -3)
              AND NOT EXISTS (
                  SELECT 1
                  FROM order_items oi
                  WHERE oi.order_id = co.order_id
                    AND oi.shipped = 'Y'
              );

-- MERGE with conditional UPDATE using CASE in WHERE
MERGE INTO employees e
USING salary_updates su
ON (e.employee_id = su.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = su.new_salary
    WHERE CASE
        WHEN e.job_id LIKE 'IT_%' THEN su.new_salary <= e.salary * 1.15
        WHEN e.job_id LIKE 'SA_%' THEN su.new_salary <= e.salary * 1.20
        ELSE su.new_salary <= e.salary * 1.10
    END;

-- MERGE with WHERE clause using date functions
MERGE INTO contracts c
USING contract_updates cu
ON (c.contract_id = cu.contract_id)
WHEN MATCHED THEN
    UPDATE SET c.end_date = cu.end_date
    WHERE cu.end_date > c.end_date
      AND MONTHS_BETWEEN(cu.end_date, c.start_date) <= 36;

-- MERGE with WHERE clause using string functions
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.email = u.email
    WHERE UPPER(u.email) LIKE '%@COMPANY.COM'
      AND LENGTH(u.email) <= 50;

-- MERGE with WHERE clause using numeric functions
MERGE INTO products p
USING price_updates pu
ON (p.product_id = pu.product_id)
WHEN MATCHED THEN
    UPDATE SET p.price = pu.new_price
    WHERE ABS(pu.new_price - p.price) / p.price <= 0.25;

-- MERGE with DELETE using aggregate in subquery
MERGE INTO product_inventory pi
USING inventory_updates iu
ON (pi.product_id = iu.product_id)
WHEN MATCHED THEN
    UPDATE SET pi.quantity = iu.quantity
    DELETE WHERE iu.quantity < (
        SELECT AVG(min_stock_level)
        FROM product_categories pc
        WHERE pc.category_id = pi.category_id
    ) * 0.1;

-- MERGE with multiple WHEN MATCHED clauses (10g R2+)
-- First WHEN MATCHED for high values, second for others
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED AND u.salary > 100000 THEN
    UPDATE SET e.salary = u.salary * 0.95,
               e.high_earner_flag = 'Y'
WHEN MATCHED AND u.salary <= 100000 THEN
    UPDATE SET e.salary = u.salary,
               e.high_earner_flag = 'N'
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, salary)
    VALUES (u.employee_id, u.first_name, u.salary);

-- MERGE with multiple WHEN NOT MATCHED clauses (10g R2+)
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = u.salary
WHEN NOT MATCHED AND u.department_id = 10 THEN
    INSERT (employee_id, first_name, salary, department_id, priority)
    VALUES (u.employee_id, u.first_name, u.salary, u.department_id, 'HIGH')
WHEN NOT MATCHED AND u.department_id != 10 THEN
    INSERT (employee_id, first_name, salary, department_id, priority)
    VALUES (u.employee_id, u.first_name, u.salary, u.department_id, 'NORMAL');

-- MERGE with multiple WHEN MATCHED and DELETE
MERGE INTO product_catalog pc
USING product_updates pu
ON (pc.product_id = pu.product_id)
WHEN MATCHED AND pu.status = 'ACTIVE' THEN
    UPDATE SET pc.price = pu.price,
               pc.quantity = pu.quantity
WHEN MATCHED AND pu.status = 'DISCONTINUED' THEN
    UPDATE SET pc.status = pu.status,
               pc.discontinued_date = SYSDATE
    DELETE WHERE pu.inventory_zero = 'Y';

-- MERGE with complex source and WHERE clauses
MERGE INTO sales_summary ss
USING (
    SELECT product_id, SUM(quantity) as total_qty, SUM(amount) as total_amt
    FROM sales
    WHERE sale_date >= TRUNC(SYSDATE, 'MM')
    GROUP BY product_id
    HAVING SUM(amount) > 1000
) s
ON (ss.product_id = s.product_id AND ss.period = TO_CHAR(SYSDATE, 'YYYY-MM'))
WHEN MATCHED THEN
    UPDATE SET ss.total_quantity = s.total_qty,
               ss.total_amount = s.total_amt
    WHERE s.total_amt > ss.total_amount
WHEN NOT MATCHED THEN
    INSERT (product_id, period, total_quantity, total_amount)
    VALUES (s.product_id, TO_CHAR(SYSDATE, 'YYYY-MM'), s.total_qty, s.total_amt)
    WHERE s.total_qty > 0;

-- MERGE with WHERE clause using ROWNUM
MERGE INTO sample_data sd
USING (
    SELECT employee_id, first_name, salary
    FROM employees
    WHERE department_id = 10
      AND ROWNUM <= 100
) src
ON (sd.employee_id = src.employee_id)
WHEN MATCHED THEN
    UPDATE SET sd.salary = src.salary
    WHERE src.salary > sd.salary;

-- MERGE with DELETE and INSERT ONLY (no UPDATE on match)
MERGE INTO temporary_cache tc
USING fresh_data fd
ON (tc.record_id = fd.record_id)
WHEN MATCHED THEN
    UPDATE SET tc.last_seen = SYSDATE
    DELETE WHERE fd.is_valid = 'N' OR fd.expired = 'Y'
WHEN NOT MATCHED THEN
    INSERT (record_id, data_value, last_seen)
    VALUES (fd.record_id, fd.data_value, SYSDATE);

-- MERGE with WHERE using DECODE
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.status = u.status
    WHERE DECODE(u.status, 'ACTIVE', 1, 'INACTIVE', 2, 3) = 1;

-- MERGE with WHERE using NVL
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.commission_pct = u.commission_pct
    WHERE NVL(u.commission_pct, 0) > NVL(e.commission_pct, 0);

-- MERGE with WHERE using COALESCE
MERGE INTO contacts c
USING contact_updates cu
ON (c.contact_id = cu.contact_id)
WHEN MATCHED THEN
    UPDATE SET c.phone = cu.phone
    WHERE COALESCE(cu.phone, c.phone, 'NONE') != 'NONE';

-- MERGE with DELETE using date comparison
MERGE INTO event_log el
USING event_updates eu
ON (el.event_id = eu.event_id)
WHEN MATCHED THEN
    UPDATE SET el.event_status = eu.event_status
    DELETE WHERE eu.event_date < ADD_MONTHS(SYSDATE, -12)
              AND eu.event_status = 'PROCESSED';

-- MERGE with conditional logic in both UPDATE and DELETE
MERGE INTO subscription_status ss
USING subscription_updates su
ON (ss.subscription_id = su.subscription_id)
WHEN MATCHED THEN
    UPDATE SET ss.status = su.status,
               ss.renewal_date = CASE
                   WHEN su.status = 'RENEWED' THEN ADD_MONTHS(ss.expiry_date, 12)
                   ELSE ss.renewal_date
               END
    DELETE WHERE su.status = 'CANCELLED'
              AND su.cancellation_date < ADD_MONTHS(SYSDATE, -6)
              AND ss.has_pending_charges = 'N';

-- MERGE with WHERE clause using JSON functions (12c+)
MERGE INTO products p
USING product_updates pu
ON (p.product_id = pu.product_id)
WHEN MATCHED THEN
    UPDATE SET p.product_data = pu.product_data
    WHERE JSON_VALUE(pu.product_data, '$.active') = 'true';

-- MERGE with WHERE clause using XML functions
MERGE INTO xml_config xc
USING xml_config_updates xcu
ON (xc.config_id = xcu.config_id)
WHEN MATCHED THEN
    UPDATE SET xc.config_xml = xcu.config_xml
    WHERE EXTRACTVALUE(xcu.config_xml, '/config/enabled') = 'true';

-- MERGE with DELETE using NOT EXISTS
MERGE INTO customer_data cd
USING customer_updates cu
ON (cd.customer_id = cu.customer_id)
WHEN MATCHED THEN
    UPDATE SET cd.status = cu.status
    DELETE WHERE cu.status = 'INACTIVE'
              AND NOT EXISTS (
                  SELECT 1
                  FROM customer_orders co
                  WHERE co.customer_id = cd.customer_id
                    AND co.order_date > ADD_MONTHS(SYSDATE, -24)
              );

-- MERGE with DELETE using IN subquery
MERGE INTO project_assignments pa
USING assignment_updates au
ON (pa.assignment_id = au.assignment_id)
WHEN MATCHED THEN
    UPDATE SET pa.status = au.status
    DELETE WHERE au.status = 'COMPLETED'
              AND pa.project_id IN (
                  SELECT project_id
                  FROM projects
                  WHERE project_status = 'CLOSED'
              );

-- MERGE with multiple conditions in DELETE
MERGE INTO inventory_items ii
USING inventory_updates iu
ON (ii.item_id = iu.item_id)
WHEN MATCHED THEN
    UPDATE SET ii.quantity = iu.quantity,
               ii.last_updated = SYSDATE
    DELETE WHERE iu.quantity = 0
              AND iu.reorder_flag = 'N'
              AND iu.last_sale_date < ADD_MONTHS(SYSDATE, -6)
              AND ii.item_value < 10;

-- MERGE with WHERE clause using BETWEEN
MERGE INTO employees e
USING salary_adjustments sa
ON (e.employee_id = sa.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = e.salary * sa.adjustment_factor
    WHERE sa.adjustment_factor BETWEEN 0.95 AND 1.15;

-- MERGE with WHERE clause using LIKE
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.job_id = u.job_id
    WHERE u.job_id LIKE 'IT_%' OR u.job_id LIKE 'SA_%';

-- MERGE with WHERE clause using IS NULL/IS NOT NULL
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.manager_id = u.manager_id
    WHERE u.manager_id IS NOT NULL
      AND e.manager_id IS NULL;

-- MERGE with complex DELETE conditions
MERGE INTO customer_subscriptions cs
USING subscription_updates su
ON (cs.subscription_id = su.subscription_id)
WHEN MATCHED THEN
    UPDATE SET cs.subscription_type = su.subscription_type,
               cs.monthly_fee = su.monthly_fee
    DELETE WHERE (su.subscription_type = 'FREE' AND su.inactive_days > 180)
              OR (su.subscription_type = 'TRIAL' AND su.trial_end_date < SYSDATE - 30)
              OR (su.payment_failures >= 3);

-- MERGE with WHERE using analytical functions result (via inline view)
MERGE INTO employee_performance ep
USING (
    SELECT employee_id, performance_score,
           RANK() OVER (ORDER BY performance_score DESC) as perf_rank
    FROM performance_reviews
    WHERE review_date >= TRUNC(SYSDATE, 'YYYY')
) pr
ON (ep.employee_id = pr.employee_id)
WHEN MATCHED THEN
    UPDATE SET ep.performance_score = pr.performance_score,
               ep.performance_rank = pr.perf_rank
    WHERE pr.perf_rank <= 100;

-- MERGE with DELETE based on calculated value
MERGE INTO account_balances ab
USING balance_updates bu
ON (ab.account_id = bu.account_id)
WHEN MATCHED THEN
    UPDATE SET ab.balance = ab.balance + bu.transaction_amount
    DELETE WHERE ab.balance + bu.transaction_amount < 0
              AND bu.account_type = 'PREPAID';

-- MERGE with multiple WHERE clauses and DELETE
MERGE INTO product_ratings pr
USING rating_updates ru
ON (pr.product_id = ru.product_id AND pr.customer_id = ru.customer_id)
WHEN MATCHED AND ru.rating >= 1 AND ru.rating <= 5 THEN
    UPDATE SET pr.rating = ru.rating,
               pr.review_text = ru.review_text,
               pr.updated_date = SYSDATE
    WHERE ru.verified_purchase = 'Y'
    DELETE WHERE ru.rating = 0 OR ru.flagged_spam = 'Y'
WHEN NOT MATCHED AND ru.rating > 0 THEN
    INSERT (product_id, customer_id, rating, review_text, created_date)
    VALUES (ru.product_id, ru.customer_id, ru.rating, ru.review_text, SYSDATE)
    WHERE ru.verified_purchase = 'Y';

-- MERGE with WHERE clause using regular expressions
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.email = u.email
    WHERE REGEXP_LIKE(u.email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- MERGE with DELETE and UPDATE SET to computed value
MERGE INTO loyalty_points lp
USING transaction_points tp
ON (lp.customer_id = tp.customer_id)
WHEN MATCHED THEN
    UPDATE SET lp.points = lp.points + tp.points_earned - tp.points_redeemed,
               lp.last_transaction_date = tp.transaction_date
    DELETE WHERE lp.points + tp.points_earned - tp.points_redeemed <= 0
              AND tp.transaction_date < ADD_MONTHS(SYSDATE, -24);
