package org.antlr.grammars.plsql;

import org.junit.jupiter.api.*;
import org.testcontainers.containers.OracleContainer;
import org.testcontainers.containers.wait.strategy.Wait;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;

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
    private static final OracleContainer oracleContainer = new OracleContainer("gvenzl/oracle-xe:18-slim")
            .withReuse(false)
            .withStartupTimeout(Duration.ofMinutes(10));

    private static Connection connection;
    private static final String PROBABLY_FAILING_DIR = "probably_failing";
    private static final Map<String, ValidationResult> results = new LinkedHashMap<>();
    
    // Oracle error codes for prerequisite creation
    private static final String ORA_NAME_ALREADY_USED = "ORA-00955";
    private static final String ORA_INSUFFICIENT_PRIVILEGES = "ORA-01031";
    private static final String ORA_ROLE_NOT_EXIST = "ORA-01919";

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
            "CREATE TABLE employees (employee_id NUMBER PRIMARY KEY, name VARCHAR2(100), department VARCHAR2(50), salary NUMBER)",
            "CREATE TABLE departments (dept_id NUMBER PRIMARY KEY, dept_name VARCHAR2(100), location VARCHAR2(100))",
            "CREATE TABLE orders (order_id NUMBER PRIMARY KEY, customer_id NUMBER, order_date DATE, status VARCHAR2(20))",
            "CREATE TABLE customers (customer_id NUMBER PRIMARY KEY, customer_name VARCHAR2(100), email VARCHAR2(100))",
            "CREATE TABLE products (product_id NUMBER PRIMARY KEY, product_name VARCHAR2(100), price NUMBER)",
            "CREATE TABLE order_items (order_item_id NUMBER PRIMARY KEY, order_id NUMBER, product_id NUMBER, quantity NUMBER)",
            "CREATE TABLE sales (sale_id NUMBER PRIMARY KEY, sale_date DATE, amount NUMBER, region VARCHAR2(50))",
            
            // Create sequences
            "CREATE SEQUENCE emp_seq START WITH 1",
            "CREATE SEQUENCE dept_seq START WITH 1",
            
            // Create basic indexes
            "CREATE INDEX emp_name_idx ON employees(name)",
            
            // Create basic views
            "CREATE VIEW emp_dept_view AS SELECT e.employee_id, e.name, d.dept_name FROM employees e JOIN departments d ON e.department = d.dept_name",
            
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
            
            // Create profile for ALTER PROFILE testing
            "CREATE PROFILE test_profile LIMIT SESSIONS_PER_USER 10",
            
            // Create indextype placeholder (requires implementation type which is complex)
            // Skipping for now as it requires CREATE TYPE BODY
            
            // Create basic materialized view
            "CREATE MATERIALIZED VIEW emp_summary AS SELECT department, COUNT(*) as emp_count FROM employees GROUP BY department"
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
                    failCount++;
                    failedStatements.add(cleanStmt.substring(0, Math.min(60, cleanStmt.length())) + " [" + e.getMessage() + "]");
                    System.out.println("  ✗ FAILED: " + cleanStmt.substring(0, Math.min(60, cleanStmt.length())) + "...");
                    System.out.println("    Error: " + e.getMessage());
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
     * Split SQL file content into individual statements
     */
    private List<String> splitSqlStatements(String content) {
        List<String> statements = new ArrayList<>();
        StringBuilder currentStatement = new StringBuilder();
        boolean inComment = false;
        boolean inString = false;
        
        String[] lines = content.split("\n");
        for (String line : lines) {
            String trimmedLine = line.trim();
            
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
            }
            
            currentStatement.append(line).append("\n");
            
            // Check if statement ends with semicolon
            if (trimmedLine.endsWith(";")) {
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
        if (!stmt.isEmpty()) {
            if (stmt.endsWith(";")) {
                stmt = stmt.substring(0, stmt.length() - 1).trim();
            }
            statements.add(stmt);
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
