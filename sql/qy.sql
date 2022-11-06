-- The minimum, average maximum and total sales of all product in each year -------------------------------------------------------------#

--  how many business years does the sales record cover?
SELECT DISTINCT year(order_date) AS Distinct_Year, 
			 COUNT(order_date) AS Number_Of_Transactions
	FROM sales_order
     GROUP BY Distinct_Year;
     
WITH sales_year AS (
	SELECT year(order_date) AS order_year,
		  monthname(order_date) AS order_month,
            (order_quantity * unit_price) AS sales
		FROM sales_order
)
SELECT order_year, 
	  MIN(sales) AS Minimum,
       round(AVG(sales), 2) AS Average,
       round(MAX(sales), 2) AS Maximum,
       round(SUM(sales), 2) AS Total
	FROM sales_year
     GROUP BY order_year;
     

-- number of distinct months in each year.
SELECT tbl.order_year, COUNT(tbl.order_month) AS number_of_distinct_month
	FROM(SELECT order_date, year(order_date) AS order_year,  month(order_date) AS order_month
		FROM sales_order
		GROUP BY order_year, order_month
		LIMIT 50) AS tbl
	GROUP BY tbl.order_year;


-- Total revenue by year -------------------------------------------------------------------------------------------
CREATE TEMPORARY TABLE rev_date_tbl
	SELECT order_date,
		  year(order_date) AS order_year,
            monthname(order_date) AS order_month,
            order_quantity,
            unit_price,
            (order_quantity * unit_price) AS sales,
		  ((order_quantity * unit_cost) + ((order_quantity * unit_price) * discount_applied)) AS cost,
		  (order_quantity * unit_price) - ((order_quantity * unit_cost) + ((order_quantity * unit_price) * discount_applied)) AS profit
		FROM sales_order;

SELECT order_year, 
	  round(AVG(profit), 2) AS Average_Profit, 
       round(SUM(profit), 2) AS Total_Proft 
	FROM rev_date_tbl
     GROUP BY order_year;
     
     

-- Total & Average profit by order month -------------------------------------------------------------------------------------------
SELECT order_month, 
	  round(AVG(profit), 2) AS Average_Profit, 
       round(SUM(profit), 2) AS Total_Profit 
	FROM rev_date_tbl
     GROUP BY order_month
     ORDER BY Total_Profit DESC;
     

-- Total & Average profit by months in 2020 ------------------------------------------------------------------------------------------
SELECT order_month,
	  round(AVG(profit), 2) AS Average_Profit, 
       round(SUM(profit), 2) AS Total_Profit 
	FROM rev_date_tbl
     WHERE order_year = 2020
     GROUP BY order_month
     ORDER BY Total_Profit DESC;
     
     
-- Year on year (YoY) --------------------------------------------------------------------------------------------------------------------------
SELECT * FROM rev_date_tbl;
     
CREATE TEMPORARY TABLE yoy_sep_19
	SELECT SUM(profit) AS Sep_19_profit
		FROM rev_date_tbl
		WHERE order_year = 2019 AND order_month = "September"; 
          
CREATE TEMPORARY TABLE yoy_sep_20
	SELECT SUM(profit) AS Sep_20_profit
		FROM rev_date_tbl
		WHERE order_year = 2020 AND order_month = "September"; 
          
SELECT round(Sep_19_profit, 2) AS Sep_19_profit, 
	  round(Sep_20_profit, 2) AS Sep_20_profit,
       round(((Sep_20_profit - Sep_19_profit) / Sep_19_profit)*100, 2) AS YoY
	FROM yoy_sep_19
     JOIN yoy_sep_20;



-- The total sales/profit of each products -------------------------------------------------------------------------------------------------------#

-- Total number of products.
SELECT count(product_name)
	FROM product;


-- [sub] First let get the unique products avaliable and the number of transactions involved.
SELECT product_name, count(product_name) AS Count
	FROM product
     JOIN sales_order
		ON product.product_id = sales_order.product_id
     GROUP BY product_name
     ORDER BY Count DESC;
     
     
-- Top 3 products (total number of orders)
SELECT product_name, SUM(order_quantity) AS Total_Order
	FROM sales_order
     JOIN product
		ON sales_order.product_id = product.product_id
	GROUP BY product_name
     ORDER BY Total_Order DESC
     LIMIT 3;
     
     

-- FOR EACH YEAR --------------------------
SELECT product_name, SUM(order_quantity) AS Total_Order
	FROM sales_order
     JOIN product
		ON sales_order.product_id = product.product_id
	WHERE year(order_date) = 2018
	GROUP BY product_name
     ORDER BY Total_Order DESC
     LIMIT 3;
     
     
-- Average discount paid on each product.
WITH prod_dis AS (
	SELECT product_id,
		  (order_quantity * unit_price) * discount_applied AS discount
		FROM sales_order
)
SELECT product_name, round(AVG(discount), 2) AS Average_Discount
	FROM prod_dis
     JOIN product
		ON prod_dis.product_id = product.product_id
	GROUP BY product_name
     ORDER BY Average_Discount DESC;


--  how much was spent in total for each product.
WITH prod_rev AS (
	SELECT product_id,
		  (order_quantity * unit_price) AS sales,
            ((order_quantity * unit_cost) + ((order_quantity * unit_price) * discount_applied)) AS cost,
            (order_quantity * unit_price) - ((order_quantity * unit_cost) + ((order_quantity * unit_price) * discount_applied)) AS profit
		FROM sales_order
)
SELECT product_name, 
	  round(SUM(sales), 2) AS Total_Sales,
       round(SUM(cost), 2) AS Total_Cost,
       round(SUM(profit), 2) AS Total_Profit
	FROM prod_rev pv
     JOIN product p
		ON pv.product_id = p.product_id
	GROUP BY product_name
     ORDER BY Total_Profit DESC;
     

-- [sub] Revenue summary for the year 2020
WITH prod_rev AS (
	SELECT product_id,
		  year(order_date) AS order_year,
		  (order_quantity * unit_price) AS sales,
            ((order_quantity * unit_cost) + ((order_quantity * unit_price) * discount_applied)) AS cost,
            (order_quantity * unit_price) - ((order_quantity * unit_cost) + ((order_quantity * unit_price) * discount_applied)) AS profit
		FROM sales_order
)
SELECT product_name, 
	  round(SUM(sales), 2) AS Total_Sales,
       round(SUM(cost), 2) AS Total_Cost,
       round(SUM(profit), 2) AS Total_Profit
	FROM prod_rev pv
     JOIN product p
		ON pv.product_id = p.product_id
	WHERE order_year = 2020
	GROUP BY product_name
     ORDER BY Total_Profit DESC;
     
     

-- The total quantity order by all customers in each year -----------------------------------------------------------------------------------------#

-- The total number of unique customers sold to
SELECT count(customer_names)
	FROM customer;

-- Number of unique transactions each customers are involved in. 

SELECT customer_names, count(customer_names) AS Count
	FROM customer
     JOIN sales_order
		ON customer.customer_id = sales_order.customer_id
	GROUP BY customer_names
     ORDER BY Count DESC;
     
     

-- Given the number of transactions above it will be intersting to see the total number of quantity orders and sales from each customers.
WITH cus_qos AS (
	SELECT customer_id,
		  order_quantity,
		  (order_quantity * unit_price) AS sales
		FROM sales_order
)
SELECT customer_names,
	  SUM(order_quantity) AS Total_Order_Quantity,
       round(SUM(sales), 2) AS Total_Sales
	FROM cus_qos
     JOIN customer
		ON cus_qos.customer_id = customer.customer_id
	GROUP BY customer_names
     ORDER BY Total_Sales DESC;
     
     

-- total order and sales made by Medline for all product purchase
WITH cus_prod_ors AS (
	SELECT customer_id,
		  product_id,
            order_quantity,
		  (order_quantity * unit_price) AS sales
		FROM sales_order
)
SELECT product_name, 
	  SUM(order_quantity) AS Total_Order_Quantity,
       round(SUM(sales), 2) AS Total_Sales
	FROM cus_prod_ors
     JOIN customer
		ON cus_prod_ors.customer_id = customer.customer_id
	JOIN product
		ON cus_prod_ors.product_id = product.product_id
	WHERE customer_names = "Medline"
	GROUP BY product_name
     ORDER BY Total_Sales DESC;
     
     

-- Top 10 customers by total amount spent(sales) and profit.
WITH cus_sp AS (
	SELECT customer_id,
		  (order_quantity * unit_price) AS sales,
            (order_quantity * unit_price) - ((order_quantity * unit_cost) + ((order_quantity * unit_price) * discount_applied)) AS profit
		FROM sales_order
)
SELECT customer_names,
	  round(SUM(sales), 2) AS Total_Sales,
       round(SUM(profit), 2) AS Total_Profit
	FROM cus_sp
     JOIN customer 
		ON cus_sp.customer_id = customer.customer_id
	GROUP BY customer_names
     ORDER BY Total_Profit DESC
     LIMIT 10;
     
     

-- The highest amount spent on a particular product by a customer.
WITH prod_cus_sale AS (
	SELECT customer_id,
		  product_id,
            (order_quantity * unit_price) AS sales
		FROM sales_order
)
SELECT customer_names, 
	  product_name,
       round(SUM(sales), 2) AS Total_Sales
	FROM prod_cus_sale
     JOIN customer
		ON prod_cus_sale.customer_id = customer.customer_id
	JOIN product
		ON prod_cus_sale.product_id = product.product_id
	GROUP BY customer_names, product_name
     ORDER BY Total_Sales DESC;
     
     
-- The best performing sales channel using total quantity order and sales ------------------------------------------------------------------------#
-- Unique sales Channel
SELECT DISTINCT sales_channel
	FROM sales_order;

-- number of transactions that came through each sales channel
SELECT sales_channel, count(sales_channel) AS Count
	FROM sales_order
     GROUP BY sales_channel
     ORDER BY Count DESC;
     
     
-- Total/average order and sale from each sales channel.
WITH sc_qos AS (
	SELECT sales_channel,
		  order_quantity, 
		  (order_quantity * unit_price) AS sales
		FROM sales_order
)
SELECT sales_channel,
	  round(AVG(order_quantity), 2) AS Average_Order,
       SUM(order_quantity) AS Total_order,
       round(AVG(sales), 2) AS Average_Sales,
       round(SUM(sales), 2) AS Total_Sales
	FROM sc_qos
     GROUP BY sales_channel
     ORDER BY Total_Sales DESC;
     
     

-- Geo-location ------------------------------------------------------------------------------------------------------------------------------------#
-- summary of region, state, county and city by total sales, cost and profit

CREATE TEMPORARY TABLE revenue_tbl
	SELECT store_id,
		  year(order_date) AS order_year,
            (order_quantity * unit_price) AS sales,
		  ((order_quantity * unit_cost) + ((order_quantity * unit_price) * discount_applied)) AS cost,
		  (order_quantity * unit_price) - ((order_quantity * unit_cost) + ((order_quantity * unit_price) * discount_applied)) AS profit
		FROM sales_order;
          
          
-- region -----------------------------
SELECT r.region, 
	  round(SUM(rt.sales), 2) AS Total_Sales,
       round(SUM(rt.cost), 2) AS Total_Cost,
       round(SUM(rt.profit), 2) AS Total_Profit
	FROM revenue_tbl rt
     JOIN store s
		ON rt.store_id = s.store_id
	JOIN regions r
		ON s.state_code = r.state_code
	GROUP BY r.region
     ORDER BY Total_Profit DESC;
     
     
-- State ----------------------
SELECT s.state, 
	  round(SUM(rt.sales), 2) AS Total_Sales,
       round(SUM(rt.cost), 2) AS Total_Cost,
       round(SUM(rt.profit), 2) AS Total_Profit
	FROM revenue_tbl rt
     JOIN store s
		ON rt.store_id = s.store_id
	GROUP BY s.state
     ORDER BY Total_Profit DESC;
     
     
-- County ---------------------
SELECT s.county, 
	  round(SUM(rt.sales), 2) AS Total_Sales,
       round(SUM(rt.cost), 2) AS Total_Cost,
       round(SUM(rt.profit), 2) AS Total_Profit
	FROM revenue_tbl rt
     JOIN store s
		ON rt.store_id = s.store_id
	GROUP BY s.county
     ORDER BY Total_Profit DESC;
     
     
-- City ----------------------------------
SELECT s.city_name AS City, 
	  round(SUM(rt.sales), 2) AS Total_Sales,
       round(SUM(rt.cost), 2) AS Total_Cost,
       round(SUM(rt.profit), 2) AS Total_Profit
	FROM revenue_tbl rt
     JOIN store s
		ON rt.store_id = s.store_id
	GROUP BY s.city_name
     ORDER BY Total_Cost DESC;
     

-- all geographical location ----------------------------------------
SELECT r.region, s.state, s.county, s.city_name,
	  round(SUM(rt.sales), 2) AS Total_Sales,
       round(SUM(rt.cost), 2) AS Total_Cost,
       round(SUM(rt.profit), 2) AS Total_Profit
	FROM revenue_tbl rt
     JOIN store s
		ON rt.store_id = s.store_id
	JOIN regions r
		ON s.state_code = r.state_code
	GROUP BY r.region, s.state, s.county, s.city_name
     ORDER BY Total_Profit DESC;


-- Total quantity ordered for each product in each state
SELECT state, 
	  product_name, 
       COUNT(order_quantity) AS Number_of_Transaction,
       round(AVG(order_quantity), 2) AS Average_Order_Quantity,
       SUM(order_quantity) AS Total_Order_Quantity
	FROM sales_order sr
     JOIN store st
		ON sr.store_id = st.store_id
	JOIN product p
		ON sr.product_id = p.product_id
	GROUP BY state, product_name
     ORDER BY state
     LIMIT 50;