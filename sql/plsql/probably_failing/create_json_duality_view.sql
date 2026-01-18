-- CREATE JSON RELATIONAL DUALITY VIEW statement examples
-- This statement is not currently supported by the PlSql grammar
-- JSON Relational Duality Views were introduced in Oracle 23ai

-- Basic JSON Relational Duality View
CREATE JSON RELATIONAL DUALITY VIEW departments_dv AS
SELECT JSON {
  '_id'         : d.deptno,
  'departmentId': d.deptno,
  'name'        : d.dname,
  'location'    : d.loc,
  'employees'   : [
    SELECT JSON {
      'employeeId' : e.empno,
      'name'       : e.ename,
      'job'        : e.job,
      'salary'     : e.sal
    }
    FROM emp e WITH INSERT UPDATE DELETE
    WHERE e.deptno = d.deptno
  ]
}
FROM dept d WITH INSERT UPDATE DELETE;

-- With OR REPLACE
CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW customer_orders_dv AS
SELECT JSON {
  '_id'       : c.ID,
  'FirstName' : c.FIRST_NAME,
  'LastName'  : c.LAST_NAME,
  'Email'     : c.EMAIL,
  'Orders'    : [
    SELECT JSON {
      'OrderId'   : o.ORDER_ID,
      'OrderDate' : o.ORDER_DATE,
      'Total'     : o.TOTAL_AMOUNT
    }
    FROM orders o WITH INSERT UPDATE DELETE
    WHERE o.CUSTOMER_ID = c.ID
  ]
}
FROM customers c WITH INSERT UPDATE DELETE;

-- Shorter syntax without RELATIONAL keyword
CREATE JSON DUALITY VIEW products_dv AS
SELECT JSON {
  '_id'         : p.product_id,
  'productName' : p.product_name,
  'price'       : p.price,
  'category'    : p.category
}
FROM products p WITH INSERT UPDATE DELETE;

-- With annotations
CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW customer_orders_dv
annotations (Description 'JSON Relational Duality View sourced from CUSTOMERS and ORDERS')
AS
SELECT JSON {
  '_id'       : c.ID,
  'FirstName' : c.FIRST_NAME,
  'LastName'  : c.LAST_NAME
}
FROM customers c WITH INSERT UPDATE DELETE;

-- Complex nested structure
CREATE OR REPLACE JSON RELATIONAL DUALITY VIEW order_details_dv AS
SELECT JSON {
  '_id'       : o.order_id,
  'orderDate' : o.order_date,
  'customer'  : {
    'customerId' : c.customer_id,
    'name'       : c.customer_name,
    'email'      : c.email
  },
  'items'     : [
    SELECT JSON {
      'itemId'      : oi.item_id,
      'productName' : p.product_name,
      'quantity'    : oi.quantity,
      'price'       : oi.price
    }
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    WHERE oi.order_id = o.order_id
  ]
}
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WITH INSERT UPDATE DELETE;

-- With IF NOT EXISTS
CREATE JSON DUALITY VIEW IF NOT EXISTS simple_view_dv AS
SELECT JSON {
  '_id'   : t.id,
  'value' : t.value
}
FROM simple_table t WITH INSERT UPDATE DELETE;
