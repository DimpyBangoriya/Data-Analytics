/* Create database dominos */


create table Pizzas(
pizza_id varchar(100) primary key ,
pizza_type_id varchar(100),
size varchar(50),
price float
);

create table pizza_type(
pizza_type_id varchar(100) primary key,
name varchar(255),
category varchar(255),
ingredients text

);

create table order_details(
order_details_id int primary key,
order_id int,
pizza_id varchar(255),
quantity int
);


-- create ER Diagram First Then Do Refrential integrity (foreign key)

select * from dominos.pizzas;
/*
1 Retrieve the total number of orders placed.
2 Calculate the total revenue generated from pizza sales.
done 3 Identify the highest-priced pizza.
4 Identify the most common pizza size ordered.
done 5 List the top 5 most ordered pizza types along with their quantities.
6 Determine the distribution of orders by hour of the day.
7 calculate the average number of pizzas ordered per day.
done 8 Determine the top 3 most ordered pizza types based on revenue.
9 Calculate the percentage contribution of each pizza type to total revenue.
10 Analyze the cumulative revenue generated over time.
11 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
*/

-- 1 Retrieve the total number of orders placed.

select count(o1.order_id) as Total_Orders
from dominos.orders o1;

-- 2 Calculate the total revenue generated from pizza sales.

select sum(x.Revenue) as Total_Revenue from
(select (price*quantity) as Revenue
from dominos.order_details od1
left join dominos.pizzas p1
on od1.pizza_id = p1.pizza_id)x;


-- 3 Identify the highest-priced pizza.

select t1.name,p1.price
from dominos.pizzas p1
inner join dominos.pizza_type t1
on p1.pizza_type_id = t1.pizza_type_id
where p1.price=(select max(price) from dominos.pizzas);


-- 4 Identify the most common pizza size ordered.


select p1.size, sum(od1.quantity) as Total_Pizza_By_Size
from dominos.order_details od1
left join dominos.pizzas p1
on p1.pizza_id = od1.pizza_id
group by p1.size
order by Total_Pizza_By_Size desc
Limit 1;


-- 5 List the top 5 most ordered pizza types along with their quantities.


select p1.pizza_type_id,count(od1.quantity) as total_orders
from dominos.order_details od1
inner join dominos.pizzas p1
on od1.pizza_id = p1.pizza_id
group by p1.pizza_type_id
order by total_orders desc
limit 5;


-- 6 Determine the distribution of orders by hour of the day.

select hour(o1.order_time) as Hour_Of_The_Day,count(o1.order_id) as Total_Orders_By_Hour
from dominos.orders o1
group by hour(o1.order_time);




-- 7 calculate the average number of pizzas ordered per day.


select avg(x.Total_Quantity_Per_Day) as Average_Number_Of_Pizzas_Ordered_Per_Day
from(
select o1.Order_date,sum(od1.quantity) as Total_Quantity_Per_Day
from dominos.orders o1
inner join dominos.order_details od1
on od1.order_id = o1.order_id
group by o1.Order_date)x;



-- 8 Determine the top 3 most ordered pizza types based on revenue.

select p1.pizza_type_id,sum(p1.price*od1.quantity) as Revenue
from dominos.order_details od1
inner join dominos.pizzas p1
on od1.pizza_id = p1.pizza_id
group by p1.pizza_type_id
order by Revenue desc
Limit 3;

-- 9 Calculate the percentage contribution of each pizza type to total revenue.


select pizza_type.category,
Round(Sum(order_details.quantity * pizzas.price) / (SELECT Round(sum(order_details.quantity * pizzas.price),02) As total_sales
from
order_details
JOIN
Pizzas
Where
order_details.pizza_id = pizzas.pizza_id)*100,2) As revenue
From 
pizza_type
JOIN
pizzas on pizza_type.pizza_type_id = pizzas.pizza_type_id
join 
order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_type.category
order by revenue Desc;



-- 10 Analyze the cumulative revenue generated over time.


select y.Order_date, y.total_Revenue, sum(y.Total_Revenue) over(order by y.Order_date) as Cum_Revnue from
	(
	select x.Order_date, sum(x.revenue) as Total_Revenue
	from
			(
			select o1.Order_date, (p1.price*od1.quantity) as Revenue
			from dominos.pizzas p1
			left join dominos.order_details od1
			on p1.pizza_id = od1.pizza_id
			left join dominos.orders o1
			on o1.order_id = od1.order_id
			)x

		group by x.Order_date
	)y;

-- 11 Determine the top 3 most ordered pizza types based on revenue for each pizza category.


select pt1.pizza_type_id, sum(od1.quantity*p1.price) as Revenue
from dominos.order_details od1
left join dominos.pizzas p1
on od1.pizza_id = p1.pizza_id
left join dominos.pizza_type pt1
on pt1.pizza_type_id = p1.pizza_type_id
group by pt1.pizza_type_id
order by Revenue desc
Limit 3;
