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

-- Another example of correlated subquery
select 
c.first_name, c.last_name,
(
select datediff(now(), max(rental_date))
from rental r
where r.customer_id = c.customer_id
) days_since_last_rental
from customer c;

-- Handling Null Values
select
c.first_name, c.last_name,
case
	when a.address is null then 'Unknown'
    else a.address
end address,
case
	when ct.city is null then 'Unknown'
    else ct.city
end city,
case
	when cn.country is null then 'Unknown'
    else cn.country
end country
from customer c
left join address a
on c.address_id = a.address_id
left join city ct
on a.city_id = ct.city_id
left join country cn
on ct.country_id = cn.country_id;

-- Exercises
/*
Rewrite the following query, which uses a simple case expression, so that the same 
results are achieved using a searched case expression. Try to use as few when clauses 
as possible.

SELECT name,
  CASE name
    WHEN 'English' THEN 'latin1'
    WHEN 'Italian' THEN 'latin1'
    WHEN 'French' THEN 'latin1'
    WHEN 'German' THEN 'latin1'
    WHEN 'Japanese' THEN 'utf8'
    WHEN 'Mandarin' THEN 'utf8'
    ELSE 'Unknown'
  END character_set
FROM language;
*/
select name,
case
	when name in ('English', 'Italian', 'French', 'German') then 'latin1'
    when name in ('Japanese','Mandarin') then 'utf8'
    else 'Unknown'
end character_set
from language;

/*
Rewrite the following query so that the result set contains a single row with five 
columns (one for each rating). Name the five columns G, PG, PG_13, R, and NC_17.

SELECT rating, coun(*)
FROM film
GROUP BY rating;
*/
select distinct rating
from film
order by rating;

select
sum(case when rating = 'G' then 1 else 0 end) g,
sum(case when rating = 'PG' then 1 else 0 end) pg,
sum(case when rating = 'PG-13' then 1 else 0 end) pg_13,
sum(case when rating = 'R' then 1 else 0 end) r,
sum(case when rating = 'NC-17' then 1 else 0 end) nc_17
from film;