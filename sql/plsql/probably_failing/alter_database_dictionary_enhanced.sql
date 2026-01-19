-- ALTER DATABASE DICTIONARY statement validation file
-- Oracle Database 12.2+ Enterprise Edition with Advanced Security Option required
--
-- IMPORTANT: These statements require:
-- 1. Oracle Enterprise Edition (NOT available in XE)
-- 2. Advanced Security Option license
-- 3. TDE (Transparent Data Encryption) configured
-- 4. Oracle Wallet configured and open
-- 5. SYSDBA privileges
--
-- These statements manage encryption of sensitive data in the data dictionary,
-- specifically passwords for database links and other obfuscated credentials.

-- Prerequisites check (informational - would need to be run separately)
-- SELECT * FROM V$OPTION WHERE PARAMETER = 'Advanced Security';
-- SELECT * FROM V$ENCRYPTION_WALLET;

-- ==============================================================================
-- Statement 1: Encrypt existing credentials in data dictionary
-- ==============================================================================
-- Purpose: Encrypt all existing and future obfuscated sensitive information
-- Target: Passwords in SYS.LINK$ and related data dictionary tables
-- Effect: Sensitive data is encrypted using TDE, key stored in wallet
-- Prerequisites:
--   - TDE wallet must be configured and open
--   - SYSDBA privilege required
--   - Advanced Security Option must be licensed
-- Expected Result: Success if prerequisites met, otherwise ORA-28365 or similar

ALTER DATABASE DICTIONARY ENCRYPT CREDENTIALS;

-- ==============================================================================
-- Statement 2: Rekey encrypted credentials
-- ==============================================================================
-- Purpose: Change the encryption key for data dictionary credentials
-- Target: All encrypted credentials in data dictionary
-- Effect: Credentials are decrypted with old key, reencrypted with new key
-- Prerequisites:
--   - Credentials must already be encrypted (previous statement executed)
--   - TDE wallet must be open
--   - SYSDBA privilege required
-- Expected Result: Success if credentials already encrypted, ORA-28400 if not encrypted

ALTER DATABASE DICTIONARY REKEY CREDENTIALS;

-- ==============================================================================
-- Statement 3: Delete credentials encryption key
-- ==============================================================================
-- Purpose: Remove encryption key, making encrypted credentials unusable
-- Target: The encryption key for data dictionary credentials
-- Effect: Encrypted passwords marked unusable, key permanently deleted
-- Prerequisites:
--   - Credentials must be encrypted
--   - SYSDBA privilege required
-- WARNING: This is DESTRUCTIVE - encrypted passwords cannot be recovered
-- Expected Result: Success if encrypted, ORA-28400 if not encrypted

ALTER DATABASE DICTIONARY DELETE CREDENTIALS KEY;

-- ==============================================================================
-- Validation Results
-- ==============================================================================
--
-- SQL SYNTAX: ✓ VALID (per Oracle 12.2+ documentation)
-- ORACLE VERSION: ✓ Correct version specified (12.2+)
-- STATEMENT PURPOSE: ✓ Valid Oracle commands
-- TESTABILITY: ⚠ Requires Enterprise Edition + Advanced Security Option
--
-- These statements are syntactically correct and semantically valid Oracle SQL.
-- However, they cannot be tested on Oracle XE or Standard Edition.
--
-- For grammar validation purposes, parsing these statements successfully
-- is sufficient proof of correctness.
--
-- References:
-- - Oracle Database Security Guide, Release 12.2
-- - Oracle Database SQL Language Reference, ALTER DATABASE
-- - Oracle Advanced Security Administrator's Guide
