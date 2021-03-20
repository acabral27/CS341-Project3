-- 8. Each store decides to give away free coupons to the customers 
-- who have ordered items from their store more than once. 
-- Retrieve STORE_NAME, CUSTOMER_NAME, NUM_ORDERS
-- CUSTOMER_NAME includes both first and last name appended with with a space character in between. 
-- Only keep the store-customer pairs where more than one order has been made.
-- Sort the results by store name alphabetic, then in decreasing order of NUM_ORDERS, 
-- and alphabetic by last name in the case of ties..
-- EXAMPLE
-- 131 rows returned
-- first row
# STORE_NAME, CUSTOMER_NAME, NUM_ORDERS
# 'Baldwin Bikes', 'Genoveva Baldwin', '3'
SELECT store_name AS STORE_NAME,
	   CONCAT(first_name, " ", last_name) AS CUSTOMER_NAME,
       (CASE WHEN ( COUNT(*) > 1) 
	   THEN COUNT(*) 
	   END) AS NUM_ORDERS
FROM orders
INNER JOIN customers
ON orders.customer_id = customers.customer_id
INNER JOIN stores
ON orders.store_id = stores.store_id
GROUP BY customers.customer_id
HAVING NUM_ORDERS > 1
ORDER BY STORE_NAME, NUM_ORDERS DESC, last_name
