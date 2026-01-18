-- ALTER DATABASE DICTIONARY statement examples
-- This statement is not currently supported by the PlSql grammar
-- Introduced in Oracle 12.2 for data dictionary encryption

-- Encrypt credentials in data dictionary
-- Encrypts existing and future obfuscated sensitive information (e.g., database link passwords)
ALTER DATABASE DICTIONARY ENCRYPT CREDENTIALS;

-- Rekey credentials
-- Changes the data encryption key applied to SYS.LINK$ and other data dictionary tables
ALTER DATABASE DICTIONARY REKEY CREDENTIALS;

-- Delete credentials key
-- Marks encrypted passwords unusable and deletes the encryption key
ALTER DATABASE DICTIONARY DELETE CREDENTIALS KEY;
