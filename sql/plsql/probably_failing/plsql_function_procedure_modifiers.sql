-- Function and procedure modifiers examples
-- Tests DETERMINISTIC, RESULT_CACHE, PARALLEL_ENABLE, PIPELINED, etc.

-- DETERMINISTIC function
CREATE OR REPLACE FUNCTION calculate_tax(p_amount NUMBER) RETURN NUMBER
DETERMINISTIC
IS
BEGIN
    RETURN p_amount * 0.15;
END;
/

-- RESULT_CACHE function
CREATE OR REPLACE FUNCTION get_tax_rate(p_country_code VARCHAR2) RETURN NUMBER
RESULT_CACHE
IS
    v_rate NUMBER;
BEGIN
    SELECT tax_rate INTO v_rate
    FROM tax_rates
    WHERE country_code = p_country_code;
    RETURN v_rate;
END;
/

-- RESULT_CACHE with RELIES_ON clause
CREATE OR REPLACE FUNCTION get_employee_count(p_dept_id NUMBER) RETURN NUMBER
RESULT_CACHE RELIES_ON (employees)
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM employees
    WHERE department_id = p_dept_id;
    RETURN v_count;
END;
/

-- PARALLEL_ENABLE function
CREATE OR REPLACE FUNCTION calculate_bonus(p_salary NUMBER) RETURN NUMBER
PARALLEL_ENABLE
DETERMINISTIC
IS
BEGIN
    RETURN p_salary * 0.1;
END;
/

-- PIPELINED function
CREATE OR REPLACE TYPE num_table AS TABLE OF NUMBER;
/

CREATE OR REPLACE FUNCTION generate_numbers(p_max NUMBER) RETURN num_table
PIPELINED
IS
BEGIN
    FOR i IN 1..p_max LOOP
        PIPE ROW(i);
    END LOOP;
    RETURN;
END;
/

-- PIPELINED with PARALLEL_ENABLE
CREATE OR REPLACE FUNCTION parallel_generate(p_max NUMBER) RETURN num_table
PIPELINED
PARALLEL_ENABLE
IS
BEGIN
    FOR i IN 1..p_max LOOP
        PIPE ROW(i * i);
    END LOOP;
    RETURN;
END;
/

-- PIPELINED with PARALLEL_ENABLE and PARTITION BY
CREATE OR REPLACE TYPE emp_row AS OBJECT (
    emp_id NUMBER,
    emp_name VARCHAR2(100),
    department_id NUMBER
);
/

CREATE OR REPLACE TYPE emp_table AS TABLE OF emp_row;
/

CREATE OR REPLACE FUNCTION partition_employees(p_cursor SYS_REFCURSOR)
    RETURN emp_table
    PIPELINED
    PARALLEL_ENABLE (PARTITION p_cursor BY HASH (department_id))
IS
    v_emp emp_row;
BEGIN
    LOOP
        FETCH p_cursor INTO v_emp;
        EXIT WHEN p_cursor%NOTFOUND;
        PIPE ROW(v_emp);
    END LOOP;
    CLOSE p_cursor;
    RETURN;
END;
/

-- PIPELINED with PARTITION BY ANY
CREATE OR REPLACE FUNCTION partition_any(p_cursor SYS_REFCURSOR)
    RETURN emp_table
    PIPELINED
    PARALLEL_ENABLE (PARTITION p_cursor BY ANY)
IS
    v_emp emp_row;
BEGIN
    LOOP
        FETCH p_cursor INTO v_emp;
        EXIT WHEN p_cursor%NOTFOUND;
        v_emp.emp_name := UPPER(v_emp.emp_name);
        PIPE ROW(v_emp);
    END LOOP;
    RETURN;
END;
/

-- PIPELINED with PARTITION BY RANGE
CREATE OR REPLACE FUNCTION partition_range(p_cursor SYS_REFCURSOR)
    RETURN emp_table
    PIPELINED
    PARALLEL_ENABLE (PARTITION p_cursor BY RANGE (emp_id))
IS
    v_emp emp_row;
BEGIN
    LOOP
        FETCH p_cursor INTO v_emp;
        EXIT WHEN p_cursor%NOTFOUND;
        PIPE ROW(v_emp);
    END LOOP;
    RETURN;
END;
/

-- PIPELINED with ORDER BY clause
CREATE OR REPLACE FUNCTION ordered_pipeline(p_cursor SYS_REFCURSOR)
    RETURN emp_table
    PIPELINED
    PARALLEL_ENABLE (PARTITION p_cursor BY HASH (department_id))
    ORDER p_cursor BY (emp_id)
IS
    v_emp emp_row;
BEGIN
    LOOP
        FETCH p_cursor INTO v_emp;
        EXIT WHEN p_cursor%NOTFOUND;
        PIPE ROW(v_emp);
    END LOOP;
    RETURN;
END;
/

-- PIPELINED with CLUSTER BY clause
CREATE OR REPLACE FUNCTION clustered_pipeline(p_cursor SYS_REFCURSOR)
    RETURN emp_table
    PIPELINED
    PARALLEL_ENABLE (PARTITION p_cursor BY HASH (department_id))
    CLUSTER p_cursor BY (department_id, emp_id)
IS
    v_emp emp_row;
BEGIN
    LOOP
        FETCH p_cursor INTO v_emp;
        EXIT WHEN p_cursor%NOTFOUND;
        PIPE ROW(v_emp);
    END LOOP;
    RETURN;
END;
/

-- Function with multiple modifiers
CREATE OR REPLACE FUNCTION multi_modifier_func(p_value NUMBER) RETURN NUMBER
DETERMINISTIC
PARALLEL_ENABLE
RESULT_CACHE
IS
BEGIN
    RETURN p_value * p_value;
END;
/

-- AUTHID CURRENT_USER
CREATE OR REPLACE FUNCTION invoker_rights_func RETURN VARCHAR2
AUTHID CURRENT_USER
IS
BEGIN
    RETURN USER;
END;
/

-- AUTHID DEFINER (default, but explicit)
CREATE OR REPLACE FUNCTION definer_rights_func RETURN VARCHAR2
AUTHID DEFINER
IS
BEGIN
    RETURN USER;
END;
/

-- Function with ACCESSIBLE BY clause (18c+)
CREATE OR REPLACE PACKAGE pkg_restricted IS
    FUNCTION private_func RETURN NUMBER
    ACCESSIBLE BY (PACKAGE pkg_allowed, PROCEDURE allowed_proc);
END;
/

CREATE OR REPLACE PACKAGE BODY pkg_restricted IS
    FUNCTION private_func RETURN NUMBER IS
    BEGIN
        RETURN 100;
    END;
END;
/

-- Procedure with DEFAULT parameters and NO COPY hint
CREATE OR REPLACE PROCEDURE process_collection(
    p_data IN OUT NOCOPY num_table,
    p_multiplier IN NUMBER DEFAULT 1,
    p_debug IN BOOLEAN DEFAULT FALSE
) IS
BEGIN
    FOR i IN 1..p_data.COUNT LOOP
        p_data(i) := p_data(i) * p_multiplier;
    END LOOP;
END;
/

-- Function RETURN with %TYPE and %ROWTYPE
CREATE OR REPLACE FUNCTION get_employee(p_emp_id NUMBER)
    RETURN employees%ROWTYPE
IS
    v_emp employees%ROWTYPE;
BEGIN
    SELECT * INTO v_emp
    FROM employees
    WHERE employee_id = p_emp_id;
    RETURN v_emp;
END;
/

-- Function with collection return type
CREATE OR REPLACE FUNCTION get_all_ids RETURN num_table
IS
    v_ids num_table;
BEGIN
    SELECT employee_id BULK COLLECT INTO v_ids FROM employees;
    RETURN v_ids;
END;
/

-- Polymorphic table function (18c+)
CREATE OR REPLACE PACKAGE ptf_package AS
    FUNCTION describe_function(
        tab IN OUT DBMS_TF.TABLE_T
    ) RETURN DBMS_TF.DESCRIBE_T;

    FUNCTION execute_function(
        tab IN OUT DBMS_TF.TABLE_T
    ) RETURN DBMS_TF.ROW_SET_T
    PIPELINED
    ROW POLYMORPHIC
    USING ptf_package;
END;
/

-- Function with SQL_MACRO (21c+)
CREATE OR REPLACE FUNCTION active_employees RETURN VARCHAR2 SQL_MACRO(TABLE) IS
BEGIN
    RETURN 'SELECT * FROM employees WHERE status = ''ACTIVE''';
END;
/

-- Scalar SQL_MACRO
CREATE OR REPLACE FUNCTION double_value(p_val NUMBER) RETURN VARCHAR2 SQL_MACRO(SCALAR) IS
BEGIN
    RETURN 'p_val * 2';
END;
/

-- Function with aggregate clause (custom aggregate)
CREATE OR REPLACE TYPE custom_avg AS OBJECT (
    total NUMBER,
    count NUMBER,

    STATIC FUNCTION ODCIAggregateInitialize(sctx IN OUT custom_avg)
        RETURN NUMBER,

    MEMBER FUNCTION ODCIAggregateIterate(self IN OUT custom_avg, value IN NUMBER)
        RETURN NUMBER,

    MEMBER FUNCTION ODCIAggregateTerminate(self IN custom_avg, returnValue OUT NUMBER, flags IN NUMBER)
        RETURN NUMBER,

    MEMBER FUNCTION ODCIAggregateMerge(self IN OUT custom_avg, ctx2 IN custom_avg)
        RETURN NUMBER
);
/

-- DETERMINISTIC combined with RESULT_CACHE
CREATE OR REPLACE FUNCTION cached_deterministic(p_value NUMBER) RETURN NUMBER
DETERMINISTIC
RESULT_CACHE
IS
BEGIN
    -- Expensive calculation
    DBMS_LOCK.SLEEP(0.1);
    RETURN p_value * p_value;
END;
/
