CREATE DATABASE walmart;
USE walmart;
SELECT * FROM walmart;

SELECT COUNT(*) FROM walmart;

SELECT DISTINCT payment_method
FROM walmart;

SELECT payment_method, COUNT(*)
FROM walmart
GROUP BY payment_method;

SELECT COUNT(DISTINCT branch)
FROM walmart;

-- Business Problems

-- 1. FInd different payment methods and number of transactions, quantity sold

SELECT payment_method,
	COUNT(*) AS No_of_transaactions,
    SUM(quantity) AS Total_quantity
FROM walmart
GROUP BY payment_method;

-- 2. Identify the highest-rated category in each branch, displaying the branch, category and average rating

SELECT *
FROM
(SELECT Branch, Category, AVG(rating) AS Average_rating,
	RANK() OVER(PARTITION BY Branch ORDER BY AVG(rating) DESC) AS rnk
FROM walmart
GROUP BY 1,2 
ORDER BY 1,3 DESC) AS t1
WHERE rnk = 1;

-- 3. Identify the busiest day for each branch based on the number of transactions

WITh busiest_day
AS
(SELECT Branch, 
	DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS Day,
	COUNT(*) AS No_of_transactions,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
FROM walmart
GROUP BY 1,2)
SELECT * FROM busiest_day
WHERE rnk = 1;

-- 4. Detertmine the average, minimum and maximum rating of category for each city.

SELECT City, Category,
	MIN(rating) AS Minimum_Rating,
    MAX(rating) AS Maximum_Rating,
    AVG(rating) AS Average_Rating
FROM walmart
GROUP BY 1, 2;

-- 5. Calculate the total profit for each category
	
SELECT Category,
	ROUND(SUM(total*profit_margin),2) AS total_profit
 FROM walmart
 GROUP BY Category
 ORDER BY 2 DESC;


-- 6. Determine the most common payment method for each branch

SELECT Branch, Payment_Method
FROM
(SELECT Branch, Payment_Method, COUNT(invoice_id),
RANK() OVER(PARTITION BY Branch ORDER BY COUNT(invoice_id) DESC) AS rnk
FROM walmart
GROUP BY 1,2) AS t1
WHERE rnk = 1;

-- 7. Categorize sales into 3 shifts(Morning, Afternoon, Evening) and find transactions in each shift

SELECT MIN(CAST(time AS TIME)), MAX(CAST(time AS TIME)) FROM walmart;

SELECT Branch,
CASE
	WHEN HOUR(CAST(time AS TIME)) < 12 THEN 'Morning'
    WHEN HOUR(CAST(time AS TIME)) BETWEEN 12 AND 17 THEN 'Afternoon'
    ELSE 'Evening'
END AS shift,
COUNT(invoice_id) AS total_transactions
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

-- 8. Identity 5 branch with highest decrease ratio (Current year 2023 and previous year 2022)

WITH cte AS
(SELECT Branch,
YEAR(STR_TO_DATE(date, '%d/%m/%y')) AS Year,
SUM(Total) AS present_year,
LAG(SUM(Total),1) OVER(PARTITION BY Branch ORDER BY YEAR(STR_TO_DATE(date, '%d/%m/%y'))) AS last_year
FROM walmart
GROUP BY 1,2
HAVING Year IN (2022,2023))
SELECT *,
ROUND(100 * (last_year - present_year) / last_year,2) AS decrease
FROM cte
WHERE Year = 2023
ORDER BY decrease DESC
LIMIT 5;
