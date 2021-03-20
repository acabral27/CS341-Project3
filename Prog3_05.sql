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
SET @today = '2018-03-21';

-- SELECT datediff(orders.shipped_date, orders.order_date) AS DAYS_SINCE_ORDER
-- FROM orders
-- WHERE orders.order_date AND orders.shipped_date IS NOT NULL;

SELECT order_id AS ORDER_ID, DATEDIFF(@today, order_date) AS DAYS_SINCE_ORDER
FROM orders
INNER JOIN customers
ON orders.customer_id = customers.customer_id
WHERE (orders.order_status = 1 OR orders.order_status = 2) 
	AND DATEDIFF(@today, order_date) > (SELECT avg( DATEDIFF(orders.shipped_date, orders.order_date)) AS AVG_DAYS
										FROM orders
										WHERE orders.order_date AND orders.shipped_date IS NOT NULL)
ORDER BY DAYS_SINCE_ORDER DESC
