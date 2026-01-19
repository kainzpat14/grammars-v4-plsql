-- ALTER TABLE FLASHBACK ARCHIVE operations
-- Tests enabling, modifying, and disabling Flashback Data Archive

-- Enable Flashback Archive on a table
ALTER TABLE employees FLASHBACK ARCHIVE fda1;

-- Enable Flashback Archive with default FDA
ALTER TABLE orders FLASHBACK ARCHIVE;

-- Modify Flashback Archive - change to different FDA
ALTER TABLE customers FLASHBACK ARCHIVE fda_archive;

-- Disable Flashback Archive (stop tracking, keep historical data)
ALTER TABLE temp_table NO FLASHBACK ARCHIVE;

-- Enable with specific flashback archive name
ALTER TABLE products FLASHBACK ARCHIVE product_history_fda;

-- Enable flashback for partitioned table
ALTER TABLE sales_partitioned FLASHBACK ARCHIVE sales_fda;

-- Re-enable after disabling
ALTER TABLE test_table FLASHBACK ARCHIVE test_fda;

-- Enable for table with LOBs
ALTER TABLE documents FLASHBACK ARCHIVE doc_fda;

-- Combine with other ALTER TABLE operations
ALTER TABLE mixed_operations ADD (new_col VARCHAR2(50));
ALTER TABLE mixed_operations FLASHBACK ARCHIVE mixed_fda;

-- Enable flashback archive on table with constraints
ALTER TABLE constrained_table FLASHBACK ARCHIVE fda_main;

-- Switch from one FDA to another
ALTER TABLE migrating_table FLASHBACK ARCHIVE new_fda;

-- Examples with table context
-- First create the Flashback Data Archive (separate statement, shown for context)
-- CREATE FLASHBACK ARCHIVE fda_5year TABLESPACE fda_ts RETENTION 5 YEAR;

-- Then enable it on tables
ALTER TABLE audit_log FLASHBACK ARCHIVE fda_5year;
ALTER TABLE transactions FLASHBACK ARCHIVE fda_5year;

-- Disable and re-enable (useful for maintenance)
ALTER TABLE maintenance_table NO FLASHBACK ARCHIVE;
-- ... perform maintenance ...
ALTER TABLE maintenance_table FLASHBACK ARCHIVE fda_main;

-- Enable on multiple related tables
ALTER TABLE parent_table FLASHBACK ARCHIVE relation_fda;
ALTER TABLE child_table FLASHBACK ARCHIVE relation_fda;

-- Enable flashback with quota specification (done at FDA level)
-- But showing table enablement after FDA has quota set
ALTER TABLE large_history_table FLASHBACK ARCHIVE fda_unlimited;
