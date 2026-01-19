# PL/SQL Block Syntax Test Cases

This directory contains comprehensive test cases for PL/SQL block syntax, anonymous blocks, procedures, functions, and related features that may not be fully supported by the current grammar.

## Test Files Overview

### plsql_anonymous_blocks_advanced.sql
Tests advanced anonymous block features:
- **Nested blocks with labels** (`<<outer_block>>`, `<<inner_block>>`)
- **BULK COLLECT INTO collections**
- **FORALL with SAVE EXCEPTIONS**
- **Dynamic SQL with EXECUTE IMMEDIATE**
  - USING clause
  - RETURNING clause
  - RETURNING INTO for single rows
- **Qualified expressions** (18c+)
  - Simple qualified expressions: `rec_type(100, 'Name')`
  - Named notation: `rec_type(id => 100, name => 'Name')`
  - Associative array initialization
- **CONTINUE WHEN** statements
- **Conditional compilation** (`$IF $$DEBUG_MODE $THEN`)
- **BOOLEAN datatype** usage (23ai)
- **PRAGMA INLINE** in anonymous blocks
- **MULTISET operations** (UNION, EXCEPT, INTERSECT)
- **Polymorphic table function** calls (18c+)
- **SELECT without FROM** (23ai)
- **JSON operations** with native JSON type (23ai)

### plsql_pragma_directives.sql
Comprehensive PRAGMA directive examples:
- **PRAGMA AUTONOMOUS_TRANSACTION**
  - In procedures
  - In functions
  - In nested procedures
- **PRAGMA EXCEPTION_INIT**
  - With standard Oracle errors
  - With user-defined error codes (-20000 series)
  - Multiple exception mappings
- **PRAGMA SERIALLY_REUSABLE**
  - In package specification
  - In package body
- **PRAGMA INLINE**
  - With 'YES' to force inlining
  - With 'NO' to prevent inlining
  - In nested functions
- **PRAGMA RESTRICT_REFERENCES** (deprecated but valid)
  - Function purity levels: WNDS, WNPS, RNDS, RNPS
  - DEFAULT keyword for package-level restrictions
- **PRAGMA UDF**
  - User-defined function optimization
- **PRAGMA DEPRECATE** (12.2+)
  - With custom deprecation messages
  - For procedures and functions
- **PRAGMA COVERAGE**
  - Marking code as not feasible for testing
- **Multiple pragmas** in single subprogram
- **Conditional compilation** with pragmas

### plsql_function_procedure_modifiers.sql
Function and procedure modifier clauses:
- **DETERMINISTIC**
  - Pure functions with consistent results
- **RESULT_CACHE**
  - Caching function results in SGA
  - RELIES_ON clause for table dependencies
- **PARALLEL_ENABLE**
  - Functions safe for parallel execution
  - Combined with DETERMINISTIC
- **PIPELINED functions**
  - Basic pipelined table functions
  - PARALLEL_ENABLE with partitioning:
    - PARTITION BY HASH
    - PARTITION BY RANGE
    - PARTITION BY ANY
  - ORDER BY clause
  - CLUSTER BY clause
- **AUTHID**
  - CURRENT_USER (invoker rights)
  - DEFINER (definer rights)
- **ACCESSIBLE BY clause** (18c+)
  - Restricting access to specific units
- **NO COPY hint**
  - For IN OUT parameters
- **RETURN %TYPE and %ROWTYPE**
  - Dynamic return types
- **Polymorphic table functions** (18c+)
  - ROW POLYMORPHIC
  - Using DBMS_TF package
- **SQL_MACRO** (21c+)
  - TABLE macros
  - SCALAR macros
- **Custom aggregate functions**
  - ODCI aggregate interface

### plsql_bulk_operations_dynamic_sql.sql
Bulk operations and dynamic SQL:
- **BULK COLLECT**
  - With LIMIT clause
  - Into multiple collections
  - With cursors
  - With dynamic SQL
- **FORALL variations**
  - Basic array DML
  - INDICES OF clause
  - INDICES OF BETWEEN clause
  - VALUES OF clause
  - SAVE EXCEPTIONS error handling
  - Complex DML operations
- **EXECUTE IMMEDIATE**
  - With BULK COLLECT INTO
  - With RETURNING clause
  - With RETURNING BULK COLLECT
  - Multiple USING clauses
  - IN OUT parameters
  - Dynamic PL/SQL blocks
- **OPEN FOR** with dynamic SQL
  - SYS_REFCURSOR usage
  - USING clause
- **DBMS_SQL** package
  - OPEN_CURSOR
  - PARSE
  - BIND_VARIABLE
  - EXECUTE and FETCH
- **Bulk operations with RETURNING**
  - FORALL with RETURNING BULK COLLECT
  - INSERT/UPDATE/DELETE with RETURNING
- **Associative arrays** in bulk operations
  - Sparse arrays
  - DBMS_SQL.NUMBER_TABLE

### plsql_exception_handling_advanced.sql
Advanced exception handling:
- **Custom exceptions**
  - Declaration and raising
  - PRAGMA EXCEPTION_INIT mapping
- **Multiple exception handlers**
  - Specific exceptions first
  - WHEN OTHERS as catch-all
- **RAISE_APPLICATION_ERROR**
  - User-defined error codes (-20000 to -20999)
  - Third parameter (TRUE) to add to error stack
- **Standard Oracle exceptions**
  - NO_DATA_FOUND
  - TOO_MANY_ROWS
  - DUP_VAL_ON_INDEX
  - ZERO_DIVIDE
  - Foreign key violations (-2291)
  - Unique constraints (-1)
  - Check constraints (-2290)
- **Nested exception handling**
  - RAISE to re-raise exceptions
  - Exception propagation between blocks
- **SQLCODE and SQLERRM**
  - Error code and message retrieval
- **UTL_CALL_STACK** (12c+)
  - ERROR_DEPTH and ERROR_MSG
  - DYNAMIC_DEPTH for call stack
  - CONCATENATE_SUBPROGRAM
- **Exception in loops**
  - Local exception handlers in loop body
- **Autonomous transaction exceptions**
  - Independent commit/rollback
- **FORALL with SAVE EXCEPTIONS**
  - SQL%BULK_EXCEPTIONS
  - ERROR_INDEX and ERROR_CODE
- **DBMS_UTILITY formatting**
  - FORMAT_ERROR_STACK
  - FORMAT_ERROR_BACKTRACE
  - FORMAT_CALL_STACK

### plsql_control_structures_advanced.sql
Advanced control flow:
- **CONTINUE statement**
  - In FOR loops
  - In WHILE loops
  - CONTINUE WHEN condition
- **GOTO statement**
  - With labels
  - For error recovery and retry logic
  - Label syntax: `<<label_name>>`
- **CASE expressions**
  - Simple CASE (equality check)
  - Searched CASE (conditional logic)
  - Nested CASE
- **CASE statements** (PL/SQL)
  - Different from CASE expressions
  - Statement-level control flow
- **EXIT WHEN**
  - In named loops
  - Exiting outer loops from inner loops
- **LOOP statement**
  - With EXIT and CONTINUE
  - Infinite loops with controlled exit
- **FOR loop variations**
  - REVERSE keyword
  - Over sparse collections
  - Cursor FOR loops
- **WHILE loop**
  - Complex conditions
  - Multiple exit conditions
- **NULL statement**
  - Explicit no-op placeholder
- **Nested control structures**
  - Complex combinations
  - FizzBuzz example
- **Conditional compilation**
  - With control structures
  - `$IF $$DEBUG_MODE $THEN`

## Oracle Version Requirements

### Oracle 10g
- Basic PL/SQL blocks
- FORALL and BULK COLLECT
- EXECUTE IMMEDIATE

### Oracle 11g
- CONTINUE statement
- CONTINUE WHEN
- Enhanced FORALL (INDICES OF, VALUES OF)

### Oracle 12.1
- UTL_CALL_STACK package
- PRAGMA DEPRECATE
- Enhancements to parallel table functions

### Oracle 12.2
- ACCESSIBLE BY clause

### Oracle 18c
- Qualified expressions
- Polymorphic table functions
- PRAGMA UDF enhancements

### Oracle 19c
- Additional polymorphic table function features

### Oracle 21c
- SQL_MACRO
- Qualified expression enhancements

### Oracle 23ai
- BOOLEAN as native SQL/PL/SQL datatype
- JSON as native datatype
- SELECT without FROM clause
- IF NOT EXISTS in DDL
- Enhanced qualified expressions

## Grammar Features to Test

### Block Structure
- [ ] Nested blocks with labels
- [ ] Anonymous blocks vs. named blocks
- [ ] DECLARE section with various declarations
- [ ] BEGIN-END structure
- [ ] EXCEPTION section

### Pragma Directives
- [ ] PRAGMA AUTONOMOUS_TRANSACTION
- [ ] PRAGMA EXCEPTION_INIT
- [ ] PRAGMA SERIALLY_REUSABLE
- [ ] PRAGMA INLINE
- [ ] PRAGMA RESTRICT_REFERENCES
- [ ] PRAGMA UDF
- [ ] PRAGMA DEPRECATE
- [ ] PRAGMA COVERAGE

### Function/Procedure Modifiers
- [ ] DETERMINISTIC
- [ ] RESULT_CACHE with RELIES_ON
- [ ] PARALLEL_ENABLE
- [ ] PIPELINED with partitioning clauses
- [ ] AUTHID CURRENT_USER/DEFINER
- [ ] ACCESSIBLE BY
- [ ] SQL_MACRO (TABLE/SCALAR)

### Bulk Operations
- [ ] BULK COLLECT INTO with LIMIT
- [ ] FORALL with INDICES OF
- [ ] FORALL with VALUES OF
- [ ] FORALL with SAVE EXCEPTIONS
- [ ] SQL%BULK_EXCEPTIONS

### Dynamic SQL
- [ ] EXECUTE IMMEDIATE with USING
- [ ] EXECUTE IMMEDIATE with RETURNING
- [ ] OPEN FOR with dynamic SQL
- [ ] DBMS_SQL package operations

### Control Structures
- [ ] CONTINUE and CONTINUE WHEN
- [ ] GOTO with labels
- [ ] CASE expression vs CASE statement
- [ ] EXIT WHEN with named loops
- [ ] FOR loop with REVERSE

### Exception Handling
- [ ] PRAGMA EXCEPTION_INIT
- [ ] RAISE_APPLICATION_ERROR
- [ ] UTL_CALL_STACK (12c+)
- [ ] DBMS_UTILITY formatting functions
- [ ] Nested exception handlers

### Modern Features (23ai)
- [ ] BOOLEAN datatype
- [ ] JSON native datatype
- [ ] SELECT without FROM
- [ ] Enhanced qualified expressions

## Testing Approach

1. **Parse Testing**: Try parsing each file with the grammar
2. **Semantic Testing**: Verify correct interpretation of constructs
3. **Edge Cases**: Test boundary conditions and unusual combinations
4. **Version Specific**: Test features against their minimum Oracle version
5. **Error Handling**: Verify appropriate error messages for invalid syntax

## Common Patterns

### Function with Multiple Modifiers
```sql
CREATE OR REPLACE FUNCTION my_func(p_val NUMBER) RETURN NUMBER
DETERMINISTIC
PARALLEL_ENABLE
RESULT_CACHE
IS
BEGIN
    RETURN p_val * 2;
END;
```

### Pipelined with Partitioning
```sql
CREATE OR REPLACE FUNCTION ptf(p_cursor SYS_REFCURSOR)
    RETURN emp_table
    PIPELINED
    PARALLEL_ENABLE (PARTITION p_cursor BY HASH (dept_id))
    ORDER p_cursor BY (emp_id)
IS
    -- Implementation
END;
```

### Bulk Operation with Exception Handling
```sql
DECLARE
    TYPE id_tab IS TABLE OF NUMBER;
    l_ids id_tab := id_tab(1, 2, 3);
BEGIN
    FORALL i IN l_ids.FIRST..l_ids.LAST SAVE EXCEPTIONS
        DELETE FROM table WHERE id = l_ids(i);
EXCEPTION
    WHEN OTHERS THEN
        FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
            -- Handle each exception
        END LOOP;
END;
```

## References

- [Oracle Database PL/SQL Language Reference, 21c](https://docs.oracle.com/en/database/oracle/oracle-database/21/lnpls/)
- [Oracle Database PL/SQL Language Reference, 23ai](https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/)
- [PL/SQL User's Guide and Reference](https://docs.oracle.com/en/database/oracle/oracle-database/19/lnpls/)
- [Oracle-Base PL/SQL Articles](https://oracle-base.com/articles/plsql/)
- [Polymorphic Table Functions](https://oracle-base.com/articles/18c/polymorphic-table-functions-18c)
- [Qualified Expressions](https://oracle-base.com/articles/18c/qualified-expressions-in-plsql-18c)

## Notes

- These test cases represent potentially unsupported or partially supported syntax
- Many features have complex interactions that need careful testing
- Oracle 23ai introduces significant modernization to PL/SQL
- Some features are deprecated but still valid (PRAGMA RESTRICT_REFERENCES)
- Performance-related pragmas (UDF, INLINE) may not affect parsing but are important for semantics
