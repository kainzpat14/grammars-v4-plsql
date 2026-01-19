-- ALTER SEQUENCE statement variations
-- Tests ALTER SEQUENCE with various modifications

-- ALTER SEQUENCE change INCREMENT BY
ALTER SEQUENCE emp_seq INCREMENT BY 5;

-- ALTER SEQUENCE change INCREMENT BY back to 1
ALTER SEQUENCE emp_seq INCREMENT BY 1;

-- ALTER SEQUENCE change MINVALUE
ALTER SEQUENCE bounded_seq MINVALUE 10;

-- ALTER SEQUENCE change MAXVALUE
ALTER SEQUENCE bounded_seq MAXVALUE 50000;

-- ALTER SEQUENCE add CYCLE
ALTER SEQUENCE nocycle_seq CYCLE;

-- ALTER SEQUENCE remove CYCLE
ALTER SEQUENCE cycling_seq NOCYCLE;

-- ALTER SEQUENCE change CACHE size
ALTER SEQUENCE cached_seq CACHE 50;

-- ALTER SEQUENCE change to NOCACHE
ALTER SEQUENCE cached_seq NOCACHE;

-- ALTER SEQUENCE change to CACHE from NOCACHE
ALTER SEQUENCE nocache_seq CACHE 100;

-- ALTER SEQUENCE add ORDER
ALTER SEQUENCE noorder_seq ORDER;

-- ALTER SEQUENCE remove ORDER
ALTER SEQUENCE ordered_seq NOORDER;

-- ALTER SEQUENCE set NOMINVALUE
ALTER SEQUENCE seq_with_min NOMINVALUE;

-- ALTER SEQUENCE set NOMAXVALUE
ALTER SEQUENCE seq_with_max NOMAXVALUE;

-- ALTER SEQUENCE change multiple attributes
ALTER SEQUENCE comprehensive_seq
INCREMENT BY 2
MINVALUE 1000
MAXVALUE 999999
CACHE 200;

-- ALTER SEQUENCE restart numbering (using RESTART - 12c+)
ALTER SEQUENCE emp_seq RESTART;

-- ALTER SEQUENCE restart with specific value (12c+)
ALTER SEQUENCE emp_seq RESTART WITH 5000;

-- ALTER SEQUENCE restart and change INCREMENT
ALTER SEQUENCE emp_seq
RESTART WITH 1000
INCREMENT BY 10;

-- ALTER SEQUENCE for negative increment
ALTER SEQUENCE countdown_seq INCREMENT BY -5;

-- ALTER SEQUENCE change from negative to positive increment
ALTER SEQUENCE countdown_seq INCREMENT BY 1;

-- ALTER SEQUENCE increase cache for performance
ALTER SEQUENCE high_volume_seq CACHE 20000;

-- ALTER SEQUENCE decrease cache
ALTER SEQUENCE high_volume_seq CACHE 100;

-- ALTER SEQUENCE for RAC - add ORDER
ALTER SEQUENCE rac_seq ORDER;

-- ALTER SEQUENCE for RAC - remove ORDER for performance
ALTER SEQUENCE rac_ordered_seq NOORDER;

-- ALTER SEQUENCE change MINVALUE and MAXVALUE together
ALTER SEQUENCE bounded_seq
MINVALUE 1
MAXVALUE 1000000;

-- ALTER SEQUENCE to cycle
ALTER SEQUENCE circular_buffer_seq
MINVALUE 1
MAXVALUE 500
CYCLE;

-- ALTER SEQUENCE extend range
ALTER SEQUENCE year_seq MAXVALUE 2100;

-- ALTER SEQUENCE narrow range
ALTER SEQUENCE year_seq MAXVALUE 2030;

-- ALTER SEQUENCE change to unbounded
ALTER SEQUENCE bounded_seq
NOMINVALUE
NOMAXVALUE;

-- ALTER SEQUENCE change increment for even numbers
ALTER SEQUENCE odd_seq INCREMENT BY 2;  -- Now generates even if current is odd

-- ALTER SEQUENCE change increment by larger value
ALTER SEQUENCE custom_increment_seq INCREMENT BY 25;

-- ALTER SEQUENCE optimize for performance
ALTER SEQUENCE transaction_id_seq
CACHE 10000
NOORDER;

-- ALTER SEQUENCE optimize for accuracy
ALTER SEQUENCE audit_seq
NOCACHE
ORDER;

-- ALTER SEQUENCE for sharded environment
ALTER SEQUENCE sharded_seq
CACHE 50000
NOORDER;

-- ALTER SEQUENCE disable cycling
ALTER SEQUENCE daily_batch_seq NOCYCLE;

-- ALTER SEQUENCE enable cycling
ALTER SEQUENCE daily_batch_seq
CYCLE
MAXVALUE 10000;

-- ALTER SEQUENCE change starting point via RESTART
ALTER SEQUENCE invoice_seq RESTART WITH 200000;

-- ALTER SEQUENCE change increment and restart
ALTER SEQUENCE batch_id_seq
RESTART WITH 1
INCREMENT BY 1;

-- ALTER SEQUENCE for new fiscal year
ALTER SEQUENCE fiscal_year_seq RESTART WITH 2025;

-- ALTER SEQUENCE increase MAXVALUE for growth
ALTER SEQUENCE employee_id_seq MAXVALUE 999999;

-- ALTER SEQUENCE change to support negative numbers
ALTER SEQUENCE signed_seq
MINVALUE -10000
MAXVALUE 10000;

-- ALTER SEQUENCE remove bounds
ALTER SEQUENCE large_nocycle_seq
NOMINVALUE
NOMAXVALUE;

-- ALTER SEQUENCE add bounds
ALTER SEQUENCE unbounded_seq
MINVALUE 1
MAXVALUE 999999999;

-- ALTER SEQUENCE change cache to 1 (near-nocache)
ALTER SEQUENCE session_seq CACHE 1;

-- ALTER SEQUENCE increase cache dramatically
ALTER SEQUENCE low_volume_seq CACHE 1000;

-- ALTER SEQUENCE for better RAC scalability
ALTER SEQUENCE rac_ordered_seq
CACHE 5000
NOORDER;

-- ALTER SEQUENCE for strict ordering
ALTER SEQUENCE time_order_seq
CACHE 10
ORDER;

-- ALTER SEQUENCE modify for identity column
ALTER SEQUENCE identity_seq
INCREMENT BY 1
CACHE 20;

-- ALTER SEQUENCE change from SCALE EXTEND to NOEXTEND (18c+)
ALTER SEQUENCE scale_extend_seq SCALE NOEXTEND;

-- ALTER SEQUENCE change from SCALE NOEXTEND to EXTEND (18c+)
ALTER SEQUENCE scale_noextend_seq SCALE EXTEND;

-- ALTER SEQUENCE change from SHARD EXTEND to NOEXTEND (18c+)
ALTER SEQUENCE sharded_seq SHARD NOEXTEND;

-- ALTER SEQUENCE change from SHARD NOEXTEND to EXTEND (18c+)
ALTER SEQUENCE shard_noextend_seq SHARD EXTEND;

-- ALTER SEQUENCE change from SESSION to GLOBAL (18c+)
ALTER SEQUENCE session_specific_seq GLOBAL;

-- ALTER SEQUENCE change from GLOBAL to SESSION (18c+)
ALTER SEQUENCE global_seq SESSION;

-- ALTER SEQUENCE restart with RESTART START WITH (alternative syntax)
ALTER SEQUENCE emp_seq RESTART START WITH 10000;

-- ALTER SEQUENCE change all attributes at once
ALTER SEQUENCE comprehensive_seq
RESTART WITH 1
INCREMENT BY 1
MINVALUE 1
MAXVALUE 999999999
NOCYCLE
CACHE 100
NOORDER;

-- ALTER SEQUENCE for downtime maintenance
ALTER SEQUENCE production_seq
NOCACHE  -- Ensure all values are persisted
ORDER;   -- Ensure strict ordering

-- ALTER SEQUENCE after maintenance
ALTER SEQUENCE production_seq
CACHE 1000  -- Resume caching
NOORDER;    -- Resume normal operation

-- ALTER SEQUENCE increase increment for bulk operations
ALTER SEQUENCE bulk_seq INCREMENT BY 1000;

-- ALTER SEQUENCE reset increment after bulk operations
ALTER SEQUENCE bulk_seq INCREMENT BY 1;

-- ALTER SEQUENCE to reset sequence to beginning
ALTER SEQUENCE test_seq
RESTART WITH 1
MINVALUE 1
MAXVALUE 1000
NOCYCLE;

-- ALTER SEQUENCE change step size
ALTER SEQUENCE custom_seq INCREMENT BY 10;

-- ALTER SEQUENCE for customer numbering change
ALTER SEQUENCE customer_num_seq
RESTART WITH 200001
MINVALUE 200001
MAXVALUE 299999;

-- ALTER SEQUENCE for new year
ALTER SEQUENCE order_2024_seq
RESTART WITH 20250001
MINVALUE 20250001
MAXVALUE 20259999;

-- ALTER SEQUENCE optimize for high concurrency
ALTER SEQUENCE concurrent_seq
CACHE 10000
NOORDER;

-- ALTER SEQUENCE optimize for low concurrency
ALTER SEQUENCE concurrent_seq
CACHE 20
ORDER;

-- ALTER SEQUENCE extend MAXVALUE approaching limit
ALTER SEQUENCE near_limit_seq
MAXVALUE 99999999;

-- ALTER SEQUENCE change to cycling when limit reached
ALTER SEQUENCE near_limit_seq
CYCLE
MINVALUE 1;

-- ALTER SEQUENCE disable cycle before limit
ALTER SEQUENCE near_limit_seq
NOCYCLE
MAXVALUE 999999999;

-- ALTER SEQUENCE change negative increment value
ALTER SEQUENCE desc_seq INCREMENT BY -100;

-- ALTER SEQUENCE reverse direction
ALTER SEQUENCE desc_seq
INCREMENT BY 1
MINVALUE 1
MAXVALUE 100000;

-- ALTER SEQUENCE for test environment reset
ALTER SEQUENCE test_data_seq RESTART WITH 1;

-- ALTER SEQUENCE for production migration
ALTER SEQUENCE migrated_seq
RESTART WITH 1000000
INCREMENT BY 1
CACHE 500;

-- ALTER SEQUENCE adjust for replication
ALTER SEQUENCE repl_seq
CACHE 10000
NOORDER;

-- ALTER SEQUENCE adjust for non-replicated environment
ALTER SEQUENCE repl_seq
CACHE 100
ORDER;

-- ALTER SEQUENCE change cache for memory constraints
ALTER SEQUENCE memory_constrained_seq CACHE 10;

-- ALTER SEQUENCE change cache for performance
ALTER SEQUENCE memory_constrained_seq CACHE 5000;

-- ALTER SEQUENCE for interval partitioning adjustment
ALTER SEQUENCE partition_seq
RESTART WITH 20240101
INCREMENT BY 1;

-- ALTER SEQUENCE for version numbering
ALTER SEQUENCE version_seq
RESTART WITH 2
INCREMENT BY 1;

-- ALTER SEQUENCE for reference numbering pattern
ALTER SEQUENCE reference_seq
INCREMENT BY 1
CACHE 200;

-- ALTER SEQUENCE prepare for archival
ALTER SEQUENCE archive_seq
RESTART WITH 1
NOCACHE
ORDER;

-- ALTER SEQUENCE resume normal operation
ALTER SEQUENCE archive_seq
CACHE 1000
NOORDER;

-- ALTER SEQUENCE for load testing
ALTER SEQUENCE loadtest_seq
CACHE 50000
NOORDER;

-- ALTER SEQUENCE after load testing
ALTER SEQUENCE loadtest_seq
CACHE 100
ORDER;

-- ALTER SEQUENCE change to support larger numbers
ALTER SEQUENCE expanding_seq
MAXVALUE 9999999999999999999999999999;

-- ALTER SEQUENCE tighten bounds for validation
ALTER SEQUENCE validation_seq
MINVALUE 1
MAXVALUE 100
NOCYCLE;

-- ALTER SEQUENCE loosen bounds after validation
ALTER SEQUENCE validation_seq
NOMINVALUE
NOMAXVALUE;

-- ALTER SEQUENCE for disaster recovery
ALTER SEQUENCE dr_seq
RESTART WITH 5000000
CACHE 1
ORDER;

-- ALTER SEQUENCE after DR test
ALTER SEQUENCE dr_seq
CACHE 1000
NOORDER;

-- ALTER SEQUENCE for A/B testing
ALTER SEQUENCE ab_test_seq
RESTART WITH 1000
INCREMENT BY 2;  -- Odd for A, even for B

-- ALTER SEQUENCE after A/B test
ALTER SEQUENCE ab_test_seq
INCREMENT BY 1
RESTART WITH 2000;

-- ALTER SEQUENCE for blue/green deployment
ALTER SEQUENCE deployment_seq
RESTART WITH 1000000;

-- ALTER SEQUENCE for rollback
ALTER SEQUENCE deployment_seq
RESTART WITH 900000;

-- ALTER SEQUENCE increase MINVALUE
ALTER SEQUENCE bounded_seq MINVALUE 100;

-- ALTER SEQUENCE decrease MINVALUE
ALTER SEQUENCE bounded_seq MINVALUE 1;

-- ALTER SEQUENCE change everything including restart
ALTER SEQUENCE complete_change_seq
RESTART WITH 5000
INCREMENT BY 5
MINVALUE 5000
MAXVALUE 50000
CYCLE
CACHE 50
ORDER;

-- ALTER SEQUENCE for maintenance window
ALTER SEQUENCE maintenance_seq
NOCACHE
ORDER;

-- ALTER SEQUENCE resume after maintenance
ALTER SEQUENCE maintenance_seq
CACHE 1000
NOORDER;

-- ALTER SEQUENCE for data migration
ALTER SEQUENCE migration_seq
RESTART WITH 10000000
INCREMENT BY 1
CACHE 10000;

-- ALTER SEQUENCE for gradual rollout
ALTER SEQUENCE rollout_seq
INCREMENT BY 1
CACHE 100;

-- ALTER SEQUENCE for full rollout
ALTER SEQUENCE rollout_seq
CACHE 5000;

-- ALTER SEQUENCE to recycle IDs
ALTER SEQUENCE recycling_seq
CYCLE
MINVALUE 1
MAXVALUE 10000
CACHE 100;

-- ALTER SEQUENCE stop recycling
ALTER SEQUENCE recycling_seq
NOCYCLE
NOMINVALUE
NOMAXVALUE;
