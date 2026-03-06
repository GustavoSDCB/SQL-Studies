-- =====================================================================================================
-- Chapter 13: Indexes and Constraints
-- Based on "Learning SQL" by Alan Beaulieu
-- Topics: Indexes; Index Creation; Unique Indexes; Multicolumn Indexes; Types of Indexes; Constraints
-- =====================================================================================================
 
select
c.first_name, c.last_name
from customer c
where last_name like "Y%";

/*
This select is known as "table scan", which means that the SGDB will iterate within all the Customer table
contents in order to find rows which last name starts with Y. Taking into account bigger DB, this can be
impractical, since it would take a lot of time to iterate all the rows only for this search.
A better way to do the same, is by using an Index:
*/

-- Index Creation
alter table customer
add index idx_email(email);
/*This query created a B-tree index type*/

/*
It is the query optimizer's duty to decide to use an index if it is deemed beneficial. If a table has more
than one index, it is also the query optimizer's duty to choose, among them, which one is the most suitable
for that particular query.
*/

-- How to see all the available indexes of a table:
show index from customer;

-- Droping an Index:
alter table customer
drop index idx_email;

-- Creating an UNIQUE INDEX:
alter table customer
add unique index idx_email(email);

/*
Behind the hood this is the same as in:

create table Customer (
email varchar(30) UNIQUE
);

In MySQL, the DBMS already creates an Unique Index for this column with a standardized name to it. The main
difference is that, by using the command to create the index instead, you are able to define a meaningful 
name to it, which makes debugging and error messages clearer. You could also do the following instead of adding
the index afterwards using the alter table command:

create table Customer (
email varchar(30),
unique index idx_email(email)
);
*/

insert into customer(store_id, first_name, last_name, email, address_id, active)
values(1,'ALAN','KAHN', 'ALAN.KAHN@sakilacustomer.org', 394, 1);

/*
If you try to add a new customer with an email address that already exists when there is an Unique Index, the
following error will show up: 

insert into customer(store_id, first_name, last_name, email, address_id, active) 
values(1,'ALAN','KAHN', 'ALAN.KAHN@sakilacustomer.org', 394, 1)	
Error Code: 1062. Duplicate entry 'ALAN.KAHN@sakilacustomer.org' for key 'customer.idx_email'	0.031 sec
*/

-- Multicolumn Indexes
-- Cases when you are searching for first and last names
alter table customer
add index idx_full_name(last_name, first_name);

-- Explain statment
explain
select
c.customer_id, c.first_name, c.last_name
from customer c
where first_name like "S%" and last_name like "P%";

-- Exercises
/*
Exercise 13-1
Generate an alter table statement for the rental table so that an error will be raised if a row having a
value found in the rental.customer_id column is deleted from the customer table.
*/
alter table rental
add constraint fk_rental_customer_id foreign key (customer_id)
references customer(customer_id) on delete restrict;
/*This is the answer, though I'll not run this query*/

/*
Exercise 13-2
Generate a multicolumn index on the payment table that could be used by both of the following queries:


SELECT customer_id, payment_date, amount
FROM payment
WHERE payment_date > cast('2019-12-31 23:59:59' as datetime);

SELECT customer_id, payment_date, amount
FROM payment
​WHERE payment_date > cast('2019-12-31 23:59:59' as datetime)
  AND amount < 5;
*/
alter table payment
add index idx_rent(payment_date, amount);