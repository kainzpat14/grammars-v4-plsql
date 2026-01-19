-- MERGE statement basic variations
-- Tests MERGE (UPSERT) syntax with WHEN MATCHED and WHEN NOT MATCHED clauses

-- Basic MERGE with UPDATE and INSERT
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = u.salary,
               e.department_id = u.department_id
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, last_name, salary, department_id)
    VALUES (u.employee_id, u.first_name, u.last_name, u.salary, u.department_id);

-- MERGE with inline view as source
MERGE INTO employees e
USING (
    SELECT employee_id, salary, commission_pct
    FROM salary_updates
    WHERE effective_date = TRUNC(SYSDATE)
) u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = u.salary,
               e.commission_pct = u.commission_pct;

-- MERGE with only UPDATE (no INSERT)
MERGE INTO employees e
USING salary_adjustments sa
ON (e.employee_id = sa.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = e.salary * sa.adjustment_factor;

-- MERGE with only INSERT (no UPDATE)
MERGE INTO employees e
USING new_hires nh
ON (e.employee_id = nh.employee_id)
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, last_name, email, hire_date)
    VALUES (nh.employee_id, nh.first_name, nh.last_name, nh.email, SYSDATE);

-- MERGE with expression in UPDATE
MERGE INTO employees e
USING performance_bonuses pb
ON (e.employee_id = pb.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = e.salary * (1 + pb.bonus_pct),
               e.last_bonus_date = SYSDATE;

-- MERGE with function calls
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.first_name = INITCAP(u.first_name),
               e.last_name = UPPER(u.last_name),
               e.email = LOWER(u.email)
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, last_name, email)
    VALUES (u.employee_id, INITCAP(u.first_name), UPPER(u.last_name), LOWER(u.email));

-- MERGE with SYSDATE/USER
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = u.salary,
               e.last_modified = SYSDATE,
               e.modified_by = USER
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, salary, created_date, created_by)
    VALUES (u.employee_id, u.first_name, u.salary, SYSDATE, USER);

-- MERGE with CASE expression
MERGE INTO employees e
USING salary_updates su
ON (e.employee_id = su.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = CASE
        WHEN su.salary > e.salary * 1.5 THEN e.salary * 1.5
        WHEN su.salary < e.salary * 0.9 THEN e.salary * 0.9
        ELSE su.salary
    END;

-- MERGE with NVL/COALESCE
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.commission_pct = NVL(u.commission_pct, e.commission_pct),
               e.manager_id = COALESCE(u.manager_id, e.manager_id, 100);

-- MERGE with concatenation
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.full_name = u.first_name || ' ' || u.last_name;

-- MERGE with arithmetic operations
MERGE INTO products p
USING price_updates pu
ON (p.product_id = pu.product_id)
WHEN MATCHED THEN
    UPDATE SET p.price = p.price * (1 + pu.increase_pct),
               p.discount = p.price * 0.1
WHEN NOT MATCHED THEN
    INSERT (product_id, product_name, price)
    VALUES (pu.product_id, pu.product_name, pu.price);

-- MERGE with date arithmetic
MERGE INTO contracts c
USING contract_extensions ce
ON (c.contract_id = ce.contract_id)
WHEN MATCHED THEN
    UPDATE SET c.end_date = c.end_date + ce.extension_days,
               c.renewal_count = c.renewal_count + 1;

-- MERGE with timestamp
MERGE INTO audit_log al
USING new_audit_entries nae
ON (al.audit_id = nae.audit_id)
WHEN NOT MATCHED THEN
    INSERT (audit_id, event_type, event_timestamp)
    VALUES (nae.audit_id, nae.event_type, SYSTIMESTAMP);

-- MERGE with interval
MERGE INTO schedules s
USING schedule_updates su
ON (s.schedule_id = su.schedule_id)
WHEN MATCHED THEN
    UPDATE SET s.start_time = s.start_time + INTERVAL '1' HOUR;

-- MERGE with multiple column updates
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.first_name = u.first_name,
               e.last_name = u.last_name,
               e.email = u.email,
               e.phone_number = u.phone_number,
               e.salary = u.salary,
               e.commission_pct = u.commission_pct,
               e.manager_id = u.manager_id,
               e.department_id = u.department_id,
               e.last_modified = SYSDATE
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, last_name, email, phone_number,
            hire_date, job_id, salary, commission_pct, manager_id, department_id)
    VALUES (u.employee_id, u.first_name, u.last_name, u.email, u.phone_number,
            SYSDATE, u.job_id, u.salary, u.commission_pct, u.manager_id, u.department_id);

-- MERGE with DEFAULT keyword
MERGE INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, last_name, salary, commission_pct)
    VALUES (u.employee_id, u.first_name, u.last_name, u.salary, DEFAULT);

-- MERGE with subquery in source
MERGE INTO department_stats ds
USING (
    SELECT department_id,
           COUNT(*) as emp_count,
           AVG(salary) as avg_salary,
           SUM(salary) as total_salary
    FROM employees
    GROUP BY department_id
) e
ON (ds.department_id = e.department_id)
WHEN MATCHED THEN
    UPDATE SET ds.employee_count = e.emp_count,
               ds.average_salary = e.avg_salary,
               ds.total_salary = e.total_salary,
               ds.last_updated = SYSDATE
WHEN NOT MATCHED THEN
    INSERT (department_id, employee_count, average_salary, total_salary, last_updated)
    VALUES (e.department_id, e.emp_count, e.avg_salary, e.total_salary, SYSDATE);

-- MERGE with JOIN in source
MERGE INTO employee_details ed
USING (
    SELECT e.employee_id, e.first_name, e.last_name, d.department_name, l.city
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    JOIN locations l ON d.location_id = l.location_id
) src
ON (ed.employee_id = src.employee_id)
WHEN MATCHED THEN
    UPDATE SET ed.department_name = src.department_name,
               ed.city = src.city
WHEN NOT MATCHED THEN
    INSERT (employee_id, full_name, department_name, city)
    VALUES (src.employee_id, src.first_name || ' ' || src.last_name,
            src.department_name, src.city);

-- MERGE with LEFT JOIN in source
MERGE INTO employee_assignments ea
USING (
    SELECT e.employee_id, e.first_name, p.project_id, p.project_name
    FROM employees e
    LEFT JOIN project_assignments pa ON e.employee_id = pa.employee_id
    LEFT JOIN projects p ON pa.project_id = p.project_id
) src
ON (ea.employee_id = src.employee_id)
WHEN MATCHED THEN
    UPDATE SET ea.project_id = src.project_id,
               ea.project_name = src.project_name;

-- MERGE with UNION in source
MERGE INTO all_contacts ac
USING (
    SELECT employee_id as contact_id, email, 'EMPLOYEE' as contact_type
    FROM employees
    UNION ALL
    SELECT customer_id, email, 'CUSTOMER'
    FROM customers
) src
ON (ac.contact_id = src.contact_id AND ac.contact_type = src.contact_type)
WHEN MATCHED THEN
    UPDATE SET ac.email = src.email
WHEN NOT MATCHED THEN
    INSERT (contact_id, email, contact_type)
    VALUES (src.contact_id, src.email, src.contact_type);

-- MERGE with CTE in source
MERGE INTO summary_table st
USING (
    WITH dept_totals AS (
        SELECT department_id, SUM(salary) as total_salary
        FROM employees
        GROUP BY department_id
    )
    SELECT department_id, total_salary
    FROM dept_totals
    WHERE total_salary > 50000
) src
ON (st.department_id = src.department_id)
WHEN MATCHED THEN
    UPDATE SET st.total_salary = src.total_salary
WHEN NOT MATCHED THEN
    INSERT (department_id, total_salary)
    VALUES (src.department_id, src.total_salary);

-- MERGE with analytic function in source
MERGE INTO employee_rankings er
USING (
    SELECT employee_id,
           RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) as salary_rank
    FROM employees
) src
ON (er.employee_id = src.employee_id)
WHEN MATCHED THEN
    UPDATE SET er.salary_rank = src.salary_rank
WHEN NOT MATCHED THEN
    INSERT (employee_id, salary_rank)
    VALUES (src.employee_id, src.salary_rank);

-- MERGE with PIVOT in source
MERGE INTO quarterly_sales_summary qss
USING (
    SELECT *
    FROM (
        SELECT product_id, TO_CHAR(sale_date, 'Q') as quarter, sale_amount
        FROM sales
        WHERE EXTRACT(YEAR FROM sale_date) = 2024
    )
    PIVOT (
        SUM(sale_amount)
        FOR quarter IN ('1' AS q1, '2' AS q2, '3' AS q3, '4' AS q4)
    )
) src
ON (qss.product_id = src.product_id)
WHEN MATCHED THEN
    UPDATE SET qss.q1_sales = src.q1,
               qss.q2_sales = src.q2,
               qss.q3_sales = src.q3,
               qss.q4_sales = src.q4;

-- MERGE with hierarchical query in source
MERGE INTO employee_levels el
USING (
    SELECT employee_id, LEVEL as org_level
    FROM employees
    START WITH manager_id IS NULL
    CONNECT BY PRIOR employee_id = manager_id
) src
ON (el.employee_id = src.employee_id)
WHEN MATCHED THEN
    UPDATE SET el.org_level = src.org_level
WHEN NOT MATCHED THEN
    INSERT (employee_id, org_level)
    VALUES (src.employee_id, src.org_level);

-- MERGE with DISTINCT in source
MERGE INTO unique_jobs uj
USING (
    SELECT DISTINCT job_id, job_title
    FROM jobs
) src
ON (uj.job_id = src.job_id)
WHEN MATCHED THEN
    UPDATE SET uj.job_title = src.job_title
WHEN NOT MATCHED THEN
    INSERT (job_id, job_title)
    VALUES (src.job_id, src.job_title);

-- MERGE with ORDER BY in source (using inline view)
MERGE INTO top_earners te
USING (
    SELECT employee_id, first_name, last_name, salary
    FROM (
        SELECT employee_id, first_name, last_name, salary
        FROM employees
        ORDER BY salary DESC
    )
    WHERE ROWNUM <= 10
) src
ON (te.employee_id = src.employee_id)
WHEN MATCHED THEN
    UPDATE SET te.salary = src.salary
WHEN NOT MATCHED THEN
    INSERT (employee_id, employee_name, salary)
    VALUES (src.employee_id, src.first_name || ' ' || src.last_name, src.salary);

-- MERGE with ROWNUM filter in source
MERGE INTO sample_employees se
USING (
    SELECT employee_id, first_name, last_name
    FROM employees
    WHERE department_id = 10
      AND ROWNUM <= 5
) src
ON (se.employee_id = src.employee_id)
WHEN NOT MATCHED THEN
    INSERT (employee_id, full_name)
    VALUES (src.employee_id, src.first_name || ' ' || src.last_name);

-- MERGE with FETCH FIRST in source (12c+)
MERGE INTO recent_hires rh
USING (
    SELECT employee_id, first_name, last_name, hire_date
    FROM employees
    ORDER BY hire_date DESC
    FETCH FIRST 20 ROWS ONLY
) src
ON (rh.employee_id = src.employee_id)
WHEN MATCHED THEN
    UPDATE SET rh.hire_date = src.hire_date
WHEN NOT MATCHED THEN
    INSERT (employee_id, employee_name, hire_date)
    VALUES (src.employee_id, src.first_name || ' ' || src.last_name, src.hire_date);

-- MERGE with CLOB column
MERGE INTO documents d
USING document_updates du
ON (d.doc_id = du.doc_id)
WHEN MATCHED THEN
    UPDATE SET d.content = du.content,
               d.last_modified = SYSDATE
WHEN NOT MATCHED THEN
    INSERT (doc_id, title, content, created_date)
    VALUES (du.doc_id, du.title, du.content, SYSDATE);

-- MERGE with BLOB column
MERGE INTO images i
USING image_updates iu
ON (i.image_id = iu.image_id)
WHEN MATCHED THEN
    UPDATE SET i.image_data = iu.image_data
WHEN NOT MATCHED THEN
    INSERT (image_id, image_name, image_data)
    VALUES (iu.image_id, iu.image_name, iu.image_data);

-- MERGE with XMLTYPE
MERGE INTO xml_documents xd
USING xml_updates xu
ON (xd.doc_id = xu.doc_id)
WHEN MATCHED THEN
    UPDATE SET xd.xml_data = xu.xml_data
WHEN NOT MATCHED THEN
    INSERT (doc_id, xml_data)
    VALUES (xu.doc_id, xu.xml_data);

-- MERGE with JSON (23ai)
MERGE INTO products_json pj
USING product_updates pu
ON (pj.product_id = pu.product_id)
WHEN MATCHED THEN
    UPDATE SET pj.product_data = pu.product_data
WHEN NOT MATCHED THEN
    INSERT (product_id, product_data)
    VALUES (pu.product_id, pu.product_data);

-- MERGE with BOOLEAN (23ai)
MERGE INTO feature_flags ff
USING flag_updates fu
ON (ff.flag_id = fu.flag_id)
WHEN MATCHED THEN
    UPDATE SET ff.is_enabled = fu.is_enabled
WHEN NOT MATCHED THEN
    INSERT (flag_id, flag_name, is_enabled)
    VALUES (fu.flag_id, fu.flag_name, fu.is_enabled);

-- MERGE with VECTOR datatype (23ai)
MERGE INTO documents_vector dv
USING document_embeddings de
ON (dv.doc_id = de.doc_id)
WHEN MATCHED THEN
    UPDATE SET dv.embedding = de.embedding
WHEN NOT MATCHED THEN
    INSERT (doc_id, title, embedding)
    VALUES (de.doc_id, de.title, de.embedding);

-- MERGE with object type
MERGE INTO customers c
USING customer_updates cu
ON (c.customer_id = cu.customer_id)
WHEN MATCHED THEN
    UPDATE SET c.address = cu.address
WHEN NOT MATCHED THEN
    INSERT (customer_id, customer_name, address)
    VALUES (cu.customer_id, cu.customer_name, cu.address);

-- MERGE with nested table
MERGE INTO departments d
USING department_updates du
ON (d.department_id = du.department_id)
WHEN MATCHED THEN
    UPDATE SET d.employee_list = du.employee_list;

-- MERGE with hint
MERGE /*+ USE_HASH(e u) */ INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = u.salary;

-- MERGE with parallel hint
MERGE /*+ PARALLEL(employees, 4) */ INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = u.salary;

-- MERGE with multiple hints
MERGE /*+ APPEND USE_HASH(e u) PARALLEL(e, 4) */ INTO employees e
USING employee_updates u
ON (e.employee_id = u.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = u.salary
WHEN NOT MATCHED THEN
    INSERT (employee_id, first_name, salary)
    VALUES (u.employee_id, u.first_name, u.salary);
