select * from customer limit 20

-- what is the total revenue genrated by male Vs female customers.
select gender, SUM(purchase_amount) as revenue
from customer
group by gender

-- which customer used a discount but still spent more than average purchase amount.
select customer_id, purchase_amount
from customer
where discount_applied = 'Yes' and purchase_amount >= (select AVG(purchase_amount) from customer)

-- which are the top5 products with the highest average review rating.
select item_purchased, ROUND(AVG(review_rating::numeric),2) as "Average Product Rating"
from customer
group by item_purchased
order by avg(review_rating) desc
limit 5;

-- compare the average purchase amount between Standard and Express shipping.
select shipping_type,
ROUND(AVG(purchase_amount),2)
from customer
where shipping_type in ('Standard','Express')
group by shipping_type

-- Do subscribe customers spend more? compare average spend and total revenue between subscribers and Non-subscribers.
select subscription_status,
COUNT(customer_id) as total_customer,
ROUND(AVG(purchase_amount),2) as avg_spend,
ROUND(SUM(purchase_amount),2) as total_revenue
from customer
group by subscription_status
order by avg_spend, total_revenue desc;

-- which 5 products have highest percentage of purchases with discount applied.
select item_purchased,
ROUND(100 * SUM(CASE WHEN discount_applied ='Yes' THEN 1 ELSE 0 END)/COUNT(*),2 ) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5;

-- Segment customer into new, returning, and loyal based on their total number of previous purchase, ad show the count of each segment.
with customer_type as (
select customer_id, previous_purchases,
CASE
	WHEN previous_purchases = 1 THEN 'New'
	WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
	ELSE 'Loyal'
	END AS customer_segment
from customer
)
select customer_segment, count(*) as "Number of Customers"
from customer_type
group by customer_segment

-- what are the top 3 most purchased products with each category.
with item_count as (
select category,
item_purchased,
COUNT(customer_id) as total_orders,
ROW_NUMBER() over(partition by category order by count(customer_id)DESC) as item_rank
from customer
group by category, item_purchased
)
select item_rank, category, item_purchased, total_orders
from item_count
where item_rank <= 3;

-- Are custromers who are repeat buyers (more than 5 previous purchases) also likely to subscribe.
select subscription_status,
COUNT(customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status

-- what is revenue revenue contribution of each age group.
select age_group,
SUM(purchase_amount) as total_revenue
from customer
group by age_group
order by total_revenue desc;