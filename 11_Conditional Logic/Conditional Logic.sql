-- =====================================================================================================
-- Chapter 11: Conditional Logic
-- Based on "Learning SQL" by Alan Beaulieu
-- Topics: Searched case Expressions; Simple case Expressions.
-- =====================================================================================================

-- Examples of Searched Case Expression
select
c.first_name, c.last_name, 
case
	when c.active = 1 
		then 'ACTIVE'
	else 'INACTIVE' -- The else clause is optional!
end activity_type
from customer c;


select 
c.name,
case
	when c.name in ('Children','Family','Sports','Animation')
		then 'All ages'
	when c.name = 'Horror'
		then 'Adult'
	when c.name in ('Music', 'Games')
		then 'Teens'
	else 'Others'
end category
from category c;

select
c.first_name, c.last_name, 
case
	when c.active = 0 then 0
	else (
		select 
		count(*)
		from rental r
		where r.customer_id = c.customer_id
    ) -- Correlated Subquery
end num_rentals
from customer c;

-- Simple Case Expressions
select category.name,
case category.name
	when 'Children' then 'All Ages'
	when 'Family' then 'All Ages'
	when 'Sports' then 'All Ages'
	when 'Animation' then 'All Ages'
	when 'Horror' then 'Adult'
	when 'Music' then 'Teens'
	when 'Games' then 'Teens'
	else 'Other'
end type_category
from category;

-- This Case is less flexible than the Searched Case Expression as we can notice


-- More Case Examples
/*
You have been asked to write a query that shows the number of film rentals for May,
June, and July of 2005:
*/

select
monthname(rental_date) rental_month, count(*) num_rentals
from rental
where rental_date between '2005-05-01' and '2005-08-01'
group by 1;

/*
However, you have also been instructed to return a single row of data with three 
columns (one for each of the three months).
*/
select
sum(case when monthname(rental_date) = 'May' then 1 else 0 end) may_rentals,
sum(case when monthname(rental_date) = 'June' then 1 else 0 end) june_rentals,
sum(case when monthname(rental_date) = 'July' then 1 else 0 end) july_rentals
from rental
where rental_date between '2005-05-01' and '2005-08-01';


-- Checking for Existence
/*
Wright a query that uses multiple case expressions to generate three output columns,
one to show whether the actor has appeared in G-rated films, another for PG-rated films, 
and a third for NC-17-rated films
*/
select a.first_name, a.last_name,
case
	when exists (select 1 from film_actor fa 
				inner join film f on fa.film_id = f.film_id 
                where fa.actor_id = a.actor_id and f.rating = 'G')
		then 'Y'
	else 'N'
end g_actor,
case
	when exists(select 1 from film_actor fa
				inner join film f on fa.film_id = f.film_id
				where fa.actor_id = a.actor_id and f.rating = 'PG')
		then 'Y'
	else 'N'
end pg_actor,
case
	when exists(select 1 from film_actor fa
				inner join film f on fa.film_id = f.film_id
				where fa.actor_id = a.actor_id and f.rating = 'NC-17')
		then 'Y'
	else 'N'
end nc17_actor
from actor a;

/*
Use a Simple Case Expression to count the number of copies in inventory
for each film and then returns either 'Out Of Stock', 'Scarce', 'Available',
or 'Common':
*/

select
f.title,
case (select count(*) from inventory i where i.film_id = f.film_id) -- *
	when 0 then 'Out of Stock'
    when 1 then 'Scarce'
    when 2 then 'Scarce'
    when 3 then 'Available'
    when 4 then 'Available'
    else 'Common'
end film_availability
from film f;

/*
* Quick remind for myself. If I want to make an "Inner Join" while using a 
correlated subquery, I can use the WHEN clause to interact with the query outside
of the subquery scope, this way I can make the Join correctly just like if it
was a normal inner join.
*/