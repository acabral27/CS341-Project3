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
