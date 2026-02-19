-- =============================================================
-- Chapter 9: Subqueries
-- Based on "Learning SQL" by Alan Beaulieu
-- Topics: Single-row, multi-row, correlated subqueries, EXISTS / NOT EXISTS
-- =============================================================

/* 
- Count the number of film rentals for each customer, and the containing query then retrieves those customers who have rented exactly 20 films.
*/
select c.first_name, c.last_name
from rental r
inner join customer c
on r.customer_id = c.customer_id
group by r.customer_id
having count(*) = 20;

-- Now using Correlated Subqueries (using equality conditions)
select c.first_name, c.last_name
from customer c 
where 20 = (select count(*) from rental r where r.customer_id = c.customer_id);

/*
Find all customers whose total payments for all film rentals are between $180 and $240.
*/
select c.first_name, c.last_name
from payment p
inner join customer c
on p.customer_id = c.customer_id
group by p.customer_id
having sum(p.amount) between 180 and 280;

-- Now using Correlated Subqueries (using range conditions)
select c.first_name, c.last_name
from customer c
where (select sum(p.amount) from payment p where p.customer_id = c.customer_id) between 180 and 240;

/*
Finds all the customers who rented at least one film prior to May 25, 2005, without regard for how many films were rented.
*/
select c.first_name, c.last_name
from customer c
inner join rental r
on c.customer_id = r.customer_id
where r.rental_date <= '2005-05-25';

-- Using Exists Operator
select c.first_name, c.last_name
from customer c
where exists (
select 1 from rental r where rental_date < '2005-05-25' and c.customer_id = r.customer_id
);

/*
Finds all actors who have never appeared in an R-rated film.
*/
select a.first_name, a.last_name
from actor a
where a.actor_id not in (
select fa.actor_id
from film_actor fa
inner join film f
on fa.film_id = f.film_id
where f.rating = 'R'
);

-- Using Not Exists
select a.first_name, a.last_name
from actor a
where not exists (
select 1
from film_actor fa
inner join film f
on fa.film_id = f.film_id
where fa.actor_id = a.actor_id and f.rating = 'R'
);

/*
Generating a list of customer IDs along with the number of film rentals and the total payments using subqueries.
*/
select c.first_name, c.last_name, p.num_rents, p.tot_payments
from customer c
inner join
(
select r.customer_id, count(*) as num_rents, sum(p.amount) as tot_payments
from rental r
inner join payment p
on r.rental_id = p.rental_id
group by r.customer_id
) as p
on c.customer_id = p.customer_id;

/*
Generate a report showing each customer’s name, along with their city, the total number of rentals, and the total payment amount.
*/
select c.first_name, c.last_name, ci.city, sum(p.amount) as tot_pymt, count(*) tot_rental
from customer c
inner join address a
on c.address_id = a.address_id
inner join city ci
on a.city_id = ci.city_id
inner join payment p
on c.customer_id = p.customer_id
group by c.first_name, c.last_name, ci.city;

-- Using Task-Oriented Subqueries
select c.first_name, c.last_name, ci.city, p.tot_pymnt, p.tot_rental
from customer c
inner join
(
select customer_id, sum(amount) as tot_pymnt, count(*) as tot_rental
from payment
group by customer_id
) as p
on c.customer_id = p.customer_id
inner join address a
on c.address_id = a.address_id
inner join city ci
on a.city_id = ci.city_id;

-- Common Table Expressions
with actors_s as (
select actor_id, first_name, last_name
from actor
where last_name like 'S%'
),
actors_s_pg as (
select s.actor_id, s.first_name, s.last_name, f.film_id, f.title
from actors_s s
inner join film_actor fa
on s.actor_id = fa.actor_id
inner join film f
on f.film_id = fa.film_id
where f.rating = 'PG'
),
actors_s_pg_revenue as (
select spg.first_name, spg.last_name, p.amount
from actors_s_pg spg
inner join inventory i
on spg.film_id = i.film_id
inner join rental r
on i.inventory_id = r.inventory_id
inner join payment p
on r.rental_id = p.rental_id
)
select spg_rev.first_name, spg_rev.last_name, sum(spg_rev.amount) as tot_revenue
from actors_s_pg_revenue spg_rev
group by 1, 2
order by 3 desc;

-- Subqueries as Expressions Generators (another way to do the same as in "Using Task-Oriented Subqueries")
select
(select c.first_name from customer c where c.customer_id = p.customer_id) first_name,
(select c.last_name from customer c where c.customer_id = p.customer_id) last_name,
(select ct.city
from customer c
inner join address a
on c.address_id = a.address_id
inner join city ct
on a.city_id = ct.city_id
where c.customer_id = p.customer_id
) city,
sum(p.amount) tot_payments, count(*) tot_rentals
from payment p
group by p.customer_id;

-- Each one of the above subqueries return only one row and one column. This concept is called Scalar Subqueries.



-- Retrieves an actor’s first and last names and sorts by the number of films in which the actor appeared:
select
a.first_name, a.last_name
from
actor a
order by
(select count(*) from film_actor fa where fa.actor_id = a.actor_id) desc;

-- Inserting a new row in the Film Actor table receiving only the first and last name and the name of the film. Using noncorrelated scalar subqueries:
insert into film_actor (actor_id, film_id, last_update)
values (
(select actor_id from actor where first_name = 'JENNIFER' and last_name = 'DAVIS'),
(select film_id from film where title = 'ACE GOLDFINGER'),
now()
);

/*
Exercises from Chapter 9
Exercise 9-1
Construct a query against the film table that uses a filter condition with a noncorrelated subquery against the category table to find all action films (category.name = 'Action').
*/
select
f.title
from film f
where film_id in
(
select
f.film_id
from
film_category fc
inner join category c
on fc.category_id = c.category_id
inner join film f
on fc.film_id = f.film_id
where c.name = 'Action'
);

/* Exercise 9-2
Rework the query from Exercise 9-1 using a correlated subquery against the category and film_category tables to achieve the same results.
*/
select 
f.title
from 
film f
where exists
(
select 
1
from 
film_category fc
inner join 
category c
on fc.category_id = c.category_id
where 
c.name = 'Action' and fc.film_id = f.film_id
);

/*
Join the following query to a subquery against the film_actor table to show the level of each actor:
	SELECT 'Hollywood Star' level, 30 min_roles, 99999 max_roles
	UNION ALL
	SELECT 'Prolific Actor' level, 20 min_roles, 29 max_roles
	UNION ALL
	SELECT 'Newcomer' level, 1 min_roles, 19 max_roles
The subquery against the film_actor table should count the number of rows for each actor using group by actor_id, and the count should be compared to the min_roles/max_roles columns to determine which level each actor belongs to.
*/

select 
act.actor_id, grp.level
from
(
select
actor_id, count(*) num_roles
from
film_actor
group by actor_id
) act
inner join
(
SELECT 'Hollywood Star' level, 30 min_roles, 99999 max_roles
UNION ALL
SELECT 'Prolific Actor' level, 20 min_roles, 29 max_roles
UNION ALL
SELECT 'Newcomer' level, 1 min_roles, 19 max_roles
) grp
on act.num_roles between grp.min_roles and grp.max_roles;
