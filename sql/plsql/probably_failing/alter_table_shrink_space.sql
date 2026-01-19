-- ALTER TABLE SHRINK SPACE operations
-- Tests various SHRINK SPACE options: COMPACT, CASCADE

-- Basic shrink space (must enable row movement first)
ALTER TABLE employees ENABLE ROW MOVEMENT;
ALTER TABLE employees SHRINK SPACE;

-- Shrink space with COMPACT (doesn't adjust high water mark)
ALTER TABLE large_table SHRINK SPACE COMPACT;

-- Shrink space with CASCADE (includes dependent objects like indexes)
ALTER TABLE orders SHRINK SPACE CASCADE;

-- Shrink space with COMPACT and CASCADE
ALTER TABLE sales_history ENABLE ROW MOVEMENT;
ALTER TABLE sales_history SHRINK SPACE COMPACT CASCADE;

-- Shrink specific partition
ALTER TABLE sales_partitioned MODIFY PARTITION p_2023 SHRINK SPACE;

-- Shrink partition with COMPACT
ALTER TABLE sales_partitioned MODIFY PARTITION p_2024 SHRINK SPACE COMPACT;

-- Shrink partition with CASCADE
ALTER TABLE orders_partitioned MODIFY PARTITION p_q1 SHRINK SPACE CASCADE;

-- Shrink subpartition
ALTER TABLE complex_partitioned MODIFY SUBPARTITION sp_jan SHRINK SPACE;

-- Shrink subpartition with CHECK (validate only, don't shrink)
ALTER TABLE test_partitioned MODIFY SUBPARTITION sp_test SHRINK SPACE CHECK;

-- Shrink LOB segment
ALTER TABLE documents MODIFY LOB(doc_content) (SHRINK SPACE);

-- Shrink LOB segment with COMPACT
ALTER TABLE documents MODIFY LOB(doc_content) (SHRINK SPACE COMPACT);

-- Shrink LOB segment with CASCADE
ALTER TABLE documents MODIFY LOB(doc_content) (SHRINK SPACE CASCADE);

-- Shrink multiple operations in sequence
ALTER TABLE big_table ENABLE ROW MOVEMENT;
ALTER TABLE big_table SHRINK SPACE COMPACT;
-- Later, after verifying:
ALTER TABLE big_table SHRINK SPACE;

-- Shrink with ONLINE (if supported in newer versions)
ALTER TABLE active_table SHRINK SPACE CASCADE ONLINE;

-- Disable row movement after shrink
ALTER TABLE employees SHRINK SPACE;
ALTER TABLE employees DISABLE ROW MOVEMENT;

-- Shrink space for Index Organized Table (IOT)
ALTER TABLE iot_table SHRINK SPACE CASCADE;

-- Shrink overflow segment of IOT
ALTER TABLE iot_table OVERFLOW SHRINK SPACE;

-- Shrink space for materialized view
ALTER TABLE mv_sales SHRINK SPACE;

-- Combination with other operations
ALTER TABLE test_table ENABLE ROW MOVEMENT;
ALTER TABLE test_table SHRINK SPACE COMPACT;
ALTER TABLE test_table MODIFY (col1 VARCHAR2(200));
ALTER TABLE test_table SHRINK SPACE;
