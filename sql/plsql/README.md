# PL/SQL grammar

This grammar is for recognizing the latest version of PL/SQL.

## Authors

Various

## Links

Oracle� Database; Database PL/SQL Language Reference [html](https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/index.html) [pdf](https://docs.oracle.com/en/database/oracle/oracle-database/23/lnpls/database-pl-sql-language-reference.pdf)

SQL Language Reference [html](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/index.html) [pdf](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqlrf/sql-language-reference.pdf)

Oracle's SQL*Plus�
User's Guide and Reference [html](https://docs.oracle.com/en/database/oracle/oracle-database/23/sqpug/index.html#SQL*Plus%C2%AE)

[wikipedia](https://en.wikipedia.org/wiki/PL/SQL)

[pldb](https://pldb.pub/concepts/pl-sql.html)

## Testing

### Grammar Tests
The grammar includes automated tests for parsing SQL examples:
- `examples/` - Standard PL/SQL examples
- `more/` - Additional test cases
- `probably_failing/` - SQL statements not yet supported by the grammar

### Oracle Syntax Validation
A testcontainer-based test validates SQL statements in `probably_failing/` against an actual Oracle Database instance:

```bash
cd sql/plsql
mvn clean test -Dtest=OracleSyntaxValidationTest
```

This test:
- Starts Oracle XE 18c in a Docker container
- Creates prerequisite database objects
- Validates each SQL statement using Oracle's DBMS_SQL.PARSE
- Generates a detailed validation report

See [ORACLE_VALIDATION_REPORT.md](ORACLE_VALIDATION_REPORT.md) for the latest validation results.

## Issues
* The grammar is ambiguous, but generally performs well.

## Performance
<img src="./times.svg">
<a href="/sql/plsql/data.zip">data.zip</a>
<a href="/sql/plsql/te.sh">te.sh</a>
<a href="/sql/plsql/gr.sh">gr.sh</a>
