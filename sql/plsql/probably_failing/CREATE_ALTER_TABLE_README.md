-- README for CREATE TABLE and ALTER TABLE Test Cases

This directory contains comprehensive test cases for CREATE TABLE and ALTER TABLE statements that may not be fully supported by the current PL/SQL grammar.

## CREATE TABLE Test Files

### create_table_23ai_datatypes.sql
Tests Oracle 23ai's new native datatypes:
- **JSON** datatype (native, not just check constraint)
- **VECTOR** datatype with dimensions and formats (FLOAT32, FLOAT64, INT8, BINARY)
- **BOOLEAN** datatype (native SQL boolean)
- Combinations of new datatypes with identity columns and constraints

Key features tested:
- VECTOR(n) with various dimensions (768, 1536, etc.)
- VECTOR(n, format) with FLOAT32, FLOAT64, INT8, BINARY
- BOOLEAN with DEFAULT TRUE/FALSE
- JSON columns with IS JSON constraints
- IF NOT EXISTS with new datatypes

### create_table_default_on_null.sql
Tests the DEFAULT ON NULL clause for columns:
- DEFAULT ON NULL with literals
- DEFAULT ON NULL with expressions (SYSDATE, USER, etc.)
- DEFAULT ON NULL with GENERATED ... AS IDENTITY
- DEFAULT ON NULL with function calls (SYSTIMESTAMP, SYS_CONTEXT)
- Combination of DEFAULT and DEFAULT ON NULL on different columns
- DEFAULT ON NULL with INVISIBLE columns

### create_table_external_advanced.sql
Advanced external table features beyond basic examples:
- BADFILE, DISCARDFILE, LOGFILE specifications
- SKIP and LOAD parameters for row control
- PREPROCESSOR for compressed files (gunzip, etc.)
- CHARACTER SET specifications (UTF8, etc.)
- DATE_FORMAT for date/timestamp columns
- TRIM specifications (LTRIM, RTRIM)
- NULL IF clauses
- Multiple location files
- VERSION parameter for ORACLE_DATAPUMP
- Complex ACCESS PARAMETERS configurations

### create_table_collation.sql
Tests COLLATE and collation specifications:
- Table-level DEFAULT COLLATION
- Column-level COLLATE clauses
- Various collation types: BINARY, BINARY_CI, BINARY_AI
- Linguistic collations: XFRENCH_CI, XGERMAN_CI, XSPANISH_CI
- USING_NLS_COMP and USING_NLS_SORT
- Collations with constraints and partitioning

### create_table_as_select_advanced.sql
Advanced CREATE TABLE AS SELECT (CTAS) variations:
- NOLOGGING and PARALLEL options
- Specific tablespace and storage parameters
- Partitioning defined in CTAS
- COMPRESS FOR QUERY/ARCHIVE/OLTP
- INMEMORY specifications
- PCTFREE, PCTUSED, CACHE/NOCACHE
- ROWDEPENDENCIES
- Complex storage attributes (INITIAL, NEXT, PCTINCREASE)
- ON COMMIT for global temporary tables
- SEGMENT CREATION DEFERRED
- LOB storage specifications in CTAS

## ALTER TABLE Test Files

### alter_table_23ai_datatypes.sql
Tests adding and modifying columns with Oracle 23ai datatypes:
- ADD column with JSON, VECTOR, BOOLEAN types
- MODIFY column to change to new datatypes
- Adding constraints to new datatype columns
- DEFAULT values and DEFAULT ON NULL for new types
- INVISIBLE columns with new datatypes
- Multiple column additions including new types

### alter_table_shrink_space.sql
Comprehensive SHRINK SPACE operations:
- Basic SHRINK SPACE
- SHRINK SPACE COMPACT (doesn't move HWM)
- SHRINK SPACE CASCADE (includes indexes)
- Shrink specific partitions and subpartitions
- SHRINK SPACE CHECK for validation
- LOB segment shrinking
- Combining with ENABLE/DISABLE ROW MOVEMENT
- Shrinking Index Organized Tables (IOT)
- Shrinking overflow segments

### alter_table_move_online.sql
Online table move operations (Oracle 12.2+):
- MOVE ONLINE to different tablespace
- MOVE ONLINE with UPDATE INDEXES
- MOVE with PARALLEL
- MOVE with compression options (COMPRESS FOR QUERY/ARCHIVE/OLTP)
- MOVE with INMEMORY/NO INMEMORY
- MOVE with storage parameters (PCTFREE, INITIAL, NEXT)
- MOVE with LOB storage specifications
- MOVE for Index Organized Tables (IOT)
- MOVE with INCLUDING OVERFLOW
- MOVE with filter conditions (Oracle 19c+)

### alter_table_flashback_archive.sql
Flashback Data Archive operations:
- FLASHBACK ARCHIVE to enable tracking
- NO FLASHBACK ARCHIVE to disable
- Switching between different Flashback Archives
- Enabling FDA on various table types (partitioned, with LOBs, etc.)
- Combining with other ALTER TABLE operations

### alter_table_advanced_operations.sql
Miscellaneous advanced ALTER TABLE operations:
- Adding DEFAULT ON NULL to existing columns
- Adding COLLATE to columns
- Converting non-partitioned to partitioned (MODIFY PARTITION BY)
- INVISIBLE/VISIBLE column modifications
- Adding and modifying identity columns
- Adding virtual columns with GENERATED ALWAYS AS
- Table-level compression modifications
- SUPPLEMENTAL LOG DATA variations
- SET UNUSED and DROP UNUSED COLUMNS
- Nested table collection modifications
- LOB storage modifications (SECUREFILE, COMPRESS, DEDUPLICATE)
- Constraint modifications (RELY/NORELY, DEFERRABLE)
- ENABLE/DISABLE ROW MOVEMENT
- Parallel degree modifications
- CACHE/NOCACHE, RESULT_CACHE
- Domain columns (Oracle 23ai)

## Grammar Support Status

These test cases document syntax that may:
1. **Not be supported** - Grammar doesn't recognize the syntax at all
2. **Partially supported** - Basic forms work but advanced options don't
3. **Need verification** - Syntax exists in grammar but edge cases untested

## Usage

These files can be used to:
1. **Identify gaps** in grammar coverage
2. **Test parser** changes when adding new features
3. **Document examples** for future grammar development
4. **Verify compatibility** across Oracle versions

## Oracle Version Requirements

- **12.1**: Identity columns, some partitioning features
- **12.2**: Online table moves, partitioning conversions
- **18c**: Additional compression options
- **19c**: Filter conditions in MOVE, additional features
- **21c**: Various enhancements
- **23ai**: JSON, VECTOR, BOOLEAN datatypes, domains, annotations, IF NOT EXISTS

## Testing Approach

To test these statements:
1. Try parsing with current grammar
2. Note which statements fail
3. Compare with Oracle documentation
4. Prioritize commonly-used features for grammar additions
5. Test against actual Oracle database when possible

## References

- [Oracle Database SQL Language Reference, 21c](https://docs.oracle.com/en/database/oracle/oracle-database/21/sqlrf/)
- [Oracle Database SQL Language Reference, 23ai](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/)
- [Oracle Database SQL Language Reference, 26ai](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/)
- [CREATE TABLE Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/CREATE-TABLE.html)
- [ALTER TABLE Documentation](https://docs.oracle.com/en/database/oracle/oracle-database/26/sqlrf/ALTER-TABLE.html)
