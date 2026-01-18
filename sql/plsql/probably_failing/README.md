# PL/SQL Grammar - Probably Failing Test Cases

This directory contains SQL statements that are **not currently supported** by the PlSql grammar in this repository. These statements represent Oracle PL/SQL features that may need to be added to the grammar in future versions.

## Purpose

These test cases document SQL statement types from Oracle Database (versions 12c through 23ai/26ai) that are missing from the current grammar implementation. They serve as:

1. **Documentation** of missing features
2. **Test cases** for grammar validation when features are added
3. **Reference examples** from Oracle documentation

## Statements Included

### ALTER Statements
- **alter_database_dictionary.sql** - Data dictionary encryption management (Oracle 12.2+)
- **alter_domain.sql** - Modify SQL domain properties (Oracle 23ai)
- **alter_indextype.sql** - Modify domain index types
- **alter_json_duality_view.sql** - Alter JSON Relational Duality Views (Oracle 23ai)
- **alter_mle_env.sql** - Alter MLE (Multilingual Engine) environments (Oracle 23ai)
- **alter_mle_module.sql** - Alter MLE modules (Oracle 23ai)
- **alter_pluggable_database.sql** - Manage pluggable databases (Oracle 12c+)
- **alter_profile.sql** - Modify user profiles with resource limits and password policies
- **alter_property_graph.sql** - Alter property graphs (Oracle 23ai)
- **alter_system.sql** - System-level database operations

### CREATE Statements
- **create_domain.sql** - Create SQL domains (single-column, multi-column, enum, flexible) (Oracle 23ai)
- **create_hybrid_vector_index.sql** - Create hybrid vector indexes combining text and vector search (Oracle 23ai 23.6+)
- **create_json_duality_view.sql** - Create JSON Relational Duality Views (Oracle 23ai)
- **create_mle_env.sql** - Create MLE JavaScript environments (Oracle 23ai)
- **create_mle_module.sql** - Create MLE JavaScript modules (Oracle 23ai)
- **create_property_graph.sql** - Create property graphs for graph analytics (Oracle 23ai)
- **create_vector_index.sql** - Create vector indexes (IVF and HNSW) for AI vector search (Oracle 23ai)

### DROP Statements
- **drop_domain.sql** - Drop SQL domains (Oracle 23ai)
- **drop_json_duality_view.sql** - Drop JSON Relational Duality Views (Oracle 23ai)
- **drop_mle_env.sql** - Drop MLE environments (Oracle 23ai)
- **drop_mle_module.sql** - Drop MLE modules (Oracle 23ai)
- **drop_property_graph.sql** - Drop property graphs (Oracle 23ai)

### Other Statements
- **flashback_database.sql** - Flashback entire database to a previous point in time (Oracle 10g+)
- **set_role.sql** - Enable/disable roles for current session
- **set_transaction.sql** - Set transaction properties (isolation level, read-only/read-write)

## Oracle Version Coverage

- **Oracle 10g**: FLASHBACK DATABASE
- **Oracle 12c**: ALTER PLUGGABLE DATABASE, ALTER DATABASE DICTIONARY
- **Oracle 23ai**: Most new features including:
  - SQL Domains (single-column, multi-column, enum, flexible)
  - JSON Relational Duality Views
  - Property Graphs
  - MLE (Multilingual Engine) for JavaScript
  - AI Vector Search (Vector Indexes, Hybrid Vector Indexes)

## Statement Categories

### Database Administration
- ALTER SYSTEM
- ALTER PLUGGABLE DATABASE
- ALTER DATABASE DICTIONARY
- FLASHBACK DATABASE

### Security & Access Control
- ALTER PROFILE (resource limits, password policies)
- SET ROLE
- ALTER INDEXTYPE

### Oracle 23ai AI & Modern Features
- Vector indexes (IVF, HNSW) for similarity search
- Hybrid vector indexes (combined text + vector search)
- JSON Relational Duality Views (unified JSON/relational access)
- Property Graphs (graph analytics)
- SQL Domains (data validation and constraints)
- MLE (JavaScript in the database)

### Transaction Control
- SET TRANSACTION (isolation levels, read-only/read-write)
- SET ROLE (role management)

## Testing Approach

These SQL files are expected to **fail parsing** with the current grammar. They can be used to:

1. Identify which statements need grammar support
2. Test grammar changes by moving files to the main examples directory once support is added
3. Verify that error messages are appropriate for unsupported statements

## Contributing

When adding support for any of these statements to the grammar:

1. Move the corresponding SQL file from `probably_failing/` to `examples/`
2. Add additional test cases if needed
3. Update this README to remove the implemented statement from the list
4. Verify all examples in the moved file parse correctly

## Sources

All examples are based on official Oracle Database documentation:
- [Oracle Database SQL Language Reference, 21c](https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/)
- [Oracle Database SQL Language Reference, 23ai](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/)
- [Oracle Database SQL Language Reference, 26ai](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/)
- [Oracle Database PL/SQL Language Reference](https://docs.oracle.com/en/database/oracle/oracle-database/21/lnpls/)

## Notes

- Some statements like SET TRANSACTION and SET ROLE may be partially supported but are included here for completeness
- Oracle 23ai introduced significant new features focused on AI, JSON, and modern application development
- Many of these features represent cutting-edge Oracle Database capabilities as of 2025
