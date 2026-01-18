-- SET TRANSACTION statement examples
-- Note: SET TRANSACTION appears to be partially supported in the grammar
-- but adding here for completeness with additional variants

-- Set transaction to read-only
SET TRANSACTION READ ONLY;

-- Set transaction to read-write
SET TRANSACTION READ WRITE;

-- Set transaction isolation level to serializable
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- Set transaction isolation level to read committed
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- Combined: read-only with serializable
SET TRANSACTION READ ONLY ISOLATION LEVEL SERIALIZABLE;

-- Combined: read-write with read committed
SET TRANSACTION READ WRITE ISOLATION LEVEL READ COMMITTED;

-- Set transaction with name
SET TRANSACTION NAME 'large_update_transaction';

-- Set transaction with rollback segment
SET TRANSACTION USE ROLLBACK SEGMENT rbs_large;

-- Combined: isolation level with name
SET TRANSACTION ISOLATION LEVEL READ COMMITTED NAME 'TRAN1';

-- Combined: read-only with name
SET TRANSACTION READ ONLY NAME 'TRAN1';

-- Full syntax: all options
SET TRANSACTION READ WRITE
  ISOLATION LEVEL READ COMMITTED
  USE ROLLBACK SEGMENT rbs_01
  NAME 'complex_transaction';

-- Another full example
SET TRANSACTION READ ONLY
  ISOLATION LEVEL SERIALIZABLE
  NAME 'reporting_transaction';
