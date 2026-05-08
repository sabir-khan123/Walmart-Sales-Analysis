select * from walmart;


select distinct payment_method from walmart;

select payment_method,count(*) from walmart group by payment_method

select count(distinct payment_method ) from walmart;

-- Q1. Find the different payment method,number of transaction,number of quantity sold
select payment_method, count(*) as no_of_transactions , sum(quantity) as total_qty_sold from walmart group by payment_method;

-- Q2. Find the highest avg rating for each branch and category
select * from
(select
	branch,
	category,
	avg(rating) as avg_rating,
    rank() over(partition by branch order by avg(rating) desc) as ranking
from walmart
group by branch,category) as t
where ranking=1

-- Q3. Find the busiest day for each branch based on the number of transactions.
select branch,day_name,trans from
(select 
	branch,
    dayname(date) as day_name,
    count(*) as trans,
    rank() over(partition by branch order by count(*) desc) as ranking 
from walmart 
group by branch,dayname(date)) as t
where ranking=1
order by branch,day_name

-- Q4. Calculate the total quantity of items sold per payment method.
select payment_method,count(*) as trans_per_method, sum(quantity) total_qty from walmart group by payment_method

-- Q5. Determine the average,min,max rating for each category and city.
select city, category, avg(rating) as avg_rating, min(rating) as min_rating, max(rating) as max_rating from walmart group by city,category order by city,category

-- Q6. Calculate the total project for each category by considering total_profit=qty*unit_price*profit_margin
select category, sum(total*profit_margin) as total_profit from walmart group by category order by total_profit desc

-- Q7. Determine the most common payment method for each branch
select branch,payment_method as preferred_payment_method from
(select 
	branch,
    payment_method,
    count(*) as trans,
    rank() over(partition by branch order by count(*) desc) as ranking
from walmart
group by branch,payment_method) as t
where ranking=1

-- Q8. Categorize sales into 3 groups morning,afternoon,evening and find out each of the shift and number of invoices
select branch,
case when hour(str_to_date(time, '%H:%i:%s')) < 12 then 'Morning'
	 when hour(str_to_date(time, '%H:%i:%s')) between 12 and 17 then 'Afternoon'
     else 'Evening' 
     end as timing,
count(*) as no_of_trans
from walmart
group by branch,
case when hour(str_to_date(time, '%H:%i:%s')) < 12 then 'Morning'
	 when hour(str_to_date(time, '%H:%i:%s')) between 12 and 17 then 'Afternoon'
     else 'Evening' 
     end
order by branch,no_of_trans desc

-- Q9. Identify 5 branches with highest decrease in revenue as compared to last year's revenue

with revenue_2022 as
(select branch,sum(total) as revenue_22 from walmart 
where year(str_to_date(date, '%d/%m/%y')) = 2022
group by branch),
revenue_2023 as
(select branch,sum(total) as revenue_23 from walmart 
where year(str_to_date(date, '%d/%m/%y')) = 2023
group by branch)

select a.branch,a.revenue_22,b.revenue_23, round(((a.revenue_22 - b.revenue_23)*100)/a.revenue_22,2) percent_dec_revenue from revenue_2022 as a
join
revenue_2023 as b
on a.branch=b.branch
where a.revenue_22 > b.revenue_23
order by percent_dec_revenue desc limit 5
