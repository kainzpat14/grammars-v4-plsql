-- INSERT statement basic variations
-- Tests fundamental INSERT syntax

-- Basic INSERT with VALUES
INSERT INTO employees (employee_id, first_name, last_name, email, hire_date)
VALUES (1000, 'John', 'Doe', 'jdoe@example.com', SYSDATE);

-- INSERT without column list (implicit - all columns)
INSERT INTO departments
VALUES (300, 'New Department', 100, 1700);

-- INSERT with subset of columns
INSERT INTO employees (employee_id, last_name, email, hire_date)
VALUES (1001, 'Smith', 'smith@example.com', SYSDATE);

-- INSERT with NULL values
INSERT INTO employees (employee_id, last_name, email, hire_date, manager_id)
VALUES (1002, 'Johnson', 'johnson@example.com', SYSDATE, NULL);

-- INSERT with expression in VALUES
INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, salary)
VALUES (1003, 'Jane', 'Wilson', LOWER('JWILSON@EXAMPLE.COM'), SYSDATE, 5000 * 1.1);

-- INSERT with function calls
INSERT INTO employees (employee_id, first_name, last_name, email, hire_date)
VALUES (1004, INITCAP('alice'), UPPER('brown'), 'abrown@example.com', TRUNC(SYSDATE));

-- INSERT with subquery result
INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, salary)
VALUES (1005, 'Bob', 'Davis', 'bdavis@example.com', SYSDATE,
        (SELECT AVG(salary) FROM employees WHERE department_id = 50));

-- INSERT with CASE expression
INSERT INTO employee_grades (employee_id, grade)
VALUES (1006, CASE WHEN 85 >= 90 THEN 'A'
                   WHEN 85 >= 80 THEN 'B'
                   ELSE 'C' END);

-- INSERT with concatenation
INSERT INTO employees (employee_id, first_name, last_name, full_name)
VALUES (1007, 'Charlie', 'Miller', 'Charlie' || ' ' || 'Miller');

-- INSERT multiple rows using INSERT ALL (multi-table insert)
INSERT ALL
    INTO employees (employee_id, first_name, last_name) VALUES (2001, 'Tom', 'Anderson')
    INTO employees (employee_id, first_name, last_name) VALUES (2002, 'Sarah', 'Taylor')
    INTO employees (employee_id, first_name, last_name) VALUES (2003, 'Mike', 'Thomas')
SELECT * FROM DUAL;

-- INSERT with TO_DATE
INSERT INTO employees (employee_id, first_name, hire_date)
VALUES (1008, 'David', TO_DATE('2024-01-15', 'YYYY-MM-DD'));

-- INSERT with TO_TIMESTAMP
INSERT INTO events (event_id, event_name, event_timestamp)
VALUES (1, 'Meeting', TO_TIMESTAMP('2024-01-15 14:30:00', 'YYYY-MM-DD HH24:MI:SS'));

-- INSERT with sequence.NEXTVAL
INSERT INTO employees (employee_id, first_name, last_name)
VALUES (emp_seq.NEXTVAL, 'Emily', 'Moore');

-- INSERT with DEFAULT keyword
INSERT INTO employees (employee_id, first_name, last_name, salary, commission_pct)
VALUES (1009, 'Frank', 'White', DEFAULT, DEFAULT);

-- INSERT with column default values
INSERT INTO employees (employee_id, first_name, last_name)
VALUES (1010, 'Grace', 'Martin');

-- INSERT ALL with different tables
INSERT ALL
    INTO employees (employee_id, first_name) VALUES (3001, 'Alex')
    INTO departments (department_id, department_name) VALUES (400, 'IT Support')
SELECT * FROM DUAL;

-- INSERT with SYS_GUID()
INSERT INTO transactions (transaction_id, transaction_uuid, amount)
VALUES (1, SYS_GUID(), 100.50);

-- INSERT with SYSTIMESTAMP
INSERT INTO audit_log (log_id, log_timestamp, action)
VALUES (1, SYSTIMESTAMP, 'User Login');

-- INSERT with USER function
INSERT INTO audit_log (log_id, username, action)
VALUES (2, USER, 'Data Update');

-- INSERT with boolean literal (23ai)
INSERT INTO feature_flags (flag_id, flag_name, is_enabled)
VALUES (1, 'NEW_FEATURE', TRUE);

-- INSERT with JSON value (23ai)
INSERT INTO documents (doc_id, doc_data)
VALUES (1, JSON('{"title": "Document 1", "status": "draft"}'));

-- INSERT with VECTOR value (23ai)
INSERT INTO embeddings (id, vector_data)
VALUES (1, TO_VECTOR('[0.1, 0.2, 0.3]'));

-- INSERT with nested table collection
INSERT INTO orders (order_id, line_items)
VALUES (1, line_item_table(
    line_item_type(1, 'Product A', 10),
    line_item_type(2, 'Product B', 20)
));

-- INSERT with VARRAY collection
INSERT INTO schedules (schedule_id, time_slots)
VALUES (1, time_slot_array(
    TO_TIMESTAMP('09:00', 'HH24:MI'),
    TO_TIMESTAMP('10:00', 'HH24:MI'),
    TO_TIMESTAMP('11:00', 'HH24:MI')
));

-- INSERT with object type
INSERT INTO customer_objects VALUES (
    customer_type(1, 'John Doe', address_type('123 Main St', 'New York', '10001'))
);

-- INSERT with REF
INSERT INTO customer_refs
SELECT REF(c) FROM customer_objects c WHERE customer_id = 1;

-- INSERT with TREAT (type casting)
INSERT INTO person_table VALUES (
    TREAT(person_type(1, 'Alice') AS employee_type)
);

-- INSERT with XMLTYPE
INSERT INTO xml_documents (doc_id, xml_content)
VALUES (1, XMLTYPE('<document><title>Test</title></document>'));

-- INSERT with CLOB
INSERT INTO large_texts (text_id, content)
VALUES (1, TO_CLOB('This is a large text content...'));

-- INSERT with BLOB
INSERT INTO binary_data (data_id, content)
VALUES (1, HEXTORAW('DEADBEEF'));

-- INSERT with interval
INSERT INTO schedules (schedule_id, duration)
VALUES (2, INTERVAL '2' HOUR);

INSERT INTO schedules (schedule_id, period)
VALUES (3, INTERVAL '30' DAY);

-- INSERT with qualified expression (18c+)
INSERT INTO employees (employee_id, emp_record)
VALUES (1011, employee_record_type(first_name => 'Helen', last_name => 'Garcia'));

-- INSERT with DECODE
INSERT INTO employee_status (employee_id, status_code, status_name)
VALUES (1012, 'A', DECODE('A', 'A', 'Active', 'I', 'Inactive', 'Unknown'));

-- INSERT with NVL
INSERT INTO employees (employee_id, first_name, commission_pct)
VALUES (1013, 'Ian', NVL(NULL, 0));

-- INSERT with COALESCE
INSERT INTO employees (employee_id, salary)
VALUES (1014, COALESCE(NULL, NULL, 5000));

-- INSERT with CAST
INSERT INTO employees (employee_id, hire_date)
VALUES (1015, CAST('2024-01-15' AS DATE));

-- INSERT with EXTRACT
INSERT INTO date_parts (record_id, year_part, month_part)
VALUES (1, EXTRACT(YEAR FROM SYSDATE), EXTRACT(MONTH FROM SYSDATE));

-- INSERT with GREATEST/LEAST
INSERT INTO ranges (range_id, max_value, min_value)
VALUES (1, GREATEST(10, 20, 30), LEAST(10, 20, 30));

-- INSERT with TRIM
INSERT INTO clean_data (data_id, clean_text)
VALUES (1, TRIM(BOTH ' ' FROM '  text with spaces  '));

-- INSERT with SUBSTR
INSERT INTO abbreviations (abbr_id, short_name)
VALUES (1, SUBSTR('Department', 1, 4));

-- INSERT with REPLACE
INSERT INTO clean_data (data_id, clean_text)
VALUES (2, REPLACE('hello world', 'world', 'universe'));

-- INSERT with TRANSLATE
INSERT INTO encoded_data (data_id, encoded_text)
VALUES (1, TRANSLATE('hello', 'helo', '1234'));

-- INSERT with LPAD/RPAD
INSERT INTO formatted_data (data_id, padded_text)
VALUES (1, LPAD('123', 10, '0'));

-- INSERT with ROUND/TRUNC
INSERT INTO numbers (num_id, rounded, truncated)
VALUES (1, ROUND(123.456, 2), TRUNC(123.456, 1));

-- INSERT with MOD
INSERT INTO calculations (calc_id, remainder)
VALUES (1, MOD(10, 3));

-- INSERT with POWER
INSERT INTO calculations (calc_id, result)
VALUES (2, POWER(2, 10));
