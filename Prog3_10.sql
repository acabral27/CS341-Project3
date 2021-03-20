-- 10. Identify whether there may be some correlation between
-- the amount ordered and the time it takes to ship the order
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
       



