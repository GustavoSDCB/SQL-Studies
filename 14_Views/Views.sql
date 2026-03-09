-- =====================================================================================================
-- Chapter 14: Views
-- Based on "Learning SQL" by Alan Beaulieu
-- Topics: Views; Updatable Views;
-- =====================================================================================================

-- View Definition
create view customer_vw
(
	customer_id,
    first_name,
    last_name,
    email
)
as
select
customer_id, first_name, last_name, 
concat(substr(email, 1, 2), '*****', substr(email, -4)) email
from customer;

/*
You can also do it by eliminating the first part of the view creation, since SQL will infer the names
of the columns based on what you put in the SELECT Statment, for example:

create view customer_vw
as
select
customer_id, first_name, last_name
concat(substr(email, 1, 2), '*****', substr(email, -4)) email
from customer

SQL would then, apply the columns names as:
customer_id | first_name | last_name | email

REMEMBER that the last column took the alias name, thus, if you don't give it an alias, it'll aplly as
the column name, the whole expression, which would not be good visually.
*/

-- To access the view you just need to do a simple SELECT Statment:
select * from customer_vw;

-- If we want to know that columns are available in a view, we can use the DESCRIBE Statment:
describe customer_vw;

/*
Example:
Let’s say that an application generates a report each month showing the total sales for each film category
so that the managers can decide what new films to add to inventory:
*/

create view sales_by_film_category
as
select
c.name category,
sum(p.amount) total_sales
from payment p
inner join rental r on p.rental_id = r.rental_id
inner join inventory i on r.inventory_id = i.inventory_id
inner join film f on i.film_id = f.film_id
inner join film_category fc on f.film_id = fc.film_id
inner join category c on fc.category_id = c.category_id
group by c.name
order by 2 desc;

/*
Example:
Joins the customer, address, city, and country tables so that all the data for customers can be easily
queried
*/

create view customer_details
as
select
c.customer_id, c.store_id, c.first_name, c.last_name, c.address_id, c.active, a.address, ct.city, cn.country, a.postal_code
from customer c
inner join address a on c.address_id = a.address_id
inner join city ct on a.city_id = ct.city_id
inner join country cn on ct.country_id = cn.country_id;

/*
Exercise 14-1

Create a view definition that can be used by the following query to generate the given results:

SELECT title, category_name, first_name, last_name
FROM film_ctgry_actor
WHERE last_name = 'FAWCETT'; 
*/
create view film_ctgry_actor
as
select
f.title, c.name category_name, a.first_name, a.last_name
from actor a
inner join film_actor fa on a.actor_id = fa.actor_id
inner join film f on fa.film_id = f.film_id
inner join film_category fc on f.film_id = fc.film_id
inner join category c on fc.category_id = c.category_id
where a.last_name = 'FAWCETT'
order by f.title;

/*
Exercise 14-2
The film rental company manager would like to have a report that includes the name of every country,
along with the total payments for all customers who live in each country. Generate a view definition 
that queries the country table and uses a scalar subquery to calculate a value for a column named tot_payments.
*/

create view customer_country
as
select
cn.country,
(
	select sum(
) as tot_payments
from country cn;