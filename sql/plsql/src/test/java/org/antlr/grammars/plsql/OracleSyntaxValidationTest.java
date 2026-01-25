package org.antlr.grammars.plsql;

import org.junit.jupiter.api.*;
import org.testcontainers.oracle.OracleContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.Duration;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Test class to validate SQL statements in probably_failing directory against Oracle Database.
 * This test uses Testcontainers to spin up an Oracle database instance and verify that
 * the SQL statements are syntactically correct according to Oracle.
 */
@Testcontainers
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class OracleSyntaxValidationTest {

    @Container
    private static final OracleContainer oracleContainer = new OracleContainer("gvenzl/oracle-free:23-slim")
            .withReuse(false);

    private static Connection connection;
    private static final String PROBABLY_FAILING_DIR = "probably_failing";
    private static final Map<String, ValidationResult> results = new LinkedHashMap<>();
    
    // Oracle error codes for prerequisite creation
    private static final String ORA_NAME_ALREADY_USED = "ORA-00955";
    private static final String ORA_INSUFFICIENT_PRIVILEGES = "ORA-01031";
    private static final String ORA_ROLE_NOT_EXIST = "ORA-01919";
    
    // Oracle error codes that indicate acceptable failures (ONLY privilege/edition issues)
    private static final Set<String> ACCEPTABLE_ERROR_PREFIXES = Set.of(
        "ORA-01031", // insufficient privileges
        "ORA-28447", // insufficient privilege for ALTER DATABASE DICTIONARY
        "ORA-65040", // operation not allowed from within pluggable database
        "ORA-65090", // operation not allowed on a pluggable database container
        "ORA-65118", // operation affecting a pluggable database cannot be performed from another pluggable database
        "ORA-38301"  // flashback requires Enterprise Edition
    );

    @BeforeAll
    public static void setUp() throws SQLException {
        connection = DriverManager.getConnection(
                oracleContainer.getJdbcUrl(),
                oracleContainer.getUsername(),
                oracleContainer.getPassword()
        );
        
        // Create prerequisite database objects
        createPrerequisites(connection);
    }

    @AfterAll
    public static void tearDown() throws SQLException {
        if (connection != null && !connection.isClosed()) {
            connection.close();
        }
        
        // Print summary report
        printSummaryReport();
    }

    /**
     * Create prerequisite database objects needed by the SQL statements
     */
    private static void createPrerequisites(Connection conn) {
        List<String> prerequisites = Arrays.asList(
            // Create basic tables for DML operations
            "CREATE TABLE employees (employee_id NUMBER PRIMARY KEY, name VARCHAR2(100), first_name VARCHAR2(50), last_name VARCHAR2(50), department VARCHAR2(50), department_id NUMBER, salary NUMBER, hire_date DATE, email VARCHAR2(100))",
            "CREATE TABLE departments (dept_id NUMBER PRIMARY KEY, dept_name VARCHAR2(100), location VARCHAR2(100), manager_id NUMBER)",
            "CREATE TABLE orders (order_id NUMBER PRIMARY KEY, customer_id NUMBER, order_date DATE, status VARCHAR2(20), total_amount NUMBER)",
            "CREATE TABLE customers (customer_id NUMBER PRIMARY KEY, customer_name VARCHAR2(100), email VARCHAR2(100), phone VARCHAR2(20))",
            "CREATE TABLE products (product_id NUMBER PRIMARY KEY, product_name VARCHAR2(100), price NUMBER, category VARCHAR2(50))",
            "CREATE TABLE order_items (order_item_id NUMBER PRIMARY KEY, order_id NUMBER, product_id NUMBER, quantity NUMBER, unit_price NUMBER)",
            "CREATE TABLE sales (sale_id NUMBER PRIMARY KEY, sale_date DATE, amount NUMBER, region VARCHAR2(50), product_id NUMBER)",
            "CREATE TABLE documents (doc_id NUMBER PRIMARY KEY, title VARCHAR2(200), content CLOB)",
            
            // Create sequences - many more for ALTER SEQUENCE tests
            "CREATE SEQUENCE emp_seq START WITH 1",
            "CREATE SEQUENCE dept_seq START WITH 1",
            "CREATE SEQUENCE bounded_seq START WITH 1 MINVALUE 1 MAXVALUE 1000",
            "CREATE SEQUENCE nocycle_seq START WITH 1",
            "CREATE SEQUENCE cycling_seq START WITH 1 CYCLE",
            "CREATE SEQUENCE cached_seq START WITH 1 CACHE 20",
            "CREATE SEQUENCE nocache_seq START WITH 1 NOCACHE",
            "CREATE SEQUENCE noorder_seq START WITH 1 NOORDER",
            "CREATE SEQUENCE ordered_seq START WITH 1 ORDER",
            "CREATE SEQUENCE seq_with_min START WITH 10 MINVALUE 10",
            "CREATE SEQUENCE seq_with_max START WITH 1 MAXVALUE 9999",
            "CREATE SEQUENCE comprehensive_seq START WITH 1",
            "CREATE SEQUENCE countdown_seq START WITH 100",
            "CREATE SEQUENCE high_volume_seq START WITH 1",
            
            // Create many indexes for ALTER INDEX tests
            "CREATE INDEX emp_name_idx ON employees(name)",
            "CREATE INDEX emp_salary_idx ON employees(salary)",
            "CREATE INDEX emp_large_idx ON employees(employee_id)",
            "CREATE INDEX emp_fast_rebuild_idx ON employees(hire_date)",
            "CREATE INDEX emp_idx ON employees(department)",
            "CREATE INDEX emp_stats_idx ON employees(email)",
            "CREATE INDEX emp_composite_idx ON employees(department, salary)",
            "CREATE INDEX emp_compressed_idx ON employees(first_name, last_name)",
            "CREATE INDEX emp_reverse_idx ON employees(employee_id)",
            "CREATE INDEX emp_old_name_idx ON employees(name)",
            "CREATE INDEX emp_invisible_idx ON employees(department_id)",
            "CREATE INDEX emp_visible_idx ON employees(salary)",
            
            // Create views for ALTER VIEW tests
            "CREATE VIEW emp_dept_view AS SELECT e.employee_id, e.name, d.dept_name FROM employees e, departments d WHERE e.department = d.dept_name",
            "CREATE VIEW simple_emp_view AS SELECT employee_id, name, salary FROM employees",
            "CREATE VIEW dept_summary_view AS SELECT dept_name, COUNT(*) as emp_count FROM employees e, departments d WHERE e.department = d.dept_name GROUP BY dept_name",
            "CREATE VIEW high_earners AS SELECT * FROM employees WHERE salary > 50000",
            
            // Create a simple type
            "CREATE OR REPLACE TYPE address_type AS OBJECT (street VARCHAR2(100), city VARCHAR2(50), state VARCHAR2(2), zip NUMBER)",
            
            // Create roles for SET ROLE testing
            "CREATE ROLE warehouse_manager",
            "CREATE ROLE order_entry",
            "CREATE ROLE shipping_clerk",
            "CREATE ROLE developer",
            "CREATE ROLE dba",
            "CREATE ROLE tester",
            "CREATE ROLE secure_role",
            "CREATE ROLE global_role",
            "CREATE ROLE dba_role",
            
            // Grant roles to test user
            "GRANT warehouse_manager TO " + oracleContainer.getUsername(),
            "GRANT order_entry TO " + oracleContainer.getUsername(),
            "GRANT shipping_clerk TO " + oracleContainer.getUsername(),
            "GRANT developer TO " + oracleContainer.getUsername(),
            "GRANT dba TO " + oracleContainer.getUsername(),
            "GRANT tester TO " + oracleContainer.getUsername(),
            "GRANT secure_role TO " + oracleContainer.getUsername(),
            "GRANT global_role TO " + oracleContainer.getUsername(),
            "GRANT dba_role TO " + oracleContainer.getUsername(),
            
            // Create tablespace for testing
            "CREATE TABLESPACE test_ts DATAFILE SIZE 50M",
            "CREATE TABLESPACE new_tablespace DATAFILE SIZE 50M",
            
            // Create profile for ALTER PROFILE testing
            "CREATE PROFILE test_profile LIMIT SESSIONS_PER_USER 10",
            "CREATE PROFILE app_profile LIMIT SESSIONS_PER_USER 5 CPU_PER_SESSION 10000",
            
            // Create materialized view
            "CREATE MATERIALIZED VIEW emp_summary AS SELECT department, COUNT(*) as emp_count FROM employees GROUP BY department",
            "CREATE MATERIALIZED VIEW sales_summary AS SELECT region, SUM(amount) as total FROM sales GROUP BY region"
        );

        try (Statement stmt = conn.createStatement()) {
            for (String sql : prerequisites) {
                try {
                    stmt.execute(sql);
                    System.out.println("Created prerequisite: " + sql.substring(0, Math.min(50, sql.length())) + "...");
                } catch (SQLException e) {
                    // Ignore errors for objects that already exist or can't be created
                    if (!e.getMessage().contains(ORA_NAME_ALREADY_USED) && // name already used
                        !e.getMessage().contains(ORA_INSUFFICIENT_PRIVILEGES) && // insufficient privileges
                        !e.getMessage().contains(ORA_ROLE_NOT_EXIST)) { // role does not exist
                        System.err.println("Warning creating prerequisite: " + e.getMessage());
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("Error setting up prerequisites: " + e.getMessage());
        }
    }

    @Test
    @Order(1)
    public void testAllProbablyFailingSqlFiles() throws IOException {
        Path probablyFailingPath = Paths.get(PROBABLY_FAILING_DIR);
        
        if (!Files.exists(probablyFailingPath)) {
            Assertions.fail("Directory not found: " + PROBABLY_FAILING_DIR);
            return;
        }

        List<Path> sqlFiles = Files.walk(probablyFailingPath)
                .filter(Files::isRegularFile)
                .filter(p -> p.toString().endsWith(".sql"))
                .sorted()
                .collect(Collectors.toList());

        System.out.println("\n========================================");
        System.out.println("Testing " + sqlFiles.size() + " SQL files from probably_failing directory");
        System.out.println("========================================\n");

        for (Path sqlFile : sqlFiles) {
            testSqlFile(sqlFile);
        }
    }

    private void testSqlFile(Path sqlFile) {
        String fileName = sqlFile.getFileName().toString();
        System.out.println("\n--- Testing file: " + fileName + " ---");

        try {
            String content = Files.readString(sqlFile);
            List<String> statements = splitSqlStatements(content);
            
            int passCount = 0;
            int failCount = 0;
            List<String> failedStatements = new ArrayList<>();
            List<String> passedStatements = new ArrayList<>();

            for (String statement : statements) {
                String cleanStmt = statement.trim();
                if (cleanStmt.isEmpty() || cleanStmt.startsWith("--")) {
                    continue;
                }

                try {
                    validateStatement(cleanStmt);
                    passCount++;
                    passedStatements.add(cleanStmt.substring(0, Math.min(60, cleanStmt.length())));
                    System.out.println("  ✓ PASSED: " + cleanStmt.substring(0, Math.min(60, cleanStmt.length())) + "...");
                } catch (SQLException e) {
                    // Check if this is an acceptable error (privilege/edition issue)
                    if (isAcceptableError(e)) {
                        passCount++;
                        passedStatements.add(cleanStmt.substring(0, Math.min(60, cleanStmt.length())) + " [acceptable: " + getErrorCode(e.getMessage()) + "]");
                        System.out.println("  ✓ PASSED (privilege/edition): " + cleanStmt.substring(0, Math.min(60, cleanStmt.length())) + "...");
                        System.out.println("    Reason: " + getErrorCode(e.getMessage()));
                    } else {
                        failCount++;
                        failedStatements.add(cleanStmt.substring(0, Math.min(60, cleanStmt.length())) + " [" + e.getMessage() + "]");
                        System.out.println("  ✗ FAILED: " + cleanStmt.substring(0, Math.min(60, cleanStmt.length())) + "...");
                        System.out.println("    Error: " + e.getMessage());
                    }
                }
            }

            results.put(fileName, new ValidationResult(passCount, failCount, passedStatements, failedStatements));
            
            System.out.println("\nFile Summary: " + passCount + " passed, " + failCount + " failed");

        } catch (IOException e) {
            System.err.println("Error reading file " + fileName + ": " + e.getMessage());
            results.put(fileName, new ValidationResult(0, -1, Collections.emptyList(), 
                Collections.singletonList("Error reading file: " + e.getMessage())));
        }
    }

    /**
     * Validate a SQL statement by preparing it (syntax check only)
     */
    private void validateStatement(String statement) throws SQLException {
        // For DDL statements, we can't use PreparedStatement, so we use EXPLAIN PLAN or parse check
        // We'll use Oracle's DBMS_SQL.PARSE for syntax validation without execution
        
        // For most statements, we'll try to create a dummy block that won't execute
        String validationSql = "DECLARE " +
                "  v_cursor INTEGER; " +
                "BEGIN " +
                "  v_cursor := DBMS_SQL.OPEN_CURSOR; " +
                "  DBMS_SQL.PARSE(v_cursor, ?, DBMS_SQL.NATIVE); " +
                "  DBMS_SQL.CLOSE_CURSOR(v_cursor); " +
                "EXCEPTION " +
                "  WHEN OTHERS THEN " +
                "    IF DBMS_SQL.IS_OPEN(v_cursor) THEN " +
                "      DBMS_SQL.CLOSE_CURSOR(v_cursor); " +
                "    END IF; " +
                "    RAISE; " +
                "END;";
        
        try (PreparedStatement pstmt = connection.prepareStatement(validationSql)) {
            pstmt.setString(1, statement);
            pstmt.execute();
        }
    }

    /**
     * Check if an error is acceptable (privilege or edition limitation ONLY)
     */
    private boolean isAcceptableError(SQLException e) {
        String message = e.getMessage();
        if (message == null) {
            return false;
        }
        
        // Check for acceptable error codes
        for (String errorPrefix : ACCEPTABLE_ERROR_PREFIXES) {
            if (message.contains(errorPrefix)) {
                return true;
            }
        }
        
        // Check for specific error messages indicating privilege/edition issues ONLY
        String lowerMessage = message.toLowerCase();
        return lowerMessage.contains("insufficient privilege") ||
               lowerMessage.contains("enterprise edition") ||
               lowerMessage.contains("requires enterprise") ||
               lowerMessage.contains("not allowed from within pluggable");
    }

    /**
     * Extract error code from error message
     */
    private String getErrorCode(String message) {
        if (message == null) {
            return "Unknown error";
        }
        
        // Extract ORA-XXXXX error code
        int oraIndex = message.indexOf("ORA-");
        if (oraIndex >= 0 && oraIndex + 9 <= message.length()) {
            return message.substring(oraIndex, oraIndex + 9);
        }
        
        return message.substring(0, Math.min(100, message.length()));
    }

    /**
     * Split SQL file content into individual statements
     * Handles:
     * - Semicolon-terminated statements
     * - Slash-terminated statements (PL/SQL blocks, MLE modules)
     * - Does not split within JavaScript blocks (MLE) or PL/SQL blocks
     */
    private List<String> splitSqlStatements(String content) {
        List<String> statements = new ArrayList<>();
        StringBuilder currentStatement = new StringBuilder();
        boolean inComment = false;
        boolean inString = false;
        boolean inJavaScriptBlock = false;
        boolean inPlSqlBlock = false;
        int plsqlDepth = 0; // Track nested BEGIN/END blocks
        
        String[] lines = content.split("\n");
        for (String line : lines) {
            String trimmedLine = line.trim();
            String upperLine = trimmedLine.toUpperCase();
            
            // Skip pure comment lines
            if (trimmedLine.startsWith("--")) {
                continue;
            }
            
            // Handle multi-line comments
            if (trimmedLine.contains("/*")) {
                inComment = true;
            }
            if (trimmedLine.contains("*/")) {
                inComment = false;
                continue;
            }
            if (inComment) {
                continue;
            }
            
            // Remove inline comments
            int commentPos = line.indexOf("--");
            if (commentPos >= 0 && !isInString(line, commentPos)) {
                line = line.substring(0, commentPos);
                trimmedLine = line.trim();
                upperLine = trimmedLine.toUpperCase();
            }
            
            // Detect JavaScript blocks in MLE modules
            if (upperLine.contains("LANGUAGE") && upperLine.contains("JAVASCRIPT") && upperLine.contains("AS")) {
                inJavaScriptBlock = true;
            }
            
            // Detect PL/SQL blocks
            if (upperLine.startsWith("BEGIN") || upperLine.startsWith("DECLARE")) {
                inPlSqlBlock = true;
                plsqlDepth = 1;
            } else if (inPlSqlBlock) {
                // Count BEGIN/END nesting
                if (upperLine.contains("BEGIN")) {
                    plsqlDepth++;
                }
                if (upperLine.contains("END;") || upperLine.equals("END")) {
                    plsqlDepth--;
                    if (plsqlDepth == 0) {
                        inPlSqlBlock = false;
                    }
                }
            }
            
            currentStatement.append(line).append("\n");
            
            // Check for statement terminator
            // 1. Slash on its own line terminates JavaScript blocks and PL/SQL blocks
            if (trimmedLine.equals("/")) {
                inJavaScriptBlock = false;
                inPlSqlBlock = false;
                plsqlDepth = 0;
                String stmt = currentStatement.toString().trim();
                if (!stmt.isEmpty() && !stmt.equals("/")) {
                    // Remove trailing slash
                    if (stmt.endsWith("/")) {
                        stmt = stmt.substring(0, stmt.length() - 1).trim();
                    }
                    statements.add(stmt);
                }
                currentStatement = new StringBuilder();
            }
            // 2. Semicolon terminates regular SQL statements (but not within JS/PL SQL blocks)
            else if (trimmedLine.endsWith(";") && !inJavaScriptBlock && !inPlSqlBlock) {
                String stmt = currentStatement.toString().trim();
                if (!stmt.isEmpty()) {
                    // Remove trailing semicolon
                    if (stmt.endsWith(";")) {
                        stmt = stmt.substring(0, stmt.length() - 1).trim();
                    }
                    statements.add(stmt);
                }
                currentStatement = new StringBuilder();
            }
        }
        
        // Add any remaining statement
        String stmt = currentStatement.toString().trim();
        if (!stmt.isEmpty() && !stmt.equals("/")) {
            if (stmt.endsWith(";")) {
                stmt = stmt.substring(0, stmt.length() - 1).trim();
            }
            if (stmt.endsWith("/")) {
                stmt = stmt.substring(0, stmt.length() - 1).trim();
            }
            if (!stmt.isEmpty()) {
                statements.add(stmt);
            }
        }
        
        return statements;
    }

    private boolean isInString(String line, int position) {
        boolean inString = false;
        for (int i = 0; i < position && i < line.length(); i++) {
            if (line.charAt(i) == '\'') {
                inString = !inString;
            }
        }
        return inString;
    }

    private static void printSummaryReport() {
        System.out.println("\n\n========================================");
        System.out.println("         VALIDATION SUMMARY REPORT      ");
        System.out.println("========================================\n");

        int totalFiles = results.size();
        int filesWithAllPass = 0;
        int filesWithSomeFail = 0;
        int totalStatementsPassed = 0;
        int totalStatementsFailed = 0;

        for (Map.Entry<String, ValidationResult> entry : results.entrySet()) {
            String fileName = entry.getKey();
            ValidationResult result = entry.getValue();
            
            totalStatementsPassed += result.passCount;
            totalStatementsFailed += result.failCount;
            
            if (result.failCount == 0 && result.passCount > 0) {
                filesWithAllPass++;
            } else if (result.failCount > 0) {
                filesWithSomeFail++;
            }

            System.out.println("File: " + fileName);
            System.out.println("  Passed: " + result.passCount);
            System.out.println("  Failed: " + result.failCount);
            
            if (!result.failedStatements.isEmpty()) {
                System.out.println("  Failed statements:");
                for (String failedStmt : result.failedStatements) {
                    System.out.println("    - " + failedStmt);
                }
            }
            System.out.println();
        }

        System.out.println("========================================");
        System.out.println("OVERALL STATISTICS");
        System.out.println("========================================");
        System.out.println("Total files tested: " + totalFiles);
        System.out.println("Files with all statements passing: " + filesWithAllPass);
        System.out.println("Files with some failures: " + filesWithSomeFail);
        System.out.println("Total statements passed: " + totalStatementsPassed);
        System.out.println("Total statements failed: " + totalStatementsFailed);
        
        double successRate = totalStatementsPassed + totalStatementsFailed > 0 
            ? (totalStatementsPassed * 100.0) / (totalStatementsPassed + totalStatementsFailed)
            : 0;
        System.out.println("Success rate: " + String.format("%.2f", successRate) + "%");
        System.out.println("========================================\n");
    }

    private static class ValidationResult {
        final int passCount;
        final int failCount;
        final List<String> passedStatements;
        final List<String> failedStatements;

        ValidationResult(int passCount, int failCount, List<String> passedStatements, List<String> failedStatements) {
            this.passCount = passCount;
            this.failCount = failCount;
            this.passedStatements = passedStatements;
            this.failedStatements = failedStatements;
        }
    }
}
