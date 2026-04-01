-- =====================================================================================================
-- Chapter 16: Analytic Functions
-- Based on "Learning SQL" by Alan Beaulieu
-- Topics: Analytic Function Concepts; Ranking; Reporting Functions.
-- =====================================================================================================

-- Data Windows
select 
quarter(payment_date) quarter, monthname(payment_date) month_nm, sum(amount) month_sales
from payment
where year(payment_date) = 2005
group by 1, 2;

-- Using Over() to determine the highest values between a quarter and the whole data
select 
quarter(payment_date) quarter, monthname(payment_date) month_nm, sum(amount) tot_month,
max(sum(amount)) over () max_overall_sales, 
max(sum(amount)) over (partition by quarter(payment_date)) max_qrtr_sales
from payment
where year(payment_date) = 2005
group by 1, 2;

/*
In the previous query, both analytic functions include an over clause, but the first one
is empty, indicating that the window should include the entire result set, whereas the
second one specifies that the window should include only rows within the same quarter.
*/

-- Another example to ilustrate how the partition by works
select
c.customer_id id, lower(c.first_name) first_name, p.amount,
sum(p.amount) over (partition by c.customer_id) tot_payment
from payment p
inner join customer c
on p.customer_id = c.customer_id;

-- Localized Sorting
select
quarter(payment_date) quarter, monthname(payment_date) month_nm, sum(amount) tot_month,
rank() over (order by sum(amount) desc) sales_rank
from payment
where year(payment_date) = 2005
group by 1, 2
order by 1, 2 desc;

-- Ranking Functions and its differences (row_number, rank, dense_rank)
-- Base query:
select
customer_id, count(*) num_rentals
from rental
group by 1
order by 2 desc;

-- row_number | rank | dense_rank
select
customer_id, count(*) num_rentals,
row_number() over(order by count(*) desc) row_number_rnk,
rank() over (order by count(*) desc) rank_rnk,
dense_rank() over (order by count(*) desc) dense_rank_rnk
from rental
group by 1;

-- Ranking based on monthly rentals
select
customer_id, monthname(rental_date) month_nm, count(*) num_rentals,
rank() over (partition by monthname(rental_date) order by count(*) desc) rank_rnk
from rental
group by 1, 2
order by 2, 3 desc;

-- The same as the previous query but wraped in the FROM clause and only showing the first 5 places.
select customer_id, month_nm, num_rentals, rank_rnk
from 
(
select
customer_id, monthname(rental_date) month_nm, count(*) num_rentals,
rank() over (partition by monthname(rental_date) order by count(*) desc) rank_rnk
from rental
group by 1, 2
order by 2, 3 desc
) tabela
where rank_rnk <= 5;