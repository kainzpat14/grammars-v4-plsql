# Oracle PL/SQL Grammar Validation TODO List

This document tracks the most commonly used Oracle SQL and PL/SQL statement types that need validation and test case creation. Items are prioritized by usage frequency and importance.

## Priority Legend
- 🔴 **HIGH** - Very commonly used, critical for most applications
- 🟡 **MEDIUM** - Frequently used, important for many use cases
- 🟢 **LOW** - Less common, specialized use cases

## Status Legend
- ✅ **DONE** - Test cases created and validated
- 🚧 **IN PROGRESS** - Currently being worked on
- ⏳ **TODO** - Not yet started
- ⚠️ **PARTIAL** - Basic support exists, needs advanced cases

---

## 1. DML Statements (Data Manipulation)

### SELECT Statements 🔴 ⏳
**Priority**: HIGH - Most fundamental and complex statement type

**Areas to cover**:
- [ ] Basic SELECT with all clauses (WHERE, GROUP BY, HAVING, ORDER BY)
- [ ] SELECT with DISTINCT, UNIQUE
- [ ] Column aliases (AS keyword, implicit aliases)
- [ ] Table aliases and schema qualification
- [ ] FETCH FIRST / OFFSET clauses (12c+)
- [ ] Row limiting: FETCH FIRST n ROWS ONLY, WITH TIES
- [ ] FOR UPDATE clause (NOWAIT, SKIP LOCKED, WAIT n)
- [ ] WITH READ ONLY clause
- [ ] SAMPLE clause for sampling
- [ ] Flashback query (AS OF SCN, AS OF TIMESTAMP)
- [ ] Hierarchical queries (CONNECT BY, START WITH, LEVEL, PRIOR)
- [ ] PIVOT and UNPIVOT operations
- [ ] MODEL clause
- [ ] Advanced subqueries (correlated, scalar, inline views)

**Files to create**:
- `select_basic_clauses.sql`
- `select_row_limiting.sql`
- `select_for_update_variations.sql`
- `select_hierarchical_queries.sql`
- `select_pivot_unpivot.sql`
- `select_flashback_queries.sql`

---

### INSERT Statements 🔴 ⏳
**Priority**: HIGH

**Areas to cover**:
- [ ] INSERT with VALUES clause
- [ ] INSERT with subquery (INSERT INTO ... SELECT)
- [ ] Multi-table INSERT (ALL, FIRST, conditional)
- [ ] INSERT with RETURNING clause
- [ ] INSERT with DEFAULT VALUES (23ai)
- [ ] INSERT with error logging (LOG ERRORS clause)
- [ ] INSERT with DML error logging clause
- [ ] INSERT with subquery and WITH CHECK OPTION
- [ ] Direct-path INSERT (INSERT /*+ APPEND */)
- [ ] INSERT INTO SET (23ai - non-positional)

**Files to create**:
- `insert_basic_variations.sql`
- `insert_multi_table.sql`
- `insert_returning_clause.sql`
- `insert_error_logging.sql`
- `insert_23ai_features.sql`

---

### UPDATE Statements 🔴 ⏳
**Priority**: HIGH

**Areas to cover**:
- [ ] Basic UPDATE with WHERE clause
- [ ] UPDATE with subquery in SET clause
- [ ] UPDATE with correlated subqueries
- [ ] UPDATE with RETURNING clause
- [ ] UPDATE with error logging
- [ ] UPDATE with DEFAULT keyword
- [ ] Multi-column updates
- [ ] UPDATE with joins (updatable views)

**Files to create**:
- `update_basic_variations.sql`
- `update_subqueries.sql`
- `update_returning_clause.sql`

---

### DELETE Statements 🔴 ⏳
**Priority**: HIGH

**Areas to cover**:
- [ ] Basic DELETE with WHERE clause
- [ ] DELETE with subquery
- [ ] DELETE with RETURNING clause
- [ ] DELETE with error logging

**Files to create**:
- `delete_variations.sql`

---

### MERGE Statements 🟡 ⏳
**Priority**: MEDIUM - Common in ETL and data warehousing

**Areas to cover**:
- [ ] Basic MERGE (MATCHED/NOT MATCHED)
- [ ] MERGE with UPDATE clause
- [ ] MERGE with INSERT clause
- [ ] MERGE with DELETE clause (conditional delete)
- [ ] MERGE with error logging
- [ ] MERGE with multiple WHEN MATCHED clauses
- [ ] MERGE with WHERE conditions on each clause

**Files to create**:
- `merge_basic_operations.sql`
- `merge_conditional_clauses.sql`
- `merge_error_logging.sql`

---

## 2. Query Constructs and Clauses

### WITH Clause (Common Table Expressions) 🔴 ⏳
**Priority**: HIGH - Increasingly common, improves readability

**Areas to cover**:
- [ ] Basic WITH clause (non-recursive)
- [ ] Multiple CTEs in single query
- [ ] Recursive WITH clause (UNION ALL)
- [ ] WITH clause column aliases
- [ ] Nested WITH clauses
- [ ] WITH clause in INSERT/UPDATE/DELETE/MERGE
- [ ] WITH FUNCTION clause (18c+)
- [ ] WITH PROCEDURE clause (18c+)

**Files to create**:
- `with_cte_basic.sql`
- `with_cte_recursive.sql`
- `with_plsql_declarations.sql`

---

### JOIN Variations 🔴 ⏳
**Priority**: HIGH

**Areas to cover**:
- [ ] INNER JOIN with ON condition
- [ ] LEFT OUTER JOIN
- [ ] RIGHT OUTER JOIN
- [ ] FULL OUTER JOIN
- [ ] CROSS JOIN
- [ ] NATURAL JOIN
- [ ] JOIN with USING clause
- [ ] Multiple joins
- [ ] Self joins
- [ ] ANSI vs Oracle join syntax comparison
- [ ] PARTITION OUTER JOIN
- [ ] CROSS APPLY / OUTER APPLY

**Files to create**:
- `joins_all_types.sql`
- `joins_partition_outer.sql`
- `joins_apply_variations.sql`

---

### Analytical Functions 🔴 ⏳
**Priority**: HIGH - Very common in reporting

**Areas to cover**:
- [ ] ROW_NUMBER()
- [ ] RANK() and DENSE_RANK()
- [ ] LAG() and LEAD()
- [ ] FIRST_VALUE() and LAST_VALUE()
- [ ] NTH_VALUE()
- [ ] LISTAGG()
- [ ] NTILE()
- [ ] Window frame specifications (ROWS, RANGE, GROUPS)
- [ ] PARTITION BY clause
- [ ] ORDER BY in analytical functions
- [ ] Nested analytical functions

**Files to create**:
- `analytical_functions_ranking.sql`
- `analytical_functions_windowing.sql`
- `analytical_functions_aggregate.sql`

---

### Set Operators 🔴 ⏳
**Priority**: HIGH

**Areas to cover**:
- [ ] UNION
- [ ] UNION ALL
- [ ] INTERSECT
- [ ] MINUS
- [ ] Multiple set operations
- [ ] Set operations with ORDER BY
- [ ] Set operations with different data types

**Files to create**:
- `set_operators_all_types.sql`

---

## 3. DDL Statements - Views and Indexes

### CREATE VIEW 🔴 ⏳
**Priority**: HIGH

**Areas to cover**:
- [ ] Basic CREATE VIEW
- [ ] CREATE OR REPLACE VIEW
- [ ] CREATE VIEW with WITH CHECK OPTION
- [ ] CREATE VIEW with WITH READ ONLY
- [ ] Views with complex queries (joins, subqueries)
- [ ] Inline constraints in views
- [ ] Views with FORCE option
- [ ] Editioning views (CREATE EDITIONING VIEW)
- [ ] Views with BEQUEATH (CURRENT_USER/DEFINER) - 12c+
- [ ] Views with annotations (23ai)

**Files to create**:
- `create_view_basic.sql`
- `create_view_advanced_options.sql`
- `create_view_complex_queries.sql`

---

### ALTER VIEW 🟡 ⏳
**Priority**: MEDIUM

**Areas to cover**:
- [ ] ALTER VIEW COMPILE
- [ ] ALTER VIEW ADD CONSTRAINT
- [ ] ALTER VIEW DROP CONSTRAINT
- [ ] ALTER VIEW MODIFY CONSTRAINT
- [ ] ALTER VIEW READ ONLY / READ WRITE
- [ ] ALTER VIEW with annotations (23ai)

**Files to create**:
- `alter_view_operations.sql`

---

### CREATE MATERIALIZED VIEW 🟡 ⏳
**Priority**: MEDIUM - Common in data warehousing

**Areas to cover**:
- [ ] Basic CREATE MATERIALIZED VIEW
- [ ] WITH PRIMARY KEY / ROWID
- [ ] BUILD IMMEDIATE / DEFERRED
- [ ] REFRESH options (FAST, COMPLETE, FORCE)
- [ ] REFRESH ON DEMAND / COMMIT / START WITH
- [ ] ENABLE/DISABLE QUERY REWRITE
- [ ] Materialized views on prebuilt tables
- [ ] Partitioned materialized views
- [ ] Materialized views with aggregates
- [ ] NEVER REFRESH option
- [ ] WITH REDUCED PRECISION
- [ ] USING INDEX clauses
- [ ] ON COMMIT REFRESH

**Files to create**:
- `create_materialized_view_basic.sql`
- `create_materialized_view_refresh_options.sql`
- `create_materialized_view_partitioned.sql`

---

### ALTER MATERIALIZED VIEW 🟡 ⏳
**Priority**: MEDIUM

**Areas to cover**:
- [ ] ALTER MATERIALIZED VIEW COMPILE
- [ ] ALTER MATERIALIZED VIEW REFRESH
- [ ] ALTER MATERIALIZED VIEW CONSIDER FRESH
- [ ] ALTER MATERIALIZED VIEW ENABLE/DISABLE QUERY REWRITE
- [ ] ALTER MATERIALIZED VIEW SHRINK SPACE
- [ ] Modify refresh options
- [ ] Modify storage options

**Files to create**:
- `alter_materialized_view_operations.sql`

---

### CREATE INDEX 🔴 ⏳
**Priority**: HIGH

**Areas to cover**:
- [ ] Basic CREATE INDEX
- [ ] CREATE UNIQUE INDEX
- [ ] CREATE BITMAP INDEX
- [ ] Function-based indexes
- [ ] Descending indexes
- [ ] Compressed indexes (COMPRESS n)
- [ ] Invisible indexes (INVISIBLE)
- [ ] Partial indexes (11g+)
- [ ] Virtual column indexes
- [ ] Text indexes (INDEXTYPE IS CTXSYS.CONTEXT)
- [ ] Spatial indexes
- [ ] Domain indexes
- [ ] Global and local partitioned indexes
- [ ] Index-organized table indexes
- [ ] Indexes with NOLOGGING
- [ ] Indexes with PARALLEL
- [ ] Online index creation (ONLINE keyword)

**Files to create**:
- `create_index_basic_types.sql`
- `create_index_function_based.sql`
- `create_index_partitioned.sql`
- `create_index_specialized.sql`

---

### ALTER INDEX 🟡 ⏳
**Priority**: MEDIUM

**Areas to cover**:
- [ ] ALTER INDEX REBUILD
- [ ] ALTER INDEX REBUILD ONLINE
- [ ] ALTER INDEX COALESCE
- [ ] ALTER INDEX MONITORING USAGE
- [ ] ALTER INDEX VISIBLE/INVISIBLE
- [ ] ALTER INDEX RENAME TO
- [ ] ALTER INDEX UNUSABLE
- [ ] ALTER INDEX partition operations
- [ ] ALTER INDEX SHRINK SPACE

**Files to create**:
- `alter_index_operations.sql`

---

## 4. DDL Statements - Other Objects

### CREATE SEQUENCE 🔴 ⏳
**Priority**: HIGH - Very common for ID generation

**Areas to cover**:
- [ ] Basic CREATE SEQUENCE
- [ ] START WITH clause
- [ ] INCREMENT BY clause
- [ ] MINVALUE / NOMAXVALUE
- [ ] MAXVALUE / NOMINVALUE
- [ ] CYCLE / NOCYCLE
- [ ] CACHE / NOCACHE
- [ ] ORDER / NOORDER
- [ ] SESSION vs GLOBAL sequences (23ai)

**Files to create**:
- `create_sequence_variations.sql`

---

### ALTER SEQUENCE 🟡 ⏳
**Priority**: MEDIUM

**Areas to cover**:
- [ ] ALTER SEQUENCE INCREMENT BY
- [ ] ALTER SEQUENCE MAXVALUE
- [ ] ALTER SEQUENCE CACHE
- [ ] ALTER SEQUENCE CYCLE
- [ ] Restart sequence (12c+)

**Files to create**:
- `alter_sequence_operations.sql`

---

### CREATE TRIGGER 🟡 ⏳
**Priority**: MEDIUM

**Areas to cover**:
- [ ] BEFORE/AFTER triggers
- [ ] INSTEAD OF triggers
- [ ] Statement-level triggers
- [ ] Row-level triggers (FOR EACH ROW)
- [ ] Compound triggers (11g+)
- [ ] Multiple triggering events (INSERT OR UPDATE OR DELETE)
- [ ] WHEN condition
- [ ] :OLD and :NEW references
- [ ] REFERENCING clause
- [ ] ENABLE/DISABLE clause
- [ ] FOLLOWS clause (ordering)
- [ ] DDL triggers (ON SCHEMA, ON DATABASE)
- [ ] System event triggers (STARTUP, SHUTDOWN, etc.)
- [ ] Trigger with AUTONOMOUS_TRANSACTION
- [ ] Crossedition triggers (12c+)

**Files to create**:
- `create_trigger_dml.sql`
- `create_trigger_compound.sql`
- `create_trigger_ddl_system.sql`
- `create_trigger_instead_of.sql`

---

### CREATE PACKAGE / PACKAGE BODY 🔴 ⏳
**Priority**: HIGH - Fundamental to PL/SQL development

**Areas to cover**:
- [ ] Basic package specification
- [ ] Package body with procedure implementations
- [ ] Package body with function implementations
- [ ] Package variables (public and private)
- [ ] Package constants
- [ ] Package cursors
- [ ] Package types
- [ ] Package initialization section
- [ ] AUTHID CURRENT_USER/DEFINER
- [ ] ACCESSIBLE BY clause (18c+)
- [ ] SERIALLY_REUSABLE pragma
- [ ] Overloaded procedures/functions
- [ ] Default parameter values
- [ ] Forward declarations

**Files to create**:
- `create_package_basic.sql`
- `create_package_advanced_features.sql`
- `create_package_body_complex.sql`

---

### CREATE TYPE / TYPE BODY 🟡 ⏳
**Priority**: MEDIUM

**Areas to cover**:
- [ ] Object types
- [ ] Collection types (VARRAY, NESTED TABLE)
- [ ] Type with member methods
- [ ] Type with static methods
- [ ] Type with constructor methods
- [ ] Type inheritance (UNDER clause)
- [ ] Abstract types (NOT INSTANTIABLE)
- [ ] Type body implementation
- [ ] MAP and ORDER methods
- [ ] SQLJ object types

**Files to create**:
- `create_type_objects.sql`
- `create_type_collections.sql`
- `create_type_body_methods.sql`

---

### CREATE SYNONYM 🟡 ⏳
**Priority**: MEDIUM

**Areas to cover**:
- [ ] Private synonyms
- [ ] Public synonyms
- [ ] Synonyms for remote objects (database links)
- [ ] CREATE OR REPLACE SYNONYM

**Files to create**:
- `create_synonym_variations.sql`

---

### CREATE DATABASE LINK 🟡 ⏳
**Priority**: MEDIUM

**Areas to cover**:
- [ ] Private database links
- [ ] Public database links
- [ ] Database links with CONNECT TO
- [ ] Database links with IDENTIFIED BY
- [ ] Database links with USING
- [ ] SHARED database links

**Files to create**:
- `create_database_link_variations.sql`

---

## 5. Constraints

### Inline Constraints 🔴 ⏳
**Priority**: HIGH

**Areas to cover**:
- [ ] NOT NULL constraints
- [ ] UNIQUE constraints
- [ ] PRIMARY KEY constraints
- [ ] FOREIGN KEY constraints with REFERENCES
- [ ] CHECK constraints
- [ ] Constraint naming (CONSTRAINT name)
- [ ] DEFERRABLE / NOT DEFERRABLE
- [ ] INITIALLY DEFERRED / INITIALLY IMMEDIATE
- [ ] ON DELETE CASCADE / SET NULL
- [ ] USING INDEX clause

**Files to create**:
- `constraints_inline_all_types.sql`

---

### Out-of-Line Constraints 🔴 ⏳
**Priority**: HIGH

**Areas to cover**:
- [ ] Table-level PRIMARY KEY (multiple columns)
- [ ] Table-level UNIQUE (multiple columns)
- [ ] Table-level FOREIGN KEY
- [ ] Table-level CHECK constraints
- [ ] Constraint with USING INDEX clause
- [ ] Disabled constraints (DISABLE clause)
- [ ] VALIDATE / NOVALIDATE constraints
- [ ] RELY / NORELY constraints

**Files to create**:
- `constraints_out_of_line.sql`
- `constraints_states.sql`

---

### ALTER TABLE ADD/MODIFY/DROP CONSTRAINT 🔴 ⏳
**Priority**: HIGH

**Areas to cover**:
- [ ] ADD CONSTRAINT
- [ ] MODIFY CONSTRAINT
- [ ] DROP CONSTRAINT
- [ ] ENABLE/DISABLE CONSTRAINT
- [ ] VALIDATE/NOVALIDATE CONSTRAINT
- [ ] RENAME CONSTRAINT
- [ ] CASCADE option for DROP

**Files to create**:
- `alter_table_constraint_operations.sql`

---

## 6. Advanced Query Features

### Subqueries 🔴 ⏳
**Priority**: HIGH

**Areas to cover**:
- [ ] Scalar subqueries
- [ ] Single-row subqueries
- [ ] Multi-row subqueries (IN, ANY, ALL)
- [ ] Correlated subqueries
- [ ] Subqueries in SELECT clause
- [ ] Subqueries in FROM clause (inline views)
- [ ] Subqueries in WHERE clause
- [ ] Subqueries in HAVING clause
- [ ] EXISTS and NOT EXISTS
- [ ] Lateral inline views (LATERAL keyword) - 12c+

**Files to create**:
- `subqueries_all_types.sql`
- `subqueries_correlated.sql`
- `subqueries_lateral.sql`

---

### CASE Expressions 🔴 ⏳
**Priority**: HIGH

**Areas to cover**:
- [ ] Simple CASE expression
- [ ] Searched CASE expression
- [ ] Nested CASE expressions
- [ ] CASE in SELECT clause
- [ ] CASE in WHERE clause
- [ ] CASE in ORDER BY clause
- [ ] DECODE function (Oracle-specific alternative)

**Files to create**:
- `case_expressions_all_forms.sql`

---

### NULL Handling 🔴 ⏳
**Priority**: HIGH

**Areas to cover**:
- [ ] NVL function
- [ ] NVL2 function
- [ ] NULLIF function
- [ ] COALESCE function
- [ ] IS NULL / IS NOT NULL
- [ ] NULL in ORDER BY (NULLS FIRST/LAST)

**Files to create**:
- `null_handling_functions.sql`

---

## 7. Transaction Control

### Transaction Statements 🔴 ⏳
**Priority**: HIGH

**Areas to cover**:
- [ ] COMMIT
- [ ] COMMIT WORK
- [ ] COMMIT FORCE
- [ ] ROLLBACK
- [ ] ROLLBACK TO SAVEPOINT
- [ ] SAVEPOINT
- [ ] SET TRANSACTION (already created but needs verification)
- [ ] SET CONSTRAINT (immediate/deferred)

**Files to create**:
- `transaction_control_statements.sql`

---

## 8. Session and System

### ALTER SESSION 🟡 ⏳
**Priority**: MEDIUM

**Areas to cover**:
- [ ] SET NLS_DATE_FORMAT
- [ ] SET NLS_TERRITORY
- [ ] SET SQL_TRACE
- [ ] SET CURRENT_SCHEMA
- [ ] SET TIME_ZONE
- [ ] ENABLE/DISABLE PARALLEL DML
- [ ] ENABLE/DISABLE PARALLEL QUERY
- [ ] ENABLE/DISABLE COMMIT IN PROCEDURE
- [ ] ADVISE COMMIT/ROLLBACK/NOTHING

**Files to create**:
- `alter_session_variations.sql`

---

## 9. Previously Created (For Reference)

### ✅ Already Covered
These have test cases created:

- ✅ CREATE TABLE (comprehensive)
- ✅ ALTER TABLE (comprehensive)
- ✅ CREATE DOMAIN (23ai)
- ✅ ALTER DOMAIN (23ai)
- ✅ CREATE JSON RELATIONAL DUALITY VIEW (23ai)
- ✅ CREATE VECTOR INDEX (23ai)
- ✅ CREATE HYBRID VECTOR INDEX (23ai)
- ✅ CREATE MLE MODULE (23ai)
- ✅ CREATE MLE ENV (23ai)
- ✅ CREATE PROPERTY GRAPH (23ai)
- ✅ ALTER SYSTEM
- ✅ ALTER PLUGGABLE DATABASE
- ✅ ALTER DATABASE DICTIONARY
- ✅ ALTER PROFILE
- ✅ FLASHBACK DATABASE
- ✅ SET ROLE
- ✅ SET TRANSACTION
- ✅ PL/SQL Blocks (comprehensive)
- ✅ PL/SQL Exception Handling
- ✅ PL/SQL Pragma Directives
- ✅ PL/SQL Function/Procedure Modifiers
- ✅ PL/SQL Bulk Operations
- ✅ PL/SQL Control Structures

---

## Priority Order for Implementation

### Phase 1: Core DML and Query (🔴 HIGH Priority)
1. SELECT statements (all variations)
2. INSERT statements
3. UPDATE statements
4. DELETE statements
5. WITH clause (CTEs)
6. JOIN variations
7. Analytical functions
8. Subqueries

### Phase 2: Core DDL (🔴 HIGH Priority)
1. CREATE/ALTER VIEW
2. CREATE/ALTER INDEX
3. CREATE/ALTER SEQUENCE
4. CREATE PACKAGE/PACKAGE BODY
5. Constraints (inline and out-of-line)

### Phase 3: Common Features (🟡 MEDIUM Priority)
1. MERGE statements
2. CREATE/ALTER MATERIALIZED VIEW
3. CREATE TRIGGER
4. CREATE TYPE/TYPE BODY
5. CREATE SYNONYM
6. CREATE DATABASE LINK
7. ALTER SESSION

### Phase 4: Advanced Features (🟢 LOW Priority)
1. Advanced trigger types
2. Specialized indexes
3. Complex type hierarchies
4. System-level DDL

---

## Testing Guidelines

For each statement type, create test cases covering:

1. **Basic syntax** - Minimal valid statement
2. **All clauses** - Each optional clause independently
3. **Combinations** - Common clause combinations
4. **Edge cases** - Unusual but valid combinations
5. **Version-specific** - Features by Oracle version
6. **Complex examples** - Real-world scenarios

## File Naming Convention

Use consistent naming:
- `[statement_type]_[feature]_[variant].sql`
- Examples:
  - `select_basic_clauses.sql`
  - `insert_multi_table.sql`
  - `create_view_with_check_option.sql`

## Documentation

Each test file should include:
- Header comment explaining what's being tested
- Oracle version requirements
- Expected behavior notes
- References to Oracle documentation

---

## Progress Tracking

**Current Status** (as of 2025-01-18):
- Total high-priority items: 15
- Total medium-priority items: 12
- Total low-priority items: 2
- Completed items: 44 (from previous work)
- Remaining TODO items: 29

**Next Steps**:
1. Start with SELECT statement variations (highest impact)
2. Move to INSERT/UPDATE/DELETE
3. Cover WITH clause and JOINs
4. Continue with views and indexes

---

## Contributing

When adding test cases:
1. Update this TODO list with checkmarks ✅
2. Add the file to `probably_failing/` directory
3. Document any Oracle-specific syntax
4. Note any grammar limitations discovered
5. Reference Oracle documentation URLs

## References

- [Oracle Database SQL Language Reference, 21c](https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/)
- [Oracle Database SQL Language Reference, 23ai](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/)
- [Oracle Database PL/SQL Language Reference](https://docs.oracle.com/en/database/oracle/oracle-database/21/lnpls/)
