# Retail-Orders-Analysis-Rest_API-Python_pandas-Mysql #

# Part 1 Extracting Data from Web platform 'Kaggle' to Jupyter Notebook
STEP 1 Go to kaggle website and sign in or sign up for a kaggle account
STEP 2 Go to settings option scroll down and look for API section and click on Create New Token
STEP 3 Once API token file is download, we need to paste that file in our local user directory 
       where we will find .kaggle folder we will replace the existing file with our new Api token file 
STEP 4 Open the project dataset and copy the URL showing as in example:- {only copy the green 
       highlighted part of url } https://www.kaggle.com/datasets/ vineetpatyal/retailorder-dataset
STEP 5 Launch Jupyter Notebook , where you will install python kaggle package and import kaggle
STEP 6 !kaggle datasets download vineetpatyal/retail-order-dataset -f orders.csv
       paste the copied url and run the above code to download zip file directly from Kaggle 
STEP 7 Import zipfile # package
       zip_ref = zipfile.ZipFile('orders.csv.zip’) zip_ref.extractall() #extract file to directory
       zip_ref.close() #close file 


# Part 2 Data Cleaning with Pandas
# Read data from the file and handle null values
: Replaced Null values in ship_mode column with NaN
# rename columns names, make them lower case and replace space with underscore
: Converted column names into lowercase and replaced spaces in column name with underscore symbol
# Derive new columns discount, 
sale price and profit: With basic aggregation such as Multiplication & subtraction Created 3 columns with discount, sale_price, Profit
# convert order date from object 
data type to DateTime: converted data type format for order_date column
# drop cost price, list price & 
discount percent columns.: Removed cost price, list price & discount percent columns from the data frame

# Part 3 Export Data from python (jupyter notebook) to Mysql Database
# Load the data into the MySQL server using append/replace function
STEP 1 !pip install pymysql and import pymysql
!pip install sqlalchemy and from sqlalchemy import create_engine
STEP 3 PART 1: engine = create_engine('mysql+pymysql://root:vip@Localhost/retail_orders’)
       PART 2 : df.to_sql('orders',engine,if_exists='append',index=False)
STEP 2 Created New Database in MySQL by name “retail_orders”
       Created Blank Table with all required columns as mentioned in our dataframe by name 
       “orders” with assigning appropriate data types to maintain Storage efficiency

# Part 4 Data Analysis on imported Data from python
# 1. Find Top 10 highest revenue genrating products
Select product_id,sum(sale_price) as Sales
from orders
group by product_id
order by Sales desc
Limit 10;

# 2. Find Top 5 highest Selling Products in each region
select region,product_id, Sales
from (
	Select region,product_id,sum(sale_price) as Sales,
         RANK() OVER (PARTITION BY region order by sum(sale_price) Desc) As product_rank
	From orders
    group by region,product_id
    ) As ranked_products
Where product_rank <= 5
Order by region, Sales Desc;

# 3 Find Month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
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

# 4 For each category which month had highest sales

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

# 5. Which sub category had highest growth by profit in 2023 compare to 2022

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
![Thumnail Image](https://github.com/VineetPatyal/Retail-Orders-Analysis-Rest_API-Python_pandas-Mysql/assets/152878178/3bf08a53-4067-498f-9402-66ec901d49d2)

