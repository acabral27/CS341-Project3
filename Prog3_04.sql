-- 4. Investigate how long it takes in general (average number of days) 
-- for an order to get completed (time from order to shipping). 
-- Calculate the value as AVG_DAYS.
-- note that the - operand may produce strange values for different months/years
-- EXAMPLE
-- output:
# AVG_DAYS
# '1.9835'
SELECT AVG( DATEDIFF(orders.shipped_date, orders.order_date)) AS AVG_DAYS
FROM orders
WHERE orders.order_date AND orders.shipped_date IS NOT NULL
