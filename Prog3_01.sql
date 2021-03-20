-- 1. Generate a table containing nicely formatted customer information.
-- Retrieve the name, address and contact details of the customer 
-- as NAME, ADDRESS, CONTACT_DETAILS
-- ordered alphabetically by last name, then first name in the case of a tie. 
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