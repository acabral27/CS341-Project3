-- 1. Generate a table containing nicely formatted customer information.
-- Retrieve the name, address and contact details of the customer 
-- as NAME, ADDRESS, CONTACT_DETAILS ordered alphabetically by last name, then first name in case of a tie. 
-- NAME includes both first and last name appended with with a space character in between. 
-- ADDRESS is calculated in the following way: <street> <city>, <state>, <zip_code>. 
-- CONTACT_DETAILS contains the string as: "Email: <email>, Phone: <phone>". 
-- If either of the email or the phone of the customer is null string, replace it with the string "N/A".
-- EXAMPLE 
-- 1445 rows returned
-- first row
# NAME, ADDRESS, CONTACT_DETAILS
# 'Ester Acevedo', '671 Miles Court  San Lorenzo, CA, 94580', 'Email: ester.acevedo@gmail.com, Phone: N/A'
SELECT CONCAT(first_name, " ", last_name) AS NAME, 
	   CONCAT(street, city, ", ", state, ", ", zip_code) AS ADDRESS,
       CONCAT("Email: ", IFNULL(email,'N/A'),", Phone: ", IFNULL(phone,'N/A')) AS CONTACT_DETAILS
FROM customers
ORDER BY last_name, first_name



-- 2. Find the contact information for a particular customer.
-- Retrieve the name, address and contact details of the customer 
-- for the order_id stored in @oid as NAME, ADDRESS, CONTACT_DETAILS.
-- Format is the same as question one, just output for a single order instead of all customers.
-- NAME includes both first and last name appended with with a space character in between. 
-- ADDRESS is calculated in the following way: <street> <city>, <state>, <zip_code>. 
-- CONTACT_DETAILS contains the string as: "Email: <email>, Phone: <phone>". 
-- If either of the email or the phone of the customer is null string, replace it with the string "N/A".
-- EXAMPLE 
-- input: set @oid = 5
# NAME, ADDRESS, CONTACT_DETAILS
# 'Arla Ellis', '127 Crescent Ave.  Utica, NY, 13501', 'Email: arla.ellis@yahoo.com, Phone: N/A'
SELECT CONCAT(first_name, " ", last_name) AS NAME, 
	   CONCAT(street, city, ", ", state, ", ", zip_code) AS ADDRESS,
       CONCAT("Email: ", IFNULL(email,'N/A'),", Phone: ", IFNULL(phone,'N/A')) AS CONTACT_DETAILS
FROM customers
INNER JOIN orders
ON customers.customer_id = orders.customer_id
WHERE order_id = @oid



-- 3. Filter out only the active orders.
-- Since we want to optimize the delivery services, 
-- from the orders table retrieve all the orders with 'Pending' and 'Processing' status 
-- and return a table with fields ORDER_ID, STATUS, STORE_ZIPCODE, CUSTOMER_ZIPCODE, REQUIRED_DATE. 
-- Order the results by STORE_ZIPCODE (ascending) and then by REQUIRED_DATE (earliest first), then by ORDER_ID.
-- The order statuses are as follows
-- Pending: 1 
-- Processing: 2
-- Rejected: 3
-- Completed : 4
-- EXAMPLE
-- 186 rows returned
-- first row
# ORDER_ID, STATUS, STORE_ZIPCODE, CUSTOMER_ZIPCODE, REQUIRED_DATE
# '1431', '2', '11432', '14580', '2018-03-12'
SELECT orders.order_id AS ORDER_ID,
	   orders.order_status AS STATUS,
       stores.zip_code AS STORE_ZIPCODE,
	   customers.zip_code AS CUSTOMER_ZIPCODE,
       orders.required_date AS REQURED_DATE
FROM orders
INNER JOIN customers
ON orders.customer_id = customers.customer_id
INNER JOIN stores
ON orders.store_id = stores.store_id
WHERE orders.order_status = 1 OR orders.order_status = 2
ORDER BY stores.zip_code,
		 orders.required_date,
         orders.order_id



-- 4. Investigate how long it takes in general (average number of days) for an order to get completed (time from order to shipping). 
-- Calculate the value as AVG_DAYS.
-- note that the - operand may produce strange values for different months/years
-- EXAMPLE
# AVG_DAYS
# '1.9835'
SELECT AVG( DATEDIFF(orders.shipped_date, orders.order_date)) AS AVG_DAYS
FROM orders
WHERE orders.order_date AND orders.shipped_date IS NOT NULL



-- 5. Based on the calculation in 4 (use the computed value, not a hard coded one),
-- return the orders which are in 'Pending' or 'Processing' states (question 3)
-- which are exceeding the average from the current date stored in @today
-- and may require expedited priority.
-- The table should return the columns 
-- ORDER_ID, DAYS_SINCE_ORDER
-- sorted starting from the longest DAYS_SINCE_ORDER. 
-- EXAMPLE
-- input: SET @today = '2018-03-21'
-- 22 rows returned
-- first row
# ORDER_ID, DAYS_SINCE_ORDER
# '1430', '11'
SELECT order_id AS ORDER_ID, DATEDIFF(@today, order_date) AS DAYS_SINCE_ORDER
FROM orders
INNER JOIN customers
ON orders.customer_id = customers.customer_id
WHERE (orders.order_status = 1 OR orders.order_status = 2) 
	AND DATEDIFF(@today, order_date) > (SELECT avg( DATEDIFF(orders.shipped_date, orders.order_date)) AS AVG_DAYS
										FROM orders
										WHERE orders.order_date AND orders.shipped_date IS NOT NULL)
ORDER BY DAYS_SINCE_ORDER DESC




-- 6.  For each store, report the Average turnaround (time from order to shipment).
-- Retrieve the STORE_NAME, AVG_TURNAROUND ordered by the fastest stores first, alphabetic in the case of a tie.
-- EXAMPLE
# STORE_NAME, AVG_TURNAROUND
# 'Rowlett Bikes', '1.9203'
# 'Baldwin Bikes', '1.9766'
# 'Santa Cruz Bikes', '2.0399'
SELECT store_name AS STORE_NAME, AVG(DATEDIFF(orders.shipped_date, orders.order_date)) AS AVG_TURNAROUND
FROM stores
INNER JOIN orders
ON stores.store_id = orders.store_id
GROUP BY orders.store_id
ORDER BY AVG_TURNAROUND



-- 7. For each store, list the percentage of orders which did not ship until after the required_date.
-- Retrieve the STORE_NAME, PERCENT_OVERDUE with the greatest first, alphabetic in the case of a tie.
-- EXAMPLE
# STORE_NAME, PERCENT_OVERDUE
# 'Santa Cruz Bikes', '29.3103'
# 'Baldwin Bikes', '27.8134'
# 'Rowlett Bikes', '20.1149'
SELECT store_name AS STORE_NAME,
				SUM(CASE WHEN shipped_date > required_date 
				THEN 1 
				END) / count(*) * 100 as PERCENT_OVERDUE
FROM stores
INNER JOIN orders
ON stores.store_id = orders.store_id
GROUP BY store_name
ORDER BY PERCENT_OVERDUE DESC,
		 STORE_NAME



-- 8. Each store decides to give away free coupons to the customers 
-- who have ordered items from their store more than once. 
-- Retrieve STORE_NAME, CUSTOMER_NAME, NUM_ORDERS
-- CUSTOMER_NAME includes both first and last name appended with with a space character in between. 
-- Only keep the store-customer pairs where more than one order has been made.
-- Sort the results by store name alphabetic, then in decreasing order of NUM_ORDERS, 
-- and alphabetic by last name in the case of ties.
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



-- 9. List information about each order.
-- Retrieve NAME, ORDER_ID, TOTAL_PRICE_BEFORE_DISCOUT, TOTAL_DISCOUNT
-- NAME includes both first and last customer name appended with with a space character in between. 
-- TOTAL_PRICE_BEFORE_DISCOUNT is the number of items multiplied by the list prices of those items, added up over all items in the order
-- TOTAL_DISCOUNT is the sum of the discount applied item by item to the total prices calculated in the prior line.
-- Both the price and the discount should be rounded to the nearest cent.
-- Order results by order_id
-- EXAMPLE 
-- 1615 rows returned
-- first row
# NAME, ORDER_ID, TOTAL_PRICE_BEFORE_DISCOUT, TOTAL_DISCOUNT
# 'Johnathan Velazquez', '1', '11397.94', '1166.89'
SELECT CONCAT( first_name, " ", last_name),
	   order_id AS ORDER_ID,
       (SELECT SUM(ROUND(order_items.quantity * order_items.list_price, 2)) 
       FROM order_items WHERE order_items.order_id = orders.order_id) 
       AS TOTAL_PRICE_BEFORE_DISCOUNT,
       (SELECT SUM(ROUND((order_items.quantity * order_items.list_price) * order_items.discount,2))
       FROM order_items WHERE order_items.order_id = orders.order_id) 
       AS TOTAL_DISCOUNT
FROM customers, orders
WHERE customers.customer_id = orders.customer_id
ORDER BY ORDER_ID



-- 10. Identify whether there may be some correlation between
-- the amount ordered and the time it takes to ship the order.
-- Compute the average and standard deviation of the time per quantity of each order
-- EXAMPLE
# AVG, STDDEV
# '0.64447607', '0.5703154314602293'  # When using GROUP BY
# '0.64447458', '0.5703161015453696'
SELECT (AVG( DATEDIFF(orders.shipped_date, orders.order_date)) /
	   (SELECT SUM(order_items.quantity)
       FROM order_items
       WHERE order_items.order_id = orders.order_id))
       AS AVG,
       STDDEV(AVG)
FROM (SELECT(DATEDIFF(orders.shipped_date, orders.order)date) /
	  SUM(order_items.quantity)) AS AVG
      FROM orders
      INNER JOIN order_items
      ON orders.order_id = order_items.order_id
      WHERE orders.order_status = 4
      GROUP BY orders.order_id)
      AS STTDEV


