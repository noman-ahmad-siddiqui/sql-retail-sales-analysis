--########### DATABASE CREATION AND DATA INSERTION ###########
CREATE DATABASE db_retail_sales;


USE db_retail_sales;

DROP TABLE IF EXISTS retail_sales
CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);

SELECT * FROM retail_sales

-- INSERTING DATA IN BULK
BULK INSERT retail_sales
FROM 'C:\Users\noman\Downloads\retail_sales.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);





-- ########### DATA OVERVIEW ###########

select Column_name, data_type from information_schema.columns
WHERE TABLE_NAME = 'retail_sales';


-- Cheking total number of records
SELECT COUNT(*) FROM retail_sales

-- Checking for duplicates
SELECT transactions_id, COUNT(*)
FROM retail_sales
GROUP BY transactions_id
HAVING COUNT(*) > 1;


SELECT * FROM retail_sales


-- data w.r.t gender
SELECT gender, COUNT(*)
FROM retail_sales
GROUP BY gender

SELECT DISTINCT gender FROM retail_sales

-- Checking if anyone has age in -ve
SELECT age
FROM retail_sales
WHERE age<1

-- checkin different categories and their number of records
SELECT category, COUNT(*)
FROM retail_sales
GROUP BY category

-- checking quantity and price if they are in negative values
SELECT *
FROM retail_sales
WHERE quantity < 0 or price_per_unit <0

-- converting date into proper format
SELECT CONVERT(DATE, sale_date,5)
FROM retail_sales


-- Checking For Null Values in  Table 
SELECT * FROM retail_sales
WHERE 
   transactions_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR age IS NULL
   OR category IS NULL
   OR quantiTy IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;




--########### DATABASE CLEANING ###########

-- Dropped NULL values where quantity and rest of calculation values are missing 
DELETE FROM retail_sales
WHERE quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL OR total_sale IS NULL;



-- Filled Null age with Average Age
UPDATE retail_sales
SET age = (select avg(age) from retail_sales)
WHERE age IS NULL



-- Total Sales
SELECT COUNT(total_sale) AS [Total # of Sales] FROM retail_sales 


-- Total revenue generated
SELECT SUM(total_sale) AS [Total Sales] FROM retail_sales

-- Avg customer age
SELECT AVG(age) FROM retail_sales

-- Maximum and Minimum Sale
SELECT MAX(total_sale) AS [Highest Sale], Min(total_sale) AS [Lowest Sale] FROM retail_sales


-- Category VS Revenue
SELECT category, SUM(total_sale) AS [Revenue] FROM retail_sales
GROUP BY category
ORDER BY [Revenue] DESC

-- Which gender spends more?
SELECT gender, SUM(total_sale) AS [Total Spend] FROM retail_sales
GROUP BY gender
ORDER BY [Total Spend] DESC

-- Which age group purchases most?
SELECT SUM(total_sale) AS [Total Sales],
CASE
    WHEN age < 25 THEN 'Young'
    WHEN age BETWEEN 25 AND 40 THEN 'Adult'
    ELSE 'Senior'
END AS [Age Group]
FROM retail_sales
GROUP BY 
CASE
        WHEN age < 25 THEN 'Young'
        WHEN age BETWEEN 25 AND 40 THEN 'Adult'
        ELSE 'Senior'
END
ORDER BY [Total Sales] DESC


-- Best sales month
SELECT DATEPART(MONTH,sale_date) AS [Month], SUM(total_sale) AS [Total Sales] FROM retail_sales
GROUP BY DATEPART(MONTH,sale_date)
ORDER BY [Total Sales] DESC


-- Morning vs Afternoon vs Evening sales
SELECT
CASE
    WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
    WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
    ELSE 'Evening'
END AS [Shift],
COUNT(*) AS [# of orders]
FROM retail_sales
GROUP BY 
CASE
    WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
    WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
    ELSE 'Evening'
END


-- Top 5 customers by spending
SELECT TOP (5) customer_id , SUM(total_sale) AS [Total Spend] FROM retail_sales
GROUP BY customer_id
ORDER BY [Total Spend] DESC


-- Average order value per category
SELECT category, ROUND(AVG(total_sale),2) AS [Avergae Order Value] FROM retail_sales
GROUP BY category

-- Rank categories by revenue
SELECT category,SUM(total_sale) AS revenue,
   RANK() OVER(ORDER BY SUM(total_sale) DESC) AS ranking
FROM retail_sales
GROUP BY category;


