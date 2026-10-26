create database super_store ;
CREATE TABLE superstore_sales (
    Row_ID INT,
    Order_ID VARCHAR(50),
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode VARCHAR(50),
    Customer_ID VARCHAR(50),
    Customer_Name VARCHAR(100),
    Segment VARCHAR(50),
    Country VARCHAR(100),
    City VARCHAR(100),
    State VARCHAR(100),
    Postal_Code VARCHAR(20),
    Region VARCHAR(50),
    Product_ID VARCHAR(50),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50),
    Product_Name VARCHAR(255),
    Sales DECIMAL(12,2),
    Quantity INT,
    Discount DECIMAL(5,2),
    Profit DECIMAL(12,2)
);

LOAD DATA LOCAL INFILE 'C:/Users/hp/Downloads/superstore_sales_data.csv'
INTO TABLE superstore_sales
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET GLOBAL local_infile = 1;

select * from superstore_sales;
----------------------------------------------------------------------
1:  the total number of orders in the Superstore dataset

select count(*) from 
superstore_sales; 

 To count how many orders the company received.
 
-----------------------------------------------------------------------
Q2.  the total Sales, total Profit, and total Quantity.

select sum(Sales) as total_sales,
	   sum(Profit)as total_profit,
	   sum(Quantity)as total_quantity
from superstore_sales;

To check total sales, total profit, and total quantity sold.

-------------------------------------------------------------
Q3.  the Top 10 Products by Sales

select`Product Name` , round(sum(Sales),2)as total_sales
from superstore_sales
group by `Product Name` 
order by total_sales desc	
limit 10;

To find the 10 products with the highest sales.

----------------------------------------------------------------
Q4. Total Sales by Category

select `Category` , round(sum(Sales),2)as total_sales
from superstore_sales
group by `Category` 
order by total_sales desc 
;

To find total sales for each category.

---------------------------------------------------------------
Q5. Total Profit by Region

select `Region` , round(sum(Profit),2)as total_profit
from superstore_sales
group by `Region` 
order by total_profit desc ;

To find the total profit for each region.

----------------------------------------------------------------------
Q6. Sales by Segment

select Segment , round(sum(Sales),2)as total_sales
from superstore_sales
group by segment 
order by total_sales desc ;

To find total sales for each customer segment.

-------------------------------------------------------------
Q7. Find Loss-Making Products

select `Product Name`, round(sum(Profit),2)as total_loss_making
from superstore_sales 
group by `Product Name` 
having total_loss_making < 0 
order by total_loss_making desc;

To find products that make a loss.

------------------------------------------------------------------------
Q8. Monthly Sales Trend 

select date_format(str_to_date
(`Order Date` ,'%d-%m-%Y' ), '%Y-%m')as sales_month , 
round(sum(Sales),2) as total_sales 
from superstore_sales 
group by sales_month 
order by sales_month desc;

To track monthly sales and identify trends over time.

---------------------------------------------------------------
Q9. Average Discount by Category 

select Category , round(avg(Discount),2) as avg_discount 
from superstore_sales 
group by Category ;

To find the average discount for each category.

------------------------------------------------------------
Q10. Orders by Ship Mode 

select `Ship Mode` , count(`order ID`)as total_order 
from superstore_sales 
group by `ship Mode`; 

To find the total number of orders for each ship mode.

------------------------------------------------------
Q11. Category-wise Sales, Profit and Profit Margin 

select Category, 
 round(sum(Sales),2)as total_sales ,
 round(sum(Profit),2)as total_profit,
 round(sum(Profit)/ sum(Sales) * 100 ,2) as profit_marging
 from superstore_sales
 group by Category 
 order by profit_marging desc;
 
 To compare sales, profit, and profit margin for each category.
 
 ------------------------------------------------------------
Q12 . Discount Impact on Profit 

select Discount , 
round(sum(Profit), 2) as total_profit ,
round(sum(Sales) , 2)as total_sales 
from superstore_sales 
group by Discount 
order by Discount desc;

To check how discounts affect profit.

------------------------------------------------
Q13. Top 10 Most Profitable Products 

select `Product Name` ,
round(sum(Profit) , 2)as total_profit 
from superstore_sales 
group by `Product Name` 
order by total_profit desc 
limit 10 ;

To find the 10 products that generate the highest profit.

----------------------------------------------
Q14 . Loss-Making Products 

select  `Product Name` ,
round(sum(Profit) , 2)as total_loss
from superstore_sales 
group by `Product Name`,
having total_loss < 0
order by total_loss asc 
limit 10 ;

To find products that generate a loss.

--------------------------------------------------
Q15 . Sales and profit Performance by Region 

select Region , 
round(sum(Profit),2) as total_profit ,
round(sum(Sales),2)as total_sales , 
round(sum(Profit) / sum(Sales) * 100 ,2)as total_profit_margin ,
rank() over ( order by sum(Profit) / sum(Sales) * 100 desc ) as rnk 
from superstore_sales 
group by Region ;

To identify which region performs best in terms of profit margin.

-----------------------------------------------------------
Q16. Rank Products by Profit Within Each Category
 
with product_rnk as (
select Category , 
`Product Name` , 
sum(Profit) as total_profit, 
DENSE_RANK() over (partition by Category order by sum(Profit) desc 
)as rnk 
from superstore_sales 
group by Category , `Product Name`
)
select * from product_rnk 
where rnk <= 3 ; 

To identify the most profitable products in each category

--------------------------------------------------
Q17 . Find orders where profit is negative despite sales being above the average order sales. 

with G_order as (
select `Order ID` , 
round(sum(Sales), 2 )as total_sales,
round(sum(Profit), 2 ) as total_profit 
from superstore_sales 
group by `Order ID` 
),
COR as (
select * from G_order 
where total_sales > (select 
avg(total_sales) as avg_sales 
from G_order )
) 
select * from COR
where total_profit < 0 ;

To identify high-value orders that still generate losses.

-----------------------------------------------------------------
Q18 . Compare sales and profit across Ship Modes for each Region.

select Region , 
`Ship Mode`,
sum(Sales) as total_sales , 
sum(Profit) as total_profit 
from superstore_sales 
group by Region , `Ship Mode` ; 

To compare shipping methods and regional performance 

-------------------------------------------------------------------------------
Q19 . Find customers whose total sales are greater
 than the average total sales per customer, and rank them by total profit.

with cte1 as (
select `Customer ID`, 
`Customer Name`,
sum(sales) as total_sales , 
sum(profit) as total_profit 
from superstore_sales 
group by `Customer ID` , `Customer Name` 
),
cte2 as (
select * from cte1 
where total_sales > (select 
avg(total_sales) as avg_salary 
from cte1 )
)
select * , rank() 
over (
order by total_profit 
) as rnk 
from cte2 ;

To identify high-sales customers and compare their profitability

-------------------------------------------------------------
Q20 . a business summary showing total sales, total profit, profit margin, distinct order
 count, and profit ranking for each sub-category.

select `Sub-Category` , 
round(sum(Sales),2) as total_sales ,
round(sum(Profit),2) as total_profit , 
count(`Order ID`)as total_order,
round(sum(Profit) / sum(Sales) * 100 ,2) as profit_margin ,
rank() over (order by sum(Profit)desc )
as rnk 
from superstore_sales 
group by `Sub-Category` ;

to summarize sales, profit, profit margin, order count, and profit ranking for each sub-category
------------------------------------------------------------



































































































































































































































































































































































































