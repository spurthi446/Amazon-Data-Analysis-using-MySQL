-- Creating database
create database SQL_Capstone_Project;
-- Using database
use SQL_Capstone_Project;

-- Creating table in database
create table amazon_data(
	Invoice_ID varchar(30),
    Branch varchar(5),
    City varchar(20),
    Customer varchar(30),
    Gender varchar(10),
    Product_line varchar(50),
    Unit_Price decimal(10,2),
    Quantity INT,
    Tax float(6,4),
    Total decimal(10,6),
    Order_Date date,
    Order_Time time,
    Payment varchar(20),
    Cogs decimal(10,5),
    Gross_Margin_Percentage float(11,9),
    Gross_Income decimal(10,6),
    Rating decimal(3,1)
);

show create table amazon_data;

-- show created table
select * from amazon_data;

-- Select columns with null values in them
select * from amazon_data where Invoice_ID is NULL;

-- Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening.
alter table amazon_data add column timeofday varchar(20);

set sql_safe_updates=0;

update amazon_data set timeofday = case 
		when hour(Order_Time) between 6 and 11 or (hour(Order_Time)=12 and minute(Order_Time)=0) then 'Day'
		when hour(Order_Time) between 12 and 17 or (hour(Order_Time) =11 and minute(Order_Time)>0) then 'Afternoon'
		else 'Evening' end;
                        
-- Add a new column named dayname that contains the extracted days of the week on which the given transaction took place
alter table amazon_data add column dayname varchar(10);

update amazon_data set dayname=dayname(Order_Date);

-- Add a new column named monthname that contains the extracted months of the year on which the given transaction took place 
alter table amazon_data add column monthname varchar(10);

update amazon_data set monthname=monthname(Order_Date); 

-- Business Questions to Answer:
select * from amazon_data limit 5;

-- 1.What is the count of distinct cities in the dataset?
select distinct City from amazon_data;

-- 2.For each branch, what is the corresponding city?
select distinct Branch,City from amazon_data ;

-- 3.	What is the count of distinct product lines in the dataset?
select count(distinct Product_line) from amazon_data;

-- 4.	Which payment method occurs most frequently?
select payment,count(*) as payment_count from amazon_data group by payment;

-- 5.Which product line has the highest sales?
select product_line,sum(total) as total_sales from amazon_data group by product_line order by total_sales desc limit 1;

-- 6.How much revenue is generated each month?
select monthname,sum(total) from amazon_data group by monthname;

-- 7.In which month did the cost of goods sold reach its peak?
select monthname,sum(cogs) as total_cogs from amazon_data group by monthname order by total_cogs desc limit 1;

-- 8.Which product line generated the highest revenue?
select product_line,sum(total) as total_revenue from amazon_data group by product_line order by total_revenue desc;

-- 9.In which city was the highest revenue recorded?
select city, sum(total) as total_sales from amazon_data group by city order by total_sales desc limit 1;

-- 10.Which product line incurred the highest Value Added Tax?
select product_line,sum(tax) as total_tax from amazon_data group by product_line order by total_tax desc limit 1;

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
select product_line,case when sum(total)>(select avg(total) from amazon_data) then 'Good' 
	else 'Bad' end as 'Product_Line_performance' from amazon_data group by product_line;
    
-- 12.Identify the branch that exceeded the average number of products sold.
select Branch from amazon_data group by Branch having avg(quantity)>(select avg(quantity) from amazon_data);

-- 13.Which product line is most frequently associated with each gender?
select gender, product_line,count(product_line) as product_line_count from amazon_data 
group by gender,product_line order by product_line_count desc;

-- 14. Calculate the average rating for each product line
select product_line,avg(rating) from amazon_data group by product_line;

-- 15.Count the sales occurrences for each time of day on every weekday.
SELECT dayname, timeofday, COUNT(*) AS num_sales
FROM amazon_data
WHERE DAYOFWEEK(order_date) not in (1,7)
GROUP BY dayname, timeofday
ORDER BY num_sales DESC;

-- 16.Identify the customer type contributing the highest revenue.
select customer, sum(total) as total_revenue from amazon_data group by customer;

-- 17Determine the city with the highest VAT percentage.
select city, (sum(tax)/(select sum(tax) from amazon_data))*100 as tax_percentage from amazon_data group by city;

-- 18.Identify the customer type with the highest VAT payments.
select customer,sum(Tax) as max_VAT from amazon_data group by customer;

-- 19.What is the count of distinct customer types in the dataset?
SELECT COUNT(DISTINCT customer) AS distinct_customer_type_count
FROM amazon_data;

-- 20.What is the count of distinct payment methods in the dataset?
SELECT COUNT(DISTINCT payment) AS distinct_payment_methods_count
FROM amazon_data;

-- 21.Which customer type occurs most frequently?
select customer,count(*) as customer_frequency from amazon_data group by customer order by customer_frequency desc;

-- 22.Identify the customer type with the highest purchase frequency.
select customer,count(*) as customer_count from amazon_data group by customer;

-- 23.Determine the predominant gender among customers.
select gender, count(*) as gender_count from amazon_data group by gender;

-- 24.Examine the distribution of genders within each branch.
select branch,gender,count(*) as gender_count from amazon_data group by branch,gender order by branch,gender;

-- 25.Identify the time of day when customers provide the most ratings.
select timeofday, count(rating) as rating_count from amazon_data group by timeofday order by rating_count desc;

-- 26.Determine the time of day with the highest customer ratings for each branch.
SELECT branch,timeofday
FROM (
	SELECT branch, timeofday, COUNT(*) AS rating_count,
	ROW_NUMBER() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS row_num
    FROM amazon_data
    GROUP BY branch, timeofday
) AS ratings_by_time
WHERE row_num = 1
ORDER BY branch;

-- 27.Identify the day of the week with the highest average ratings.
select dayname,avg(rating) as avg_rating from amazon_data group by dayname order by avg_rating desc limit 1; 

-- 28.Determine the day of the week with the highest average ratings for each branch.
SELECT branch, dayname FROM (
    SELECT branch, dayname, AVG(rating) AS avg_rating,
	ROW_NUMBER() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS row_num
    FROM amazon_data
    GROUP BY branch, dayname
) AS ranked_days
WHERE row_num = 1;

