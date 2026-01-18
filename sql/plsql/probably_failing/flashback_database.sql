-- FLASHBACK DATABASE statement examples
-- This statement is not currently supported by the PlSql grammar
-- FLASHBACK DATABASE was introduced in Oracle 10g

-- Flashback to a restore point
FLASHBACK DATABASE TO RESTORE POINT cdb_grp;
FLASHBACK DATABASE TO RESTORE POINT before_upgrade;
FLASHBACK DATABASE TO RESTORE POINT daily_backup;

-- Flashback to a specific SCN (System Change Number)
FLASHBACK DATABASE TO SCN 34468;
FLASHBACK DATABASE TO SCN 1234567890;

-- Flashback to before a specific SCN
FLASHBACK DATABASE TO BEFORE SCN 34500;

-- Flashback to a specific timestamp
FLASHBACK DATABASE TO TIMESTAMP TO_TIMESTAMP('2013-11-05 14:00:00', 'YYYY-MM-DD HH24:MI:SS');
FLASHBACK DATABASE TO TIMESTAMP SYSDATE - 1/24;  -- 1 hour ago
FLASHBACK DATABASE TO TIMESTAMP SYSDATE - 1;     -- 1 day ago

-- Flashback to before a specific timestamp
FLASHBACK DATABASE TO BEFORE TIMESTAMP TO_TIMESTAMP('2025-01-18 10:00:00', 'YYYY-MM-DD HH24:MI:SS');

-- Flashback pluggable database
FLASHBACK PLUGGABLE DATABASE pdb1 TO RESTORE POINT my_restore_point;
FLASHBACK PLUGGABLE DATABASE pdb1 TO SCN 9876543210;
FLASHBACK PLUGGABLE DATABASE pdb1 TO TIMESTAMP SYSDATE - 1;
FLASHBACK PLUGGABLE DATABASE pdb1 TO BEFORE TIMESTAMP SYSDATE - 2;
FLASHBACK PLUGGABLE DATABASE pdb1 TO BEFORE SCN 9876543211;

-- Flashback multiple pluggable databases
FLASHBACK PLUGGABLE DATABASE pdb1, pdb2 TO RESTORE POINT common_restore_point;

-- Flashback with RESETLOGS (after opening database)
-- Note: FLASHBACK DATABASE returns database to MOUNT state
-- After flashback, you typically:
-- ALTER DATABASE OPEN RESETLOGS;
