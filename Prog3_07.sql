-- 7. For each store, list the percentage of orders which did not ship until after the required_date
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

