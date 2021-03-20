-- 9. List information about each order.
-- Retrieve NAME, ORDER_ID, TOTAL_PRICE_BEFORE_DISCOUT, TOTAL_DISCOUNT
-- NAME includes both first and last customer name appended with with a space character in between. 
-- TOTAL_PRICE_BEFORE_DISCOUNT is the number of items multiplied by the list prices of those items, added up over all items in the order
-- TOTAL_DISCOUNT is the sum of the discount applied item by item to the total prices calculated in the prior line.
-- Both the price and the discount should be rounded to the nearest cent.
-- Order results by order_id
-- EXAMPLE 
-- 1615 rows reutrned
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
