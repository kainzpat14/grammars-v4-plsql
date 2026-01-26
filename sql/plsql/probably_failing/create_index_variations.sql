-- CREATE INDEX statement variations
-- Tests CREATE INDEX with various types and options

-- Basic CREATE INDEX
CREATE INDEX emp_name_idx ON employees(last_name);

-- CREATE INDEX on multiple columns (composite index)
CREATE INDEX emp_name_dept_idx ON employees(last_name, first_name, department_id);

-- CREATE UNIQUE INDEX
CREATE UNIQUE INDEX emp_email_idx ON employees(email);

-- CREATE INDEX with schema qualification
CREATE INDEX hr.emp_salary_idx ON hr.employees(salary);

-- CREATE INDEX with ASC (ascending - default)
CREATE INDEX emp_salary_asc_idx ON employees(salary ASC);

-- CREATE INDEX with DESC (descending)
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

-- CREATE INDEX with mixed ASC/DESC
CREATE INDEX emp_dept_sal_idx ON employees(department_id ASC, salary DESC);

-- CREATE INDEX with TABLESPACE
CREATE INDEX emp_hire_date_idx ON employees(hire_date)
TABLESPACE users;

-- CREATE INDEX with STORAGE clause
CREATE INDEX emp_large_idx ON employees(employee_id)
STORAGE (INITIAL 1M NEXT 1M PCTINCREASE 0);

-- CREATE INDEX with PCTFREE
CREATE INDEX emp_idx_pctfree ON employees(employee_id)
PCTFREE 10;

-- CREATE INDEX with INITRANS
CREATE INDEX emp_idx_trans ON employees(employee_id)
INITRANS 2;

-- CREATE INDEX with MAXTRANS
CREATE INDEX emp_idx_maxtrans ON employees(employee_id)
MAXTRANS 255;

-- CREATE INDEX with LOGGING
CREATE INDEX emp_idx_logging ON employees(employee_id)
LOGGING;

-- CREATE INDEX with NOLOGGING
CREATE INDEX emp_idx_nologging ON employees(employee_id)
NOLOGGING;

-- CREATE INDEX with COMPUTE STATISTICS (deprecated but still used)
CREATE INDEX emp_idx_stats ON employees(employee_id)
COMPUTE STATISTICS;

-- CREATE INDEX with COMPRESS
CREATE INDEX emp_compressed_idx ON employees(department_id, job_id)
COMPRESS 1;

-- CREATE INDEX with COMPRESS advanced
CREATE INDEX emp_compressed_adv_idx ON employees(department_id, job_id, salary)
COMPRESS 2;

-- CREATE INDEX with NOCOMPRESS
CREATE INDEX emp_nocompress_idx ON employees(employee_id)
NOCOMPRESS;

-- CREATE INDEX ONLINE (allows DML during index creation)
CREATE INDEX emp_online_idx ON employees(salary)
ONLINE;

-- CREATE INDEX with PARALLEL
CREATE INDEX emp_parallel_idx ON employees(hire_date)
PARALLEL 4;

-- CREATE INDEX with NOPARALLEL
CREATE INDEX emp_noparallel_idx ON employees(commission_pct)
NOPARALLEL;

-- CREATE INDEX with REVERSE
CREATE INDEX emp_reverse_idx ON employees(employee_id)
REVERSE;

-- CREATE BITMAP INDEX
CREATE BITMAP INDEX emp_dept_bitmap_idx ON employees(department_id);

-- CREATE BITMAP INDEX on multiple columns
CREATE BITMAP INDEX emp_job_dept_bitmap_idx ON employees(job_id, department_id);

-- CREATE BITMAP INDEX with NOLOGGING
CREATE BITMAP INDEX emp_status_bitmap_idx ON employees(status)
NOLOGGING;

-- CREATE function-based index (FBI)
CREATE INDEX emp_upper_name_idx ON employees(UPPER(last_name));

-- CREATE function-based index with multiple functions
CREATE INDEX emp_name_func_idx ON employees(UPPER(last_name), UPPER(first_name));

-- CREATE function-based index with expression
CREATE INDEX emp_annual_salary_idx ON employees(salary * 12);

-- CREATE function-based index with complex expression
CREATE INDEX emp_total_comp_idx ON employees(salary + NVL(commission_pct * salary, 0));

-- CREATE function-based index with SUBSTR
CREATE INDEX emp_last_name_prefix_idx ON employees(SUBSTR(last_name, 1, 3));

-- CREATE function-based index with TO_CHAR
CREATE INDEX emp_hire_year_idx ON employees(TO_CHAR(hire_date, 'YYYY'));

-- CREATE function-based index with TRUNC
CREATE INDEX emp_hire_date_trunc_idx ON employees(TRUNC(hire_date));

-- CREATE function-based index with CASE
CREATE INDEX emp_salary_category_idx ON employees(
    CASE
        WHEN salary > 10000 THEN 'HIGH'
        WHEN salary > 5000 THEN 'MEDIUM'
        ELSE 'LOW'
    END
);

-- CREATE function-based index with NVL
CREATE INDEX emp_commission_nvl_idx ON employees(NVL(commission_pct, 0));

-- CREATE function-based index with COALESCE
CREATE INDEX emp_contact_idx ON employees(COALESCE(phone_number, mobile_number, 'N/A'));

-- CREATE domain index (for text search, spatial, etc.)
CREATE INDEX emp_resume_text_idx ON employees(resume)
INDEXTYPE IS CTXSYS.CONTEXT;

-- CREATE domain index with parameters
CREATE INDEX product_desc_text_idx ON products(description)
INDEXTYPE IS CTXSYS.CONTEXT
PARAMETERS ('LEXER my_lexer WORDLIST my_wordlist');

-- CREATE spatial index (Oracle Spatial)
CREATE INDEX location_spatial_idx ON locations(geometry)
INDEXTYPE IS MDSYS.SPATIAL_INDEX;

-- CREATE spatial index with parameters
CREATE INDEX store_location_idx ON stores(location)
INDEXTYPE IS MDSYS.SPATIAL_INDEX
PARAMETERS ('sdo_indx_dims=2 layer_gtype=POINT');

-- CREATE XML index (11g+)
CREATE INDEX xml_doc_idx ON xml_documents(xml_data)
INDEXTYPE IS XDB.XMLINDEX;

-- CREATE XML index with parameters
CREATE INDEX xml_structured_idx ON xml_documents(xml_data)
INDEXTYPE IS XDB.XMLINDEX
PARAMETERS ('PATHS (INCLUDE (/root/element))');

-- CREATE JSON search index (12c+)
CREATE SEARCH INDEX products_json_idx ON products(product_data)
FOR JSON;

-- CREATE index on virtual column
CREATE INDEX emp_annual_sal_virt_idx ON employees(annual_salary);

-- CREATE index with LOCAL keyword (for partitioned tables)
CREATE INDEX sales_local_idx ON sales(sale_date)
LOCAL;

-- CREATE index with GLOBAL keyword (for partitioned tables)
CREATE INDEX sales_global_idx ON sales(product_id)
GLOBAL;

-- CREATE partitioned index
CREATE INDEX sales_part_idx ON sales(sale_date)
GLOBAL PARTITION BY RANGE (sale_date)
(
    PARTITION sales_2023 VALUES LESS THAN (TO_DATE('2024-01-01', 'YYYY-MM-DD')),
    PARTITION sales_2024 VALUES LESS THAN (TO_DATE('2025-01-01', 'YYYY-MM-DD'))
);

-- CREATE hash partitioned index
CREATE INDEX emp_hash_idx ON employees(employee_id)
GLOBAL PARTITION BY HASH (employee_id)
PARTITIONS 4;

-- CREATE index on partitioned table with LOCAL
CREATE INDEX sales_local_part_idx ON sales_partitioned(product_id)
LOCAL;

-- CREATE index with UNUSABLE
CREATE INDEX emp_unusable_idx ON employees(manager_id)
UNUSABLE;

-- CREATE index with INVISIBLE (11g+)
CREATE INDEX emp_invisible_idx ON employees(phone_number)
INVISIBLE;

-- CREATE index with VISIBLE (default)
CREATE INDEX emp_visible_idx ON employees(fax_number)
VISIBLE;

-- CREATE index with key compression
CREATE INDEX emp_dept_job_comp_idx ON employees(department_id, job_id, salary)
COMPRESS 2;

-- CREATE index with advanced compression (12c+)
CREATE INDEX emp_advanced_comp_idx ON employees(department_id, job_id)
COMPRESS ADVANCED LOW;

-- CREATE index with advanced compression HIGH
CREATE INDEX emp_comp_high_idx ON employees(last_name, first_name)
COMPRESS ADVANCED HIGH;

-- CREATE index-organized table (IOT) with index
CREATE TABLE iot_employees (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50)
) ORGANIZATION INDEX;

-- CREATE index on nested table (invalid syntax in Oracle Free 23)
-- Correct syntax would require a storage table for the nested table
-- CREATE INDEX dept_emp_nested_idx ON TABLE(SELECT employee_list FROM departments);

-- CREATE index with NOSORT (data already sorted)
CREATE INDEX emp_sorted_idx ON employees(employee_id)
NOSORT;

-- CREATE index with ASC NULLS FIRST (NULLS FIRST/LAST not supported in Oracle Free 23 index creation)
-- CREATE INDEX emp_comm_nulls_first_idx ON employees(commission_pct ASC NULLS FIRST);

-- CREATE index with DESC NULLS LAST (NULLS FIRST/LAST not supported in Oracle Free 23 index creation)
-- CREATE INDEX emp_mgr_nulls_last_idx ON employees(manager_id DESC NULLS LAST);

-- CREATE index with multiple null ordering (NULLS FIRST/LAST not supported in Oracle Free 23 index creation)
-- CREATE INDEX emp_mixed_nulls_idx ON employees(
--     department_id ASC NULLS FIRST,
--     salary DESC NULLS LAST
-- );

-- CREATE unique function-based index
CREATE UNIQUE INDEX emp_unique_upper_email_idx ON employees(UPPER(email));

-- CREATE bitmap join index
CREATE BITMAP INDEX sales_customer_bji ON sales(customers.country_id)
FROM sales, customers
WHERE sales.customer_id = customers.customer_id;

-- CREATE bitmap join index with multiple tables
CREATE BITMAP INDEX order_complex_bji ON order_items(products.category_id)
FROM order_items, orders, products
WHERE order_items.order_id = orders.order_id
  AND order_items.product_id = products.product_id;

-- CREATE index with DEFERRED invalidation (12c+)
CREATE INDEX emp_deferred_idx ON employees(department_id)
DEFERRED INVALIDATION;

-- CREATE index with IMMEDIATE invalidation
CREATE INDEX emp_immediate_idx ON employees(job_id)
DEFERRED INVALIDATION;

-- CREATE index with IN_MEMORY storage
CREATE INDEX emp_inmemory_idx ON employees(salary)
STORAGE(BUFFER_POOL KEEP);

-- CREATE index with specific buffer pool
CREATE INDEX emp_recycle_idx ON employees(last_activity_date)
STORAGE(BUFFER_POOL RECYCLE);

-- CREATE index with FREELIST GROUPS
CREATE INDEX emp_freelist_idx ON employees(hire_date)
STORAGE(FREELIST GROUPS 4);

-- CREATE index with FREELISTS
CREATE INDEX emp_freelists_idx ON employees(termination_date)
STORAGE(FREELISTS 10);

-- CREATE index on CLOB column using function
CREATE INDEX doc_clob_substr_idx ON documents(DBMS_LOB.SUBSTR(content, 100, 1));

-- CREATE index on BLOB column is not directly supported
-- But can index extracted attributes
-- CREATE INDEX image_size_idx ON images(DBMS_LOB.GETLENGTH(image_data));

-- CREATE index with multiple tablespaces (for partitioned)
CREATE INDEX sales_multi_ts_idx ON sales(sale_date)
LOCAL
(
    PARTITION p1 TABLESPACE ts1,
    PARTITION p2 TABLESPACE ts2
);

-- CREATE index with INDEXING ON (for partitioned tables - 12c+)
CREATE INDEX sales_indexing_on_idx ON sales(product_id)
LOCAL INDEXING ON;

-- CREATE index with INDEXING OFF
CREATE INDEX sales_indexing_off_idx ON sales(customer_id)
LOCAL INDEXING OFF;

-- CREATE partial index (using function-based with filter)
CREATE INDEX emp_high_salary_idx ON employees(employee_id)
WHERE salary > 10000;  -- Not standard Oracle, but some versions support

-- CREATE index with key compression for bitmap (not supported in Oracle Free 23)
-- CREATE BITMAP INDEX emp_dept_compressed_bm_idx ON employees(department_id)
-- COMPRESS;

-- CREATE index on XMLType column using XMLIndex
CREATE INDEX xml_orders_idx ON xml_orders(order_xml)
INDEXTYPE IS XDB.XMLINDEX
PARAMETERS ('GROUP order_group
             XMLTABLE orders_tab
             ''/orders/order''
             COLUMNS
               order_id NUMBER PATH ''@id'',
               customer_id NUMBER PATH ''customer_id''');

-- CREATE index on virtual column with function
ALTER TABLE employees ADD (annual_salary NUMBER GENERATED ALWAYS AS (salary * 12) VIRTUAL);
CREATE INDEX emp_virtual_annual_idx ON employees(annual_salary);

-- CREATE descending index for optimization
CREATE INDEX emp_salary_desc_opt_idx ON employees(salary DESC, hire_date DESC);

-- CREATE index with multiple compression levels
CREATE INDEX emp_selective_comp_idx ON employees(
    department_id,  -- compressed
    job_id,         -- compressed
    salary          -- not compressed
)
COMPRESS 2;

-- CREATE index ONLINE with PARALLEL
CREATE INDEX emp_online_parallel_idx ON employees(last_name)
ONLINE PARALLEL 4;

-- CREATE index with NOLOGGING and PARALLEL
CREATE INDEX emp_fast_load_idx ON employees(email)
NOLOGGING PARALLEL 8;

-- CREATE index with all options combined
CREATE INDEX emp_comprehensive_idx ON employees(department_id, job_id, salary)
TABLESPACE index_tablespace
PCTFREE 5
INITRANS 4
STORAGE (INITIAL 1M NEXT 1M PCTINCREASE 0)
COMPRESS 2
NOLOGGING
PARALLEL 4
ONLINE;

-- CREATE index for interval partitioned table
CREATE INDEX interval_sales_idx ON interval_sales(sale_date)
LOCAL;

-- CREATE index for reference partitioned table
CREATE INDEX ref_part_idx ON child_table(parent_id)
LOCAL;

-- CREATE index on system partitioned table
CREATE INDEX sys_part_idx ON system_part_table(id)
LOCAL;

-- CREATE index with SECUREFILE LOB
CREATE INDEX lob_secure_idx ON documents(
    DBMS_CRYPTO.HASH(content, 2)  -- Hash of LOB content
);

-- CREATE fulltext index on concatenated columns
CREATE INDEX emp_fullname_idx ON employees(first_name || ' ' || last_name);

-- CREATE index on DATE with time component
CREATE INDEX emp_hire_datetime_idx ON employees(hire_date);

-- CREATE index on TIMESTAMP
CREATE INDEX event_timestamp_idx ON events(event_timestamp);

-- CREATE index on TIMESTAMP WITH TIME ZONE
CREATE INDEX event_tz_idx ON events(event_timestamp_tz);

-- CREATE index on INTERVAL
CREATE INDEX task_duration_idx ON tasks(end_time - start_time);

-- CREATE index for case-insensitive search
CREATE INDEX emp_name_ci_idx ON employees(NLSSORT(last_name, 'NLS_SORT=BINARY_CI'));

-- CREATE index with linguistic sort
CREATE INDEX emp_name_linguistic_idx ON employees(
    NLSSORT(last_name, 'NLS_SORT=FRENCH')
);

-- CREATE index on ROWID (pseudo-column)
-- Not typically needed, but for completeness
-- CREATE INDEX emp_rowid_idx ON employees(ROWID);

-- CREATE index with DEGREE for parallelism
CREATE INDEX emp_degree_idx ON employees(salary)
PARALLEL (DEGREE 4);

-- CREATE index with INSTANCES for parallel server
CREATE INDEX emp_instances_idx ON employees(hire_date)
PARALLEL (DEGREE 4 INSTANCES 2);

-- CREATE index organized differently (MONITORING USAGE not supported in Oracle Free 23)
-- CREATE INDEX emp_monitored_idx ON employees(last_modified_date)
-- MONITORING USAGE;

-- CREATE index with no monitoring
CREATE INDEX emp_nomonitor_idx ON employees(created_date)
NOMONITORING USAGE;
