-- DROP VIEW statement variations
-- Tests DROP VIEW with various options

-- Basic DROP VIEW
DROP VIEW emp_view;

-- DROP VIEW with CASCADE CONSTRAINTS
DROP VIEW emp_dept_view CASCADE CONSTRAINTS;

-- DROP VIEW IF EXISTS (not standard Oracle, but test anyway)
-- Oracle doesn't support IF EXISTS natively, but some tools add it
-- Standard Oracle approach is to handle exceptions in PL/SQL

-- Drop view without checking existence (will error if doesn't exist)
DROP VIEW non_existent_view;

-- DROP VIEW for read-only view
DROP VIEW readonly_emp_view;

-- DROP VIEW for view with CHECK OPTION
DROP VIEW checked_emp_view;

-- DROP VIEW for complex view with joins
DROP VIEW complex_join_view;

-- DROP VIEW for view with aggregations
DROP VIEW aggregated_view;

-- DROP VIEW for view with analytic functions
DROP VIEW analytic_view;

-- DROP VIEW for view with UNION
DROP VIEW union_view;

-- DROP VIEW for hierarchical view
DROP VIEW hierarchy_view;

-- DROP VIEW with schema qualification
DROP VIEW hr.employee_view;

-- DROP multiple views (requires multiple statements)
DROP VIEW view1;
DROP VIEW view2;
DROP VIEW view3;

-- DROP VIEW that has dependent objects (with CASCADE CONSTRAINTS)
DROP VIEW parent_view CASCADE CONSTRAINTS;

-- DROP VIEW created with FORCE option
DROP VIEW force_created_view;

-- DROP editioning view (11g R2+)
DROP VIEW editioning_view;

-- DROP noneditionable view (11g R2+)
DROP VIEW noneditionable_view;

-- Drop view with PIVOT
DROP VIEW pivoted_view;

-- Drop view with UNPIVOT
DROP VIEW unpivoted_view;

-- Drop view with CTE
DROP VIEW cte_view;

-- Drop view with LATERAL
DROP VIEW lateral_view;

-- Drop view with JSON functions
DROP VIEW json_view;

-- Drop view with XMLTABLE
DROP VIEW xml_view;

-- Drop view with window functions
DROP VIEW windowed_view;

-- Drop view with LISTAGG
DROP VIEW listagg_view;

-- Drop materialized view (different syntax)
DROP MATERIALIZED VIEW mv_emp_summary;

-- Drop materialized view with preserve table
DROP MATERIALIZED VIEW mv_dept_stats PRESERVE TABLE;

-- PL/SQL block to drop view if exists
BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW emp_view';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN  -- ORA-00942: table or view does not exist
            RAISE;
        END IF;
END;
/

-- PL/SQL block to drop view with CASCADE CONSTRAINTS if exists
BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW emp_dept_view CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

-- Drop view and ignore error if it doesn't exist
DECLARE
    view_not_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(view_not_exists, -942);
BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW my_view';
EXCEPTION
    WHEN view_not_exists THEN
        NULL; -- Ignore error
END;
/

-- Drop all views for a specific pattern (requires dynamic SQL)
BEGIN
    FOR view_rec IN (
        SELECT view_name
        FROM user_views
        WHERE view_name LIKE 'TEMP_%'
    ) LOOP
        EXECUTE IMMEDIATE 'DROP VIEW ' || view_rec.view_name;
    END LOOP;
END;
/

-- Drop view with CASCADE if it has constraints
BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW constrained_view CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- Drop view and all dependent objects
BEGIN
    FOR rec IN (
        SELECT object_name, object_type
        FROM user_objects
        WHERE object_name = 'MY_VIEW'
    ) LOOP
        IF rec.object_type = 'VIEW' THEN
            EXECUTE IMMEDIATE 'DROP VIEW ' || rec.object_name || ' CASCADE CONSTRAINTS';
        END IF;
    END LOOP;
END;
/

-- Drop view from different schema (requires privileges)
DROP VIEW other_schema.their_view;

-- Drop view cascade constraints from different schema
DROP VIEW other_schema.constrained_view CASCADE CONSTRAINTS;
