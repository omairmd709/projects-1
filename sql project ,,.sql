
create table hospital(
order_id	int,
order_date	date,
city	varchar(100),
product	varchar(100),
therapeutic_area	varchar(100),
channel	varchar(100),
sales_rep	varchar(100),
units_sold	int,
unit_price	int,
discount	numeric(10,2),
revenue	numeric(10,2),
cost	numeric(10,2),
profit	numeric(10,2)
);
select *from hospital;

select city,sum(revenue)as total_revenue 
from hospital 
group by city;

--find top 5 products by total revenue
select product,sum(revenue)as total_revenue
from hospital
group by product
order by total_revenue desc limit 5;

--Find the average revenue per order for each sales channel.
select channel,avg(revenue)as avg_revenue
from hospital
group by channel
--Find all sales representatives whose total revenue is greater than ₹10,00,000.
select sales_rep,sum(revenue) as total_revenue
from hospital
group by sales_rep
having sum(revenue)>1000000;
--Find the number of orders and total units sold for each therapeutic area.

select distinct count(order_id)as number_orders,therapeutic_Area,
sum(units_sold)as total_unit_Sold
from hospital
group by therapeutic_area;

--Find cities where total revenue > ₹20,00,000 and total orders > 500.

select *from hospital;

select city,sum(revenue)as total_revenue ,
count(order_id)as total_orders
from hospital
group by city
having sum(revenue)>2000000 and count(order_id)>500;

--Find the product with the highest average profit per order.
select product,avg(profit)as avg_profit
from hospital
group by product
order by avg_profit desc limit 1;

--For each city, calculate total revenue total cost total profit profit margin %

select city ,sum(revenue)as total_revenue,
sum(cost)as total_cost,sum(profit)as total_profit,
(sum(profit)/sum(revenue) *100)as profit_margin 
from hospital
group by city;


--Create a column called sales_category:

--Revenue < ₹10,000 → Low
--₹10,000–₹30,000 → Medium

--₹30,000 → High
select order_id,city,product,revenue,
case
when revenue >=30000 then 'high'
when revenue between 10000 and 29999 then 'medium'
else 'low'
end as sales_category 
from hospital 
group by order_id, city,product,revenue;


-- Calculate the number of orders in each discount category:

--0% → No Discount
--5% → Low Discount
--10% → Medium Discount
--15% → High Discount


select 
case
when discount = 0.00 then 'zero discount'
when discount = 0.05 then 'low discount'
when discount = 0.10 then 'medium discount'
when discount = 0.15 then 'high discount'
end as discount_category,
count(*) as total_orders
from hospital group by discount;


--Q11. Find the second-highest revenue-generating product.

--Q12. Find the highest-revenue sales representative within each city.

--Q13. Find the top 3 sales representatives in terms of revenue for each therapeutic area.

--Q14. Find orders whose revenue is greater than the average order revenue.

--Q15. Find each product's percentage contribution to the overall company revenue.

select *from hospital;

--Q11. Find the second-highest revenue-generating product.
select * from(
select product,sum(revenue)as total_revenue,
rank()over(order by sum(revenue) desc)as rev_rank
from hospital
group by product
)as ranked_products
where rev_rank =2;
--Q12. Find the highest-revenue sales representative within each city.
with rep_revenue as (
select city,sales_rep,sum(revenue)as total_revenue
from hospital
group by city ,sales_rep
),
ranked as (select city,sales_rep,total_revenue,
rank()over(partition by city order by total_revenue desc)as rev_rank
from rep_revenue)
select city,sales_rep,total_revenue
from ranked
where rev_rank=1;
--Q13. Find the top 3 sales representatives in terms of revenue for each therapeutic area.
with rep_revenue as (
select sales_rep,therapeutic_area,sum(revenue)as total_revenue
from hospital
group by sales_rep,therapeutic_area
),
ranked as (
select sales_rep,therapeutic_area,total_revenue,
 rank() over (partition by therapeutic_area order by total_revenue desc)as rep_rank
from rep_revenue)
select sales_rep,therapeutic_area,total_revenue,rep_rank
from ranked
where rep_rank <=3;


--Q14. Find orders whose revenue is greater than the average order revenue.
with order_total as (
select order_id,sum(revenue)as total_revenue
from hospital
group by order_id
)
select order_id,total_revenue
from order_total
where total_revenue >(select avg(total_revenue)from order_total);

--Q15. Find each product's percentage contribution to the overall company revenue.
select sum(revenue)from hospital;
select *from hospital;
select product,(sum(revenue)/(select sum(revenue)as total_revenue from hospital)*100)as percent_contribution
from hospital
group by product;


--Q16. Rank products based on total revenue, from highest to lowest.
select product,sum(revenue)as total_revenue,
rank () over(order by sum(revenue) desc)as rev_rank
from hospital
group by product;


--Q17. For every city, rank sales representatives based on their total revenue.
select *from hospital;
with revenue as (
select city,sales_rep,sum(revenue)as total_revenue
from hospital
group by city,sales_rep
),
ranked as (select city,sales_rep,total_revenue,
rank()over(partition by city order by total_revenue desc )as rep_rank 
from revenue)
select city ,sales_rep,total_revenue,rep_rank
from ranked;

--Q18. Find the top 2 sales representatives in every city.

select *from hospital;
with revenue as (
select city,sales_rep,sum(revenue)as total_revenue
from hospital
group by city,sales_rep
),
ranked as (select city,sales_rep,total_revenue,
rank()over(partition by city order by total_revenue desc )as rep_rank 
from revenue)
select city ,sales_rep,total_revenue,rep_rank
from ranked
where rep_rank <=2;

--Q19. Calculate each sales representative's revenue and the previous-ranked representative's revenue within the same city.
with revenue as(
select city,sales_rep,sum(revenue)as total_revenue
from hospital
group by city ,sales_rep
)
select city,sales_rep,total_revenue,
lag(total_revenue)over(partition by city order by total_revenue desc)as prev_rep_revenue
from revenue;

--Q20. Calculate a running total of revenue ordered by order_date.
select * from hospital;


select order_date,sum(revenue)as daily_revenue,
sum(sum(revenue))over(order by order_date)as running_revenue 
from hospital
group by order_Date;

--Q21. Month-over-month sales
--Calculate total revenue for each month and show the previous month's revenue alongside it
select * from hospital;

with revenue as(
select to_char (order_date,'mon')as order_month,
extract (month from order_date),sum(revenue)as total_revenue
from hospital
group by to_char (order_date,'mon'),extract (month from order_date)
)
select order_month,total_revenue,
lag(total_revenue) over (order by order_month)as prev_month_revenue
from revenue
order by order_month;

--Q22. Month-over-month growth
--Calculate:
--(current month revenue - previous month revenue)
------------------------------------------------ × 100
--previous month revenue
--Return:

WITH month_o_month AS (
    SELECT 
        TO_CHAR(order_date, 'mon') AS order_month,
        EXTRACT(MONTH FROM order_date) AS month_num,
        SUM(revenue) AS cur_mon_revenue
    FROM hospital
    GROUP BY TO_CHAR(order_date, 'mon'), EXTRACT(MONTH FROM order_date)
)
SELECT 
    order_month,
    cur_mon_revenue,
    LAG(cur_mon_revenue) OVER (ORDER BY month_num) AS prev_month_revenue,
    ((cur_mon_revenue - LAG(cur_mon_revenue) OVER (ORDER BY month_num)) / LAG(cur_mon_revenue) OVER (ORDER BY month_num)) * 100 AS mom_growth
FROM month_o_month
ORDER BY month_num;


with month_o_month as (
select to_char (order_date,'mon')as order_month,
extract (month from order_date)as month_num,
sum(revenue)as current_month_revenue
from hospital
group by to_char (order_date,'mon'),
extract (month from order_date)
)
select order_month,month_num,current_month_revenue,
lag(current_month_revenue)over(order by month_num)as previous_month_revenue,
((current_month_revenue-lag(current_month_revenue) over (order by month_num)) / lag(current_month_revenue)over(order by month_num))*100 as mom_growth
from month_o_month
order by month_num;


--Q23. Best-performing city each month
--For every month, find the city with the highest revenue.

with revenue_r as (
select city,sum(revenue)as total_revenue,
to_char(order_Date,'mon')as order_month,
extract(month from order_date)as month_num
from hospital
group by city,to_char(order_Date,'mon'),
extract(month from order_date)
),
ranked as(select city,total_revenue,order_month,month_num,
rank()over( partition by month_num order by total_revenue desc  )as rnk from revenue_r
)
select city,total_revenue,order_month
from ranked
where rnk=1
order by month_num;
--Q24. Product contribution by city
--For every city, calculate each product's:
--product revenue
------------------------- × 100
--city's total revenue

WITH product_revenue AS (
    
    SELECT 
        city,
        product,
        SUM(revenue) AS prod_revenue
    FROM hospital
    GROUP BY city, product
),
contribution_calc AS (
 
    SELECT 
        city,
        product,
        prod_revenue,
       
        SUM(prod_revenue) OVER(PARTITION BY city) AS city_total_revenue,
        ROUND((prod_revenue / SUM(prod_revenue) OVER(PARTITION BY city)) * 100, 2) AS contribution_percentage
    FROM product_revenue
)
SELECT 
    city,
    product,
    prod_revenue,
    city_total_revenue,
    contribution_percentage
FROM contribution_calc
ORDER BY city, contribution_percentage DESC;

select * from hospital

with p_revenue as(
select product,city,sum(revenue)as product_revenue
from hospital
group by city,product
),
contribution as (
select city,product,product_revenue,
sum(product_revenue)over(partition by city )as  city_sp_revenue,
(product_revenue/sum(product_revenue)over (partition by city )* 100)as per_contribution
from p_revenue) 
select city,product,product_revenue,city_sp_revenue,per_contribution
from contribution 
order by city,per_contribution desc;

--Product contribution by city
--For every city, calculate each product's:
--product revenue
with city_revenue as(
select product, city,sum(revenue)as total_revenue
from hospital
group by city,product
),pro_contribution as(
select product,city,total_revenue,
(total_revenue/sum(total_revenue)over (partition by city ))*100 as pro_contribution
from city_revenue
)
select product,city,total_revenue as city_rev,pro_contribution
from pro_contribution
order by city ,pro_contribution desc;

--Q25. Top product per city
--Find the highest-revenue product in every city.

with city_rev as (
select product,city,sum(revenue)as total_revenue
from hospital
group by city,product
),ranked as (
select city,product,total_revenue,
rank()over (partition by city order by total_revenue desc)as rnk
from city_rev
)select product,city,total_revenue
from ranked
where rnk= 1;

--Q26. Underperforming cities
--Find cities whose revenue is below the average city revenue.
select* from(
select city,avg(revenue)as avg_revenue
from hospital
group by city
having avg(revenue)<(select avg(revenue) from hospital)
)

--Q27. Sales representative performance
--For every sales representative, calculate:
--•	Total revenue 
--•	Total profit 
--•	Profit margin 
--•	Rank within their city 

select city,sales_rep,sum(revenue)as total_revenue,
sum(profit)as total_profit,
(sum(profit)/sum(revenue))as profit_margin,
rank ()over(partition by city order by sum(revenue) desc )as rnk
from hospital
group by sales_rep,city


--Q28. Product performance
--Find products that have:
--•	Revenue above the average product revenue 
--•	AND profit margin above the average product profit margin. 
with product_metrics as(
select product,avg(revenue)as avg_revenue,
(sum(profit)/sum(revenue))as profit_margin
from hospital
group by product
)select * from product_metrics
where avg_revenue>(select avg(avg_revenue)from product_metrics) and profit_margin > (select avg (profit_margin)from product_metrics);


select * from hospital

--Q29. Channel analysis
--For each channel, calculate:
--•	Total revenue 
----•	Total orders 
--•	Average order revenue 
--•	Revenue contribution % 
--Then identify the best-performing channel by revenue

 select channel,sum(revenue)as total_revenue,
count(order_id)as total_orders,
avg(revenue)as avg_revenue,
(sum(revenue)/(select sum(revenue) from hospital))*100 as revenue_contribution
from hospital
group by channel;

--Q30. Sales decline investigation
--Management says:
"Revenue has declined in some cities. Identify the cities where revenue
in the second half of the year is lower than revenue in the first half."
--Write a query that returns:
--city
--H1_revenue
--H2_revenue
--difference

with city_sales as(
select city,
sum(case when extract (month from order_date) between 01 and 06 then revenue else 0 end)as h1_revenue,
sum(case when extract (month from order_date) between 07 and 12 then revenue else 0 end)as h2_revenue
from hospital
group by city 
) select city ,h1_revenue,h2_revenue,(h2_revenue-h1_revenue) as difference
from city_sales
where h2_revenue<h1_revenue;


--Q31. Top 2 products per therapeutic area
--Find the top 2 products by revenue within each therapeutic area.
select* from hospital
select * from(
select therapeutic_area,product,
sum(revenue)as total_revenue,
rank()over(partition by therapeutic_area order by sum(revenue) desc ) as ranked
from hospital
group by therapeutic_area,product
)t
where ranked <=2
________________________________________
--Q32. Sales representative above city average
--Find sales representatives whose revenue is higher than the average sales-representative revenue of their city.
select* from hospital

with city_revenue as(
select sales_rep,city,sum(revenue) as city_rev
from hospital
group by sales_rep,city
),avg_sales as (
select sales_rep,city,city_rev,avg(city_rev)over(partition by city)as avg_rev
from city_revenue
group by sales_rep,city_rev,city
) select sales_rep,city,city_rev,avg_rev
from avg_sales
where city_rev>avg_rev

--Q33. Highest-margin product in each city
--Find the product with the highest profit margin within every city.

select *from (select product,city,(sum(profit)/sum(revenue))*100 as profit_margin,
rank()over(partition by city order by (sum(profit)/sum(revenue))*100 desc)as ranked
from hospital
group by product,city)t
where ranked =1;

--Q34. Consecutive performance
--Find sales representatives whose revenue was higher than their previous-ranked representative's revenue within the same city.


with rep_revenue as(
select city, sales_rep,sum(revenue)as rep_revenue
from hospital
group by city,sales_rep
),prev_rep_revenue as(
select city,sales_rep,rep_revenue,
lag(rep_revenue)over(partition by city)as previous_rep
from rep_revenue
)select  city,sales_rep,rep_revenue,previous_rep
from prev_rep_revenue

--Q35. Business recommendation
--Write SQL to identify the best city based on:
--•	Revenue 
--•	Profit margin 
--•	Number of orders 

select city,max(revenue)as max_profit,
(sum(profit)/sum(revenue))*100 as profit_margin,
(count(order_id))as max_orders
from hospital
group by city
order by max_profit desc


--Q.36 Find products where:
--Revenue is above the average product revenue
--AND
--Profit margin is below the average product profit margin.
select * from hospital
with pro_revenue as (
select product,sum(revenue)as total_revenue,
(sum(profit)/sum(revenue))* 100 as pro_margin
from hospital
group by product
), avg_pr as(
select avg(total_revenue)as avg_revenue,
avg(pro_margin)as avg_margin
from pro_revenue
)select product,total_revenue,pro_margin,avg_revenue,avg_margin
from pro_revenue cross join avg_pr
where total_revenue> avg_revenue and pro_margin<avg_margin

--Q37.
--Identify the top-performing sales representative in each city, 
--but only consider representatives whose total revenue is greater than ₹10 lakh.


with ranked as(
select city,sales_rep,sum(revenue)as total_revenue,
rank()over(partition by city order by sum(revenue) desc )as ranked
from hospital
group by city,sales_Rep)
select city ,sales_rep,total_revenue
from ranked
where ranked=1
order by total_revenue desc;

--Q38.
--For each city, find the product that generated the highest revenue
--and calculate what percentage of that city's revenue came from that product.

with rev as (
select city,product,sum(revenue)as total_revenue,
rank()over(partition by city order by sum(revenue) desc)as  ranked
from hospital
group by city,product
),city_contribution as (
select city,product,total_revenue,ranked,
(total_revenue/(sum(total_revenue)over (partition by city))) *100 as contribution
from rev
)select city,product,total_revenue,contribution 
from city_contribution
where ranked =1;

--Q.39 Find the month with the highest total revenue for each product.

select product,order_month,total_revenue from (
select to_char(order_Date,'mon'),sum(revenue)as total_revenue,
extract(month from order_Date)as order_month,product,
rank ()over(partition by product order by sum(revenue) desc)as rnk
from hospital
group by to_char(order_Date,'mon'),extract(month from order_Date),product
)t
where rnk= 1
order by product;














































