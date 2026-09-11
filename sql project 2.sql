select * from public_sales
create table public_sales (
order_id	serial primary key,
order_date	date,
customer_id	int,
customer_name	varchar(100),
city	varchar(100),
signup_date	date,
product_id	varchar(100),
product_name	varchar(100),
category	varchar(100),	
unit_price	numeric(10,2),
quantity	int,
discount_pct	numeric(10,2),
gross_revenue	numeric(10,2),
discount_amount	numeric(10,2),
revenue	numeric(10,2),
status	varchar(100),
payment_method	varchar(100),
rep_id	int,
rep_name varchar(100),
region	varchar(100)
);
drop table if exists public_sales;
 select * from public_sales

--1.	Find the average discount percentage for each product category. 

select category ,
round (avg(discount_pct),2) as avg_discount
from public_sales
group by category;


--2.	Find the category with the highest average selling price. 


select category,avg(unit_price*quantity)as avg_selling
from public_sales
group by category
order by avg_selling desc limit 1;

ALTER TABLE public_sales RENAME TO psale;
select * from psale


--3.	Find the city with the highest average order value. 

select city,avg(unit_price*quantity)as average_order_Value
from psale
group by city
order by average_order_Value desc limit 1



--4.	Calculate the discount amount as a percentage of gross revenue for each month. 

select * from psale


select to_char(order_date,'mon') , extract (month from order_date)as order_month,city,
(sum(discount_amount)/nullif(sum(gross_revenue),0))*100 as percent_of_gross_revenue,
rank()over(partition by city)
from psale
group by to_char(order_date,'mon'), extract(month from order_date),city
order by order_month asc

--5.	Find products where the average quantity per order is greater than 3.
select * from psale

select * from(
select product_name,round (avg(quantity),3)as avg_quanttity_ordered
from psale
group by product_name
)t 
where avg_quanttity_ordered>3


--6.	Find the top 5 cities by number of unique customers. 
select * from psale
 select distinct count(customer_id)as unique_customer,city
 from psale
 group by  city
 order by unique_customer desc limit 5

--7.	Find the percentage of orders that are delivered in each region. 
select * from psale

select region,(count(*) filter(where status ='Delivered')*100.0/nullif (count(*),0))as percent_Delivery
from psale
group by region
order by region ;


--8.	Find the sales representatives who handle customers from more than 5 cities. 

select rep_id,
count(distinct city)as city
from psale
group by rep_id
having count(distinct city)>5


--9.	Find the product category with the highest cancellation rate. 
select * from psale


select category,
count(*)filter(where status='Cancelled')as cancelled_orders
from psale
group by category 
order by cancelled_orders desc limit 1


--10.	Find the month with the highest number of delivered orders. 

select to_char(order_date,'mon'), extract(month from order_date)as order_month,
count(*)filter(where status='Delivered')as delivered_orders
from psale
group by  to_char(order_date,'mon'),extract (month from order_date)
order by delivered_orders desc limit 1


--11.	Find customers whose first-ever order was delivered.
select * from psale

with ranked_order as (
select order_date,customer_name,quantity,status,
rank()over(partition by customer_name order by order_Date asc)as early_order from psale
)select order_Date,customer_name,early_order,quantity,status
from ranked_order
where early_order=1 and status = 'Delivered'
order by order_date asc

12.	Find customers who have both cancelled and delivered orders. 
select customer_name 
from psale
where status in('Delivered','Cancelled')
group by customer_name
having count(distinct status)=2;

--13.	Find customers whose average order value is higher than the overall average order value. 
select * from psale

with avg_order as(
select customer_name,avg(quantity*unit_price)as avg_order_value
from psale
group by customer_name
)select customer_name,avg_order_value from avg_order
where avg_order_value>(select avg(quantity*unit_price) from psale)


--14.	Find products where discounted revenue exceeds ₹10 lakh 

select* from(
select product_name,sum(revenue)as total_revenue from psale
group by product_name)t
where total_revenue>1000000



15.	Find the city where the difference between gross revenue and net revenue is highest. 
select * from psale
select city,
(sum(gross_revenue)-sum(revenue))as differnce_of_revenue
from psale
group by city
order by differnce_of_revenue desc limit 1

--16.	Find the sales representative with the highest average order value in each region. 
with avg_order as(
select region,rep_name,avg(quantity*unit_price)as avg_value
from psale
group by rep_name,region
),ranked as(select rep_name,avg_value,region,
rank()over(partition by region order by avg_value desc)as rnk from avg_order
)select rep_name,region,avg_value
from ranked
where rnk=1;

--17.	Find the most popular payment method in each city. 

select * from(select city,payment_method,
rank()over (partition by city order by count(*)desc )as rnk
from psale
group by city,payment_method
)t
where rnk=1;

------OR BY THIS -------------------
with payment_count as(
select city,payment_method,count(payment_method)as count_payment
from psale
group by city,payment_method
),ranked_payment as(
select city,payment_method,count_payment,
rank()over(partition by city order by count_payment desc)as rnk 
from payment_count
)select city,payment_method,count_payment
from ranked_payment
where rnk=1;

select * from psale
18.	Find customers who have purchased the same product more than once. 
select * from (
select product_name,customer_name , count(customer_name)as customer
from psale
group by product_name,customer_name
)t
where customer >=2;

SELECT 
    product_name, 
    customer_name, 
    COUNT(*) AS purchase_count
FROM 
    psale
GROUP BY 
    product_name, 
    customer_name
HAVING 
    COUNT(*) >= 2;


19.	Find products that have been purchased by customers from at least 5 different cities.

select * from (
select product_name,count(distinct city)as city_count
from psale
group by product_name
)t
where city_count>=5;



select * from psale

20.	Find the category with the highest revenue per unit sold. 

select category,(round(sum(revenue)/sum(quantity)),2) as total_revenue_per_unit
from psale
group by category
order by total_revenue_per_unit desc limit 1

--21.	For every sales representative, calculate their revenue rank within their region. .

select rep_name,region,sum(revenue)as total_revenue,
rank()over(partition by region order by sum(revenue))as rep_rank
from psale
group  by rep_name,region


--22.	For every city, find the top 3 product categories by revenue. 
select * from psale
select * from(
select city,category,sum(revenue)as total_Revenue,
rank()over(partition by city order by sum(revenue)desc)as ranked
from psale
group by city ,category)t
where ranked <=3;


select * from psale
--23.	For every month, find the top 3 cities by revenue. 
with revenue_ranked as(
select to_char(order_date,'MON')as month_name,extract (month from order_date)as month_number,
city,sum(revenue)as total_revenue,
rank()over(partition by extract(month from order_date))as ranked_rev
from psale
group by to_char(order_date,'MON'),extract (month from order_date),city
)
select month_name,month_number,city,total_revenue from revenue_ranked 
where ranked_rev<=3
select * from psale
--24.	Calculate each month's revenue and its percentage contribution to annual revenue. 
with pcont as(
select to_char(order_date,'MON')order_month_name,extract (month from order_date)as order_month,
sum(revenue)as total_revenue,
(sum(revenue)/(select sum(revenue) from psale)) *100 as percent_contribution
from psale
group by to_char(order_date,'MON'),extract (month from order_date)
)
select order_month_name,order_month,total_revenue,percent_contribution
from pcont
order by order_month asc

--25.	Find each customer's second-largest order. 
SELECT *
FROM (
    SELECT
        customer_name,
        order_id,
        order_date,
        quantity,
        revenue,
        DENSE_RANK() OVER (
            PARTITION BY customer_name
            ORDER BY revenue DESC
        ) AS rnk
    FROM psale
) t
WHERE rnk = 2;


26.	Find the first product purchased by each customer. 

select * from(
select customer_name,product_name,order_date,
rank()over(partition by customer_name order by order_date asc)as rnk
from psale
group by customer_name,product_name,order_date
)t
where rnk=1;
select * from psale
--27.	Find the product with the largest month-over-month revenue increase. 

with monthly_revenue as(
select extract(month from order_date)as order_month,sum(revenue)as total_revenue,
product_name
from psale
group by extract(month from order_date),product_name
),prev_month_rev as(
select order_month,total_revenue,product_name,
lag(total_revenue)over(partition by product_name order by order_month)as prev_month
from monthly_revenue
)select order_month,product_name,total_revenue,prev_month,
total_revenue-prev_month as revenue_change
from prev_month_rev 
WHERE prev_month IS NOT NULL
ORDER BY order_month asc


--28.	Find the sales representative whose revenue growth from their first active month to their latest active month is highest. 
select * from psale




--29.	Find the 3rd highest-revenue customer in each region. 
select * from (
select customer_name,sum(revenue)as total_revenue,
region,
rank()over(partition by region order by sum(revenue)desc)as ranked
from psale
group by customer_name,region
)t
where ranked =3;

--30.	For every category, find the product that generated the highest revenue each month. 
select * from (
select to_char(order_date,'MON')as month_name,extract(month from order_date)as month_num,category,
product_name,sum(revenue)as total_Revenue,
dense_rank()over(partition by extract(month from order_date) order by sum(revenue)desc)as ranked 
from psale
group by to_char(order_date,'MON'),extract(month from order_date),category,product_name
)t
where ranked =1
order by month_num asc

--31.	Find customers whose latest order value is greater than their average historical order value. 
with latest_order as(
select customer_name,revenue,order_date,
first_value(revenue)over(partition by customer_name order by order_date desc)as latest_order,
avg(revenue)over(partition by customer_name)as avg_revenue
from psale 
)select distinct customer_name,latest_order,round((avg_revenue),2)as avg_revenue
from latest_order
where latest_order>avg_revenue;

--32.	Find customers whose every delivered order had a discount of at least 10%. 
select customer_name,discount_pct,status
from psale
where discount_pct >=0.10 and status = 'Delivered'

--33.	Find the longest consecutive sequence of months in which each city generated revenue above ₹10 lakh. 

select * from(
select to_char(order_date,'MON')as order_month,extract(month from order_date)as month_num,
sum(revenue)as total_revenue , city,
rank()over(partition by city order by sum(revenue)desc)
from psale
group by to_char(order_date,'MON'),extract(month from order_date),city 
)t 
where total_revenue>1000000
order by city ;

select * from psale
--34.	Find products whose monthly revenue rank improved for two consecutive months. 
WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        product_name,
        SUM(revenue) AS total_revenue
    FROM psale
    GROUP BY DATE_TRUNC('month', order_date), product_name
),

ranked AS (
    SELECT
        month,
        product_name,
        total_revenue,
        RANK() OVER (
            PARTITION BY month
            ORDER BY total_revenue DESC
        ) AS revenue_rank
    FROM monthly_revenue
),

with_previous AS (
    SELECT
        product_name,
        month,
        revenue_rank,

        LAG(revenue_rank, 1) OVER (
            PARTITION BY product_name
            ORDER BY month
        ) AS prev_rank,

        LAG(revenue_rank, 2) OVER (
            PARTITION BY product_name
            ORDER BY month
        ) AS prev_2_rank

    FROM ranked
)

SELECT DISTINCT product_name
FROM with_previous
WHERE revenue_rank < prev_rank
  AND prev_rank < prev_2_rank;

--35.	Find the month in which each region had its highest revenue, along with the revenue and rank of that month. 
with monthly_revenue as(
select to_char(order_date,'MON')as month_name,region,sum(revenue)as total_revenue
from psale
group by  to_char(order_date,'MON'),region
),ranked as (
select month_name,total_revenue,region,
rank()over(partition by region order by total_revenue desc)as rankeds
from monthly_revenue
)select month_name,region,total_revenue,rankeds
from ranked
where rankeds = 1
order by total_revenue desc

--36.	Find customers whose cumulative revenue crossed ₹1 lakh, and return the exact order on which they crossed it. 
with cumulative_Revenue as(
select customer_name,order_date,order_id,customer_id,
sum(revenue)over(partition by customer_id order by order_date,order_id)as total_revenue
from psale
), threshold as (
select customer_name,order_date,order_id,total_revenue,customer_id,
row_number()over(partition by customer_id order by order_date,order_id)as ranks
from cumulative_Revenue
where total_revenue >=100000
)select customer_name,customer_id,order_date,order_id,total_revenue,ranks
from threshold
where ranks=1

--37.	For each sales representative, calculate the percentage of their total orders that were cancelled and rank them within their region. 
with cancelled_orders as(
select region,rep_name,count(*) as total_orders,
count(*)filter(where status='Cancelled')as cancelled_order
from psale
group by region,rep_name
),ranked as (
select region,rep_name,total_orders,cancelled_order,
round((cancelled_order*100.0/total_orders ),2)as percentage_cancelled,
rank()over(partition by region order by (cancelled_order*100.0/total_orders ))as rnk
from cancelled_orders
)select region,rep_name,total_orders,cancelled_order,percentage_cancelled,rnk
from ranked


--38.	Find the top 5 customers by revenue in every month, and calculate how many times each customer appeared in the monthly top 5.
with customer as (
select customer_name,extract(month from order_Date)as order_month,sum(revenue)as total_revenue,
dense_rank()over(partition by extract(month from order_Date) order by sum(revenue)desc )as rnk
from psale
group by customer_name,extract(month from order_Date)
),filtered as (
select customer_name,total_revenue,rnk,order_month from customer
where rnk <=5
)select order_month, customer_name,total_revenue,rnk,
count(customer_name)as appeared
from filtered 
group by order_month,customer_name,total_revenue,rnk
order by order_month asc;

--39.	Find the product category whose revenue growth was higher than the overall company's revenue growth for each month. 
WITH comp_revenue AS (
    SELECT 
        EXTRACT(MONTH FROM order_date) AS order_month,
        SUM(revenue) AS current_comp_revenue,
        LAG(SUM(revenue)) OVER(ORDER BY EXTRACT(MONTH FROM order_date)) AS prev_m_comp_revenue
    FROM psale
    GROUP BY EXTRACT(MONTH FROM order_date)
),
category_revenue AS (
    SELECT 
        category,
        EXTRACT(MONTH FROM order_date) AS order_month,
        SUM(revenue) AS current_cat_revenue,
        LAG(SUM(revenue)) OVER(PARTITION BY category ORDER BY EXTRACT(MONTH FROM order_date)) AS prev_cat_revenue
    FROM psale
    GROUP BY category, EXTRACT(MONTH FROM order_date)
),
growth_calculation AS (
    SELECT 
        c.category,
        c.order_month,
        ((c.current_cat_revenue - c.prev_cat_revenue) / c.prev_cat_revenue) * 100 AS cat_mon_growth,
        ((p.current_comp_revenue - p.prev_m_comp_revenue) / p.prev_m_comp_revenue) * 100 AS comp_mon_growth
    FROM category_revenue c 
    JOIN comp_revenue p ON c.order_month = p.order_month
    WHERE p.prev_m_comp_revenue IS NOT NULL AND c.prev_cat_revenue IS NOT NULL
)
SELECT 
    order_month,
    category,
    ROUND(cat_mon_growth, 2) AS category_growth_pct,
    ROUND(comp_mon_growth, 2) AS company_growth_pct
FROM growth_calculation 
WHERE cat_mon_growth > comp_mon_growth
ORDER BY order_month ASC, category_growth_pct DESC;


--40.	Build a monthly management summary showing revenue, gross revenue, 
--discount amount, delivered-order rate, cancellation rate, AOV, and month-over-month revenue growth.
------------SUMMARY DATA -------------
select * from psale

select to_char(order_date,'YYYY-MM')as order_month,
count(*)as total_orders
from psale 
group by to_char(order_date,'YYYY-MM')
order by order_month

select to_char(order_date,'YYYY-MM')as order_month,
sum(revenue)as total_revenue
from psale 
group by to_char(order_date,'YYYY-MM')
order by order_month 
select count(case when status = 'Delivered' then 1 end)*100.0/
count(*)as delivered_order_rate
from psale
--summary data
with monthly_summary as(
select to_char(order_date,'YYYY-MM')as order_month,
sum(revenue)as total_revenue,
sum(gross_revenue)as total_gross_revenue,
sum(discount_amount)as total_discount,
count(case when status = 'Delivered' then 1 end)*100.0/
count(*)as delivered_order_rate,
count(case when status = 'Cancelled' then 1 end)*100.0/
count(*)as Cancelled_order_rate,
sum(revenue)/count(order_id)as AOV
from psale
group by to_char(order_date,'YYYY-MM')
order by order_month
),previous_month_revenue as(
select *,
lag(total_revenue)over(order by order_month)as previous_month_revenue
from monthly_summary
) select *,round((total_revenue-previous_month_revenue)*100/previous_month_revenue,2 ) as MOM_growth 
from previous_month_revenue
order by order_month






