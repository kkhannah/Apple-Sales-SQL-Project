-- Apple Sales Project - 1M rows sales datasets

SELECT * FROM category;
SELECT * FROM products;
SELECT * FROM stores;
SELECT * FROM sales;
SELECT * FROM warranty;

-- EDA
SELECT DISTINCT repair_status FROM warranty;
SELECT COUNT(*) FROM sales;

-- Improving Query Performance

EXPLAIN ANALYZE
SELECT * FROM sales
WHERE product_id ='P-44';

-- Before index - Execution Time: 67.069 ms
-- After index - Execution Time: 3.757 ms

EXPLAIN ANALYZE
SELECT * FROM sales
WHERE store_id ='ST-31';

-- Before index - Execution Time: 74.498 ms
-- After index - Execution Time: 2.855 ms

CREATE INDEX sales_product_id ON sales(product_id);
CREATE INDEX sales_store_id ON sales(store_id);
CREATE INDEX sales_sale_date ON sales(sale_date);

-- Business Problems

-- 1. Find the number of stores in each country.

SELECT 
	country,
	COUNT(store_id) as total_stores
FROM stores
GROUP BY country
ORDER BY total_stores DESC;

-- Q.2 Calculate the total number of units sold by each store.

SELECT 
	st.store_id,
	st.store_name,
	SUM(COALESCE(s.quantity,0)) as total_unit_sold
FROM sales as s
RIGHT JOIN
stores as st
ON st.store_id = s.store_id
GROUP BY st.store_id, st.store_name
ORDER BY total_unit_sold DESC;

-- Q.3 Identify how many sales occurred in December 2023.

SELECT 
	COUNT(sale_id) as total_sale 
FROM sales
WHERE TO_CHAR(sale_date, 'MM-YYYY') = '12-2023';

-- Q.4 Determine how many stores have never had a warranty claim filed.

SELECT 
	COUNT(*) as no_of_stores 
FROM stores
WHERE store_id NOT IN (
						SELECT 
							DISTINCT store_id
						FROM sales as s
						JOIN warranty as w
						ON s.sale_id = w.sale_id
						);

-- Q.5 Calculate the percentage of warranty claims marked as "Warranty Void".

SELECT 
	ROUND((COUNT(*)/(SELECT COUNT(*) FROM warranty)::numeric) * 100,2)as warranty_void_percentage
FROM warranty
WHERE repair_status = 'Warranty Void';

-- Q.6 Identify which store had the highest total units sold in the last year.

WITH store_cte AS
	(SELECT 
		s.store_id,
		st.store_name,
		SUM(s.quantity) as total_quantity,
		RANK() OVER (ORDER BY SUM(s.quantity) DESC) AS store_rank
	FROM sales as s
	JOIN stores as st
	ON s.store_id = st.store_id
	WHERE sale_date >= (CURRENT_DATE - INTERVAL '1 year')
	GROUP BY s.store_id, st.store_name)

SELECT 
	store_id, store_name, total_quantity
FROM store_cte
WHERE store_rank=1;

-- Q.7 Count the number of unique products sold in the last year.

SELECT 
	COUNT(DISTINCT product_id)
FROM sales
WHERE sale_date >= (CURRENT_DATE - INTERVAL '1 year');

-- Q.8 Find the average price of products in each category.

SELECT 
	p.category_id,
	c.category_name,
	ROUND(AVG(p.price)::numeric, 2) as avg_price
FROM products as p
JOIN 
category as c
ON p.category_id = c.category_id
GROUP BY p.category_id, c.category_name
ORDER BY avg_price DESC;

-- Q.9 How many warranty claims were filed in 2020?

SELECT 
	COUNT(*)
FROM warranty
WHERE EXTRACT(YEAR FROM claim_date) = 2020;

-- Q.10 For each store, identify the best-selling day based on highest quantity sold.

SELECT  
	store_id, day_name, total_unit_sold
FROM
(
	SELECT 
		store_id,
		TO_CHAR(sale_date, 'Day') as day_name,
		SUM(quantity) as total_unit_sold,
		RANK() OVER(PARTITION BY store_id ORDER BY SUM(quantity) DESC) as rank
	FROM sales
	GROUP BY store_id, day_name
) as t1
WHERE rank = 1;

-- Q.11 Identify the least selling product in each country for each year based on total units sold.

WITH product_rank
AS
(
	SELECT 
		st.country,
		EXTRACT(YEAR FROM s.sale_date) as sale_year,
		p.product_name,
		SUM(s.quantity) as total_qty_sold,
		RANK() OVER(PARTITION BY st.country,EXTRACT(YEAR FROM s.sale_date) ORDER BY SUM(s.quantity)) as rank
	FROM sales as s
	JOIN 
	stores as st
	ON s.store_id = st.store_id
	JOIN
	products as p
	ON s.product_id = p.product_id
	GROUP BY st.country, sale_year, p.product_name
)
SELECT 
	country, sale_year, product_name, total_qty_sold
FROM product_rank
WHERE rank = 1;

-- Q.12 Calculate how many warranty claims were filed within 180 days of a product sale.

SELECT 
	COUNT(*)
FROM warranty as w
JOIN 
sales as s
ON s.sale_id = w.sale_id
WHERE w.claim_date - sale_date <= 180;

--Q.13  Determine how many warranty claims were filed for products launched in the last two years.

SELECT 
	p.product_name,
	COUNT(w.claim_id) as no_claim,
	COUNT(s.sale_id) as no_sales
FROM warranty as w
RIGHT JOIN
sales as s 
ON s.sale_id = w.sale_id
JOIN products as p
ON p.product_id = s.product_id
WHERE p.launch_date >= CURRENT_DATE - INTERVAL '2 years'
GROUP BY p.product_name
HAVING COUNT(w.claim_id) > 0;

-- Q.14 List the months in the last three years where sales exceeded 5,000 units in the USA.

SELECT 
	TO_CHAR(sale_date, 'MM-YYYY') as month,
	SUM(s.quantity) as total_unit_sold
FROM sales as s
JOIN 
stores as st
ON s.store_id = st.store_id
WHERE 
	st.country = 'USA'
	AND
	s.sale_date >= CURRENT_DATE - INTERVAL '3 year'
GROUP BY month
HAVING SUM(s.quantity) > 5000;

-- Q.15 Identify the product category with the most warranty claims filed in the last two years.
WITH product_cte as 
(
	SELECT 
		c.category_name,
		COUNT(w.claim_id) as total_claims,
		RANK() OVER (ORDER BY COUNT(w.claim_id) DESC) as product_rank
	FROM warranty as w
	JOIN
	sales as s
	ON w.sale_id = s.sale_id
	JOIN products as p
	ON p.product_id = s.product_id
	JOIN 
	category as c
	ON c.category_id = p.category_id
	WHERE 
		w.claim_date >= CURRENT_DATE - INTERVAL '2 year'
	GROUP BY c.category_name
)

SELECT 
	category_name, total_claims
FROM product_cte
WHERE product_rank=1;


-- Q.16 Determine the percentage chance of receiving warranty claims after each purchase for each country!

SELECT 
	st.country,
	ROUND((COUNT(w.claim_id)::numeric/SUM(s.quantity)::numeric)*100,2) as percentage
	
FROM sales as s
JOIN stores as st
ON s.store_id = st.store_id
LEFT JOIN 
warranty as w
ON w.sale_id = s.sale_id
GROUP BY st.country
ORDER BY percentage DESC;

-- Q.17 Analyze the year-by-year growth ratio for each store.

WITH yearly_sales
AS
(
	SELECT 
		s.store_id,
		st.store_name,
		EXTRACT(YEAR FROM sale_date) as year,
		SUM(s.quantity * p.price) as total_sale
	FROM sales as s
	JOIN
	products as p
	ON s.product_id = p.product_id
	JOIN stores as st
	ON st.store_id = s.store_id
	GROUP BY s.store_id, st.store_name, year
),
growth_ratio
AS
(
	SELECT 
		store_name,
		year,
		LAG(total_sale, 1) OVER(PARTITION BY store_name ORDER BY year) as last_year_sale,
		total_sale as current_year_sale
	FROM yearly_sales
)

SELECT 
	store_name,
	year,
	last_year_sale,
	current_year_sale,
	ROUND(
			(current_year_sale - last_year_sale)::numeric/
							last_year_sale::numeric * 100
	,2) as growth_ratio
FROM growth_ratio
WHERE last_year_sale IS NOT NULL;

-- Q.18 Calculate the correlation between product price and warranty claims for 
-- products sold in the last five years, segmented by price range.

SELECT 
	
	CASE
		WHEN p.price < 500 THEN 'Less Expenses Product'
		WHEN p.price BETWEEN 500 AND 1000 THEN 'Mid Range Product'
		ELSE 'Expensive Product'
	END as price_segment,
	COUNT(w.claim_id) as total_Claim
FROM warranty as w
JOIN
sales as s
ON w.sale_id = s.sale_id
JOIN 
products as p
ON p.product_id = s.product_id
WHERE sale_date >= CURRENT_DATE - INTERVAL '5 year'
GROUP BY price_segment;

-- Q.19 Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed

WITH paid_repair
AS
(
	SELECT 
		s.store_id,
		COUNT(w.claim_id) as paid_repaired
	FROM sales as s
	JOIN warranty as w
	ON w.sale_id = s.sale_id
	WHERE w.repair_status = 'Paid Repaired'
	GROUP BY s.store_id
),
total_repaired
AS
(
	SELECT 
		s.store_id,
		COUNT(w.claim_id) as total_repaired
	FROM sales as s
	JOIN warranty as w
	ON w.sale_id = s.sale_id
	GROUP BY s.store_id
)

SELECT 
	tr.store_id,
	st.store_name,
	pr.paid_repaired,
	tr.total_repaired,
	ROUND(pr.paid_repaired::numeric/
			tr.total_repaired::numeric * 100
		,2) as percentage_paid_repaired
FROM paid_repair as pr
JOIN 
total_repaired tr
ON pr.store_id = tr.store_id
JOIN stores as st
ON tr.store_id = st.store_id;

-- Q.20 Write a query to calculate the monthly running total of sales for each store

WITH monthly_sales
AS
(
	SELECT 
		store_id,
		TO_CHAR(sale_date,'yyyy-mm') as year_month,
		SUM(p.price * s.quantity) as total_revenue
	FROM sales as s
	JOIN 
	products as p
	ON s.product_id = p.product_id
	GROUP BY store_id, year_month
)
SELECT 
	*,
	SUM(total_revenue) OVER(PARTITION BY store_id ORDER BY year_month) as running_total
FROM monthly_sales;

-- Q.21 Analyze product sales trends over time, segmented into key periods: 
-- from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.


SELECT 
	p.product_name,
	CASE 
		WHEN s.sale_date>=p.launch_date AND s.sale_date< p.launch_date+INTERVAL '6 MONTH' THEN 'less than 6 months'
		WHEN s.sale_date>=p.launch_date+INTERVAL '6 MONTH' AND s.sale_date<p.launch_date+INTERVAL '12 MONTH' THEN '6-12 months'
		WHEN s.sale_date>=p.launch_date+INTERVAL '12 MONTH' AND s.sale_date<p.launch_date+INTERVAL '18 MONTH' THEN '12-18 months'
		ELSE '18 months and beyond'
	END as segment,
	SUM(s.quantity) as total_qty_sale
	
FROM sales as s
JOIN products as p
ON s.product_id = p.product_id
GROUP BY p.product_name, segment
ORDER BY p.product_name, total_qty_sale DESC;

-- End of Analysis
