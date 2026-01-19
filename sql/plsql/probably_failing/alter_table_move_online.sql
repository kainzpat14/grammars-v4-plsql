-- ALTER TABLE MOVE ONLINE operations
-- Tests moving entire tables online (Oracle 12.2+)

-- Basic online move to different tablespace
ALTER TABLE employees MOVE ONLINE;

-- Move to specific tablespace
ALTER TABLE large_table MOVE TABLESPACE new_tablespace ONLINE;

-- Move with UPDATE INDEXES
ALTER TABLE orders MOVE TABLESPACE faster_storage ONLINE UPDATE INDEXES;

-- Move with PARALLEL
ALTER TABLE big_table MOVE ONLINE PARALLEL 8;

-- Move with compression
ALTER TABLE archive_data MOVE ONLINE COMPRESS FOR QUERY HIGH;

-- Move with NOCOMPRESS
ALTER TABLE hot_data MOVE ONLINE NOCOMPRESS;

-- Move with tablespace and compression
ALTER TABLE sales_history
    MOVE TABLESPACE archive_ts
    ONLINE
    COMPRESS FOR ARCHIVE HIGH
    UPDATE INDEXES;

-- Move with parallel and update indexes
ALTER TABLE transactions
    MOVE TABLESPACE ssd_storage
    ONLINE
    PARALLEL 16
    UPDATE INDEXES;

-- Move with specific storage parameters
ALTER TABLE critical_data
    MOVE ONLINE
    STORAGE (INITIAL 200M NEXT 200M)
    UPDATE INDEXES;

-- Move with PCTFREE
ALTER TABLE customer_data
    MOVE ONLINE
    PCTFREE 20
    UPDATE INDEXES;

-- Move with INMEMORY
ALTER TABLE frequently_accessed
    MOVE ONLINE
    INMEMORY
    UPDATE INDEXES;

-- Move with NO INMEMORY
ALTER TABLE rarely_accessed
    MOVE ONLINE
    NO INMEMORY;

-- Complex move with multiple options
ALTER TABLE complex_table
    MOVE
    TABLESPACE new_ts
    PCTFREE 15
    INITRANS 10
    STORAGE (INITIAL 100M NEXT 100M)
    COMPRESS FOR OLTP
    ONLINE
    PARALLEL 12
    UPDATE INDEXES;

-- Move partition online (already supported, for completeness)
ALTER TABLE partitioned_table
    MOVE PARTITION p_2024
    TABLESPACE new_ts
    ONLINE
    UPDATE INDEXES;

-- Move with LOB storage specifications
ALTER TABLE documents
    MOVE ONLINE
    LOB (doc_content) STORE AS SECUREFILE (
        TABLESPACE lob_ts
        CACHE
        COMPRESS HIGH
    )
    UPDATE INDEXES;

-- Move Index Organized Table (IOT) online
ALTER TABLE iot_table MOVE ONLINE;

-- Move with prefix compression
ALTER TABLE iot_table
    MOVE ONLINE
    PREFIX COMPRESSION 5;

-- Move with including overflow
ALTER TABLE iot_with_overflow
    MOVE ONLINE INCLUDING OVERFLOW
    UPDATE INDEXES;

-- Move with filter condition (Oracle 19c+)
ALTER TABLE large_table
    MOVE ONLINE
    INCLUDING ROWS WHERE active_flag = 1
    UPDATE INDEXES;

-- Move without ONLINE (for comparison - traditional blocking move)
ALTER TABLE test_table MOVE TABLESPACE users;

-- Move to same tablespace but with different compression
ALTER TABLE sales
    MOVE ONLINE
    COMPRESS FOR QUERY LOW
    UPDATE INDEXES;
