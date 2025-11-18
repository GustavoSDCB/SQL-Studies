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
on c.address_id = a.address_idkkk
inner join city ci
on a.city_id = ci.city_id;