package org.antlr.plsql;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.testcontainers.containers.OracleContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Test class to validate SQL statements from alter_database_dictionary.sql
 * against a real Oracle database using Testcontainers.
 */
@Testcontainers
public class AlterDatabaseDictionaryTest {

    @Container
    private static final OracleContainer oracle = new OracleContainer("gvenzl/oracle-xe:21-slim-faststart")
            .withDatabaseName("testdb")
            .withUsername("testuser")
            .withPassword("testpass")
            .withReuse(false);

    private static Connection connection;

    @BeforeAll
    static void setup() throws SQLException {
        // Get connection as SYS with SYSDBA privileges for database-level operations
        String jdbcUrl = oracle.getJdbcUrl();
        connection = DriverManager.getConnection(jdbcUrl, "sys as sysdba", oracle.getPassword());
        System.out.println("Connected to Oracle database: " + jdbcUrl);
    }

    @AfterAll
    static void teardown() throws SQLException {
        if (connection != null && !connection.isClosed()) {
            connection.close();
        }
    }

    @Test
    public void testAlterDatabaseDictionary() throws IOException, SQLException {
        // Read the SQL file
        Path sqlFilePath = Paths.get("probably_failing/alter_database_dictionary.sql");
        String sqlContent = Files.readString(sqlFilePath);

        // Extract SQL statements (ignore comments and empty lines)
        List<String> statements = extractStatements(sqlContent);

        System.out.println("\n========================================");
        System.out.println("Testing ALTER DATABASE DICTIONARY statements");
        System.out.println("========================================\n");

        boolean allSucceeded = true;

        for (int i = 0; i < statements.size(); i++) {
            String stmt = statements.get(i);
            System.out.println("Statement " + (i + 1) + ": " + stmt);

            try (Statement sqlStatement = connection.createStatement()) {
                // Try to execute the statement
                sqlStatement.execute(stmt);
                System.out.println("✓ SUCCESS: Statement executed successfully\n");
            } catch (SQLException e) {
                allSucceeded = false;
                System.out.println("✗ FAILED: " + e.getMessage());
                System.out.println("Error Code: " + e.getErrorCode());
                System.out.println("SQL State: " + e.getSQLState());

                // Analyze the error
                analyzeError(e, stmt);
                System.out.println();
            }
        }

        System.out.println("========================================");
        if (allSucceeded) {
            System.out.println("All statements executed successfully!");
        } else {
            System.out.println("Some statements failed. See details above.");
        }
        System.out.println("========================================\n");
    }

    /**
     * Extract SQL statements from the file content.
     * Ignores comments and empty lines.
     */
    private List<String> extractStatements(String content) {
        List<String> statements = new ArrayList<>();

        // Split by semicolon and filter out comments
        String[] lines = content.split("\n");
        StringBuilder currentStatement = new StringBuilder();

        for (String line : lines) {
            String trimmedLine = line.trim();

            // Skip comment lines
            if (trimmedLine.startsWith("--") || trimmedLine.isEmpty()) {
                continue;
            }

            currentStatement.append(line).append("\n");

            // If line ends with semicolon, it's the end of a statement
            if (trimmedLine.endsWith(";")) {
                String stmt = currentStatement.toString().trim();
                // Remove the trailing semicolon and any comments
                stmt = stmt.replaceAll(";\\s*$", "");

                // Remove inline comments
                stmt = stmt.replaceAll("--.*$", "").trim();

                if (!stmt.isEmpty()) {
                    statements.add(stmt);
                }
                currentStatement = new StringBuilder();
            }
        }

        // Add any remaining statement
        if (currentStatement.length() > 0) {
            String stmt = currentStatement.toString().trim();
            stmt = stmt.replaceAll(";\\s*$", "");
            stmt = stmt.replaceAll("--.*$", "").trim();
            if (!stmt.isEmpty()) {
                statements.add(stmt);
            }
        }

        return statements;
    }

    /**
     * Analyze the error and provide insights about why it failed.
     */
    private void analyzeError(SQLException e, String statement) {
        int errorCode = e.getErrorCode();
        String message = e.getMessage();

        System.out.println("\nError Analysis:");

        // Common Oracle error codes
        switch (errorCode) {
            case 1031:
                System.out.println("- Missing privileges. This operation requires SYSDBA or specific database privileges.");
                System.out.println("- ALTER DATABASE DICTIONARY is a highly privileged operation.");
                break;
            case 900:
            case 901:
            case 902:
            case 903:
            case 904:
            case 905:
                System.out.println("- Syntax error or unsupported statement.");
                System.out.println("- This statement might not be supported in this Oracle version.");
                System.out.println("- Oracle XE 21c may not support all features available in Enterprise Edition.");
                break;
            case 1950:
                System.out.println("- Missing database privileges.");
                break;
            case 65000:
            case 65001:
            case 65535:
                System.out.println("- Feature might not be available in Oracle XE (Express Edition).");
                System.out.println("- ALTER DATABASE DICTIONARY encryption may require Enterprise Edition.");
                break;
            default:
                if (message.toLowerCase().contains("dictionary")) {
                    System.out.println("- This is a data dictionary operation requiring special privileges.");
                }
                if (message.toLowerCase().contains("unsupported") ||
                    message.toLowerCase().contains("invalid") ||
                    message.toLowerCase().contains("unknown")) {
                    System.out.println("- The statement syntax may not be supported in this Oracle version/edition.");
                    System.out.println("- ALTER DATABASE DICTIONARY was introduced in Oracle 12.2 and may have edition restrictions.");
                }
        }

        System.out.println("\nPossible reasons for failure:");
        System.out.println("1. Oracle XE (Express Edition) doesn't support this feature");
        System.out.println("2. Feature requires Oracle Enterprise Edition");
        System.out.println("3. Oracle version is too old (feature introduced in 12.2)");
        System.out.println("4. Database not in appropriate mode for this operation");
        System.out.println("5. Additional database configuration required");
    }
}
