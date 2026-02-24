-- =====================================================================================================
-- Chapter 10: Joins Revisited
-- Based on "Learning SQL" by Alan Beaulieu
-- Topics: Outer Joins, Left vs Right Outer Joins, Three-Way Outer Joins, Cross Joins, Natural Joins
-- =====================================================================================================

-- Outer Join
select 
f.film_id, f.title, count(*) as num_copies
from 
film f
inner join inventory i
on f.film_id = i.film_id
group by f.film_id; -- Excpected 1000 rows, got 958 instead

-- To generate the expected result, we use an outer join instead:
-- Left Join
select 
f.film_id, f.title, count(i.inventory_id) as num_copies
from 
film f
left OUTER join inventory i
on f.film_id = i.film_id
group by f.film_id;

/*
Quick Reminder!
The OUTER part in the join is not necessary, most (or all) SGDB's already recognise the 
LEFT JOIN as an outer join, since that is exactly what it is. The same rule aplies to 
right and full joins too.
 */
 
-- Right Join
select 
f.film_id, f.title, count(i.inventory_id) as num_films
from
inventory i
right outer join film f
on
i.film_id = f.film_id
group by f.film_id;

/*
Left and Right Joins consist in the same principle, the name of the Join will decide
which table will be the responsible for determining the number of rows in the result
set. If it is Left, than the table declared in the FROM statment will be the "main" table
whereas the Right will turn the table declared in the Join statment the "main" table.
*/

-- Three-Way Outer Joins
select 
f.film_id, f.title, i.inventory_id, r.rental_date
from film f
left join inventory i
on f.film_id = i.film_id
left join rental r
on i.inventory_id = r.inventory_id
where f.film_id between 13 and 15;

-- Cross Joins
select c.name category_name, l.name language_name
from category c
cross join language l;

/*
Cross Joins are not used commonly, usually they are used by mistake (like when only
specifying JOIN in the Join statment), but if you'd like to have a Cartesian Product of 
two tables, that's how you should get to this result.
*/

-- Natural Joins
select
cu.first_name, cu.last_name, r.rental_date
from 
(
select c.customer_id, c.first_name, c.last_name
from customer c
) cu
natural join rental r;

/*
In this case we used a subquery to select only the id, first name and last name of the
Customer table because of the last_update column that both tables have. If we didn't
do it, the natural join will try to join the rows using both customer_id and last_update
columns, which would generate an empty set, since the last_update time will be different
in both tables according to the time each row was added in them.

This occurs because the Natural Join looks into these two tables and searches for columns
they share in common (usually FK) to join them.
*/

-- Exercises
/*
Exercise - 1
Using the following table definitions and data, write a query that returns each customer
name along with their total payments:

		Customer:
Customer_id  	Name
-----------  	---------------
1		John Smith
2		Kathy Jones
3		Greg Oliver

		Payment:
Payment_id	Customer_id	Amount
----------	-----------	--------
101		1		8.99
102		3		4.99
103		1		7.99

Include all customers, even if no payment records exist for that customer.
*/
select 
c.first_name, c.last_name, sum(p.amount) total_payment
from customer c
left join payment p
on c.customer_id = p.customer_id
group by c.customer_id;

/*
Exercise - 2
Reformulate your query from Exercise 10-1 to use the other outer join type
(e.g., if you used a left outer join in Exercise 10-1, use a right outer join this
time) such that the results are identical to Exercise 10-1.
*/
select 
c.first_name, c.last_name, sum(p.amount) total_payment
from payment p
right join customer c
on c.customer_id = p.customer_id
group by c.customer_id;

/*
* I did the exercises using the already existing tables because I don't see any reason
why would I create two new tables (or CTE's) just to achieve the same results with
the tables I already have inside Sakila's Database.
*/