#1. Find Top 10 highest revenue genrating products
Select product_id,sum(sale_price) as Sales
from orders
group by product_id
order by Sales desc
Limit 10;

#2. Find Top 5 highest Selling Products in each region
select region,product_id, Sales
from (
	Select region,product_id,sum(sale_price) as Sales,
         RANK() OVER (PARTITION BY region order by sum(sale_price) Desc) As product_rank
	From orders
    group by region,product_id
    ) As ranked_products
Where product_rank <= 5
Order by region, Sales Desc;

#3 Find Month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
SELECT
    month(order_date) AS order_month,
    SUM(CASE WHEN year(order_date) = 2022 THEN sale_price ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN year(order_date) = 2023 THEN sale_price ELSE 0 END) AS sales_2023
FROM
    orders
GROUP BY
    month(order_date)
ORDER BY
    month(order_date);

#4 For each category which month had highest sales

With monthly_sales as
(SELECT category,
CONCAT(YEAR(order_date), '-', LPAD(MONTH(order_date), 2, '0')) AS order_yearmonth,
SUM(sale_price) as sales,
ROW_NUMBER() OVER(partition by category order by sum(sale_price) desc) as highest_monthsale
FROM orders
group by category,CONCAT(YEAR(order_date), '-', LPAD(MONTH(order_date), 2, '0'))
)
select 
category, order_yearmonth, sales
from
monthly_sales
Where
highest_monthsale = 1
Order by category,order_yearmonth;

#5. Which sub category had highest growth by profit in 2023 compare to 2022

With cte as
(Select sub_category,
year(order_date) as order_year,
sum(profit) as profit
from orders
group by sub_category,year(order_date)
),
cte2 as (SELECT
    sub_category,
    SUM(CASE WHEN order_year = 2022 THEN profit ELSE 0 END) AS profit_2022,
    SUM(CASE WHEN order_year = 2023 THEN profit ELSE 0 END) AS profit_2023
FROM cte
group by sub_category
)
Select *,
(profit_2023 - profit_2022) as profit_growth
from cte2
ORDER BY
    (profit_2023 - profit_2022) desc
    Limit 1;










