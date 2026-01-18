-- SET ROLE statement examples
-- Note: SET ROLE appears to be partially supported in the grammar
-- but adding here for completeness with additional variants

-- Enable a single role
SET ROLE warehouse_manager;

-- Enable multiple roles
SET ROLE order_entry, shipping_clerk;

-- Enable a role with password
SET ROLE warehouse_manager IDENTIFIED BY xyz123;

-- Enable multiple roles with passwords
SET ROLE order_entry IDENTIFIED BY pass1, shipping_clerk IDENTIFIED BY pass2;

-- Enable all roles except specific ones
SET ROLE ALL EXCEPT dba_role;

-- Disable all roles
SET ROLE NONE;

-- Enable all roles
SET ROLE ALL;

-- Complex example with multiple roles, some with passwords
SET ROLE developer,
         dba IDENTIFIED BY admin_pass,
         tester IDENTIFIED BY test_pass;

-- Enable role using external authentication
SET ROLE secure_role IDENTIFIED EXTERNALLY;

-- Enable role using global authentication
SET ROLE global_role IDENTIFIED GLOBALLY;
