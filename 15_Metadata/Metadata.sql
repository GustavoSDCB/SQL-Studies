-- =====================================================================================================
-- Chapter 15: Metadata
-- Based on "Learning SQL" by Alan Beaulieu
-- Topics: Data About Data; Working with Metadata; Deployment Verification; Dynamyc SQL Generation.
-- =====================================================================================================

-- Query to retrieve all tables and views from the database
select table_name, table_type
from information_schema.tables
where table_schema = 'sakila' and table_type = 'BASE TABLE'
order by 1;

-- Query to retrieve additional information (flags in this case)
select table_name, is_updatable
from information_schema.views
where table_schema = 'sakila'
order by 1;

-- Query to retrieve information about the columns from tables and views
select
column_name, data_type, character_maximum_length char_max_len, 
numeric_precision num_prcsn, numeric_scale num_scale
from information_schema.columns
where table_schema = 'sakila' and table_name = 'film'
order by ordinal_position;

/* 
The ordinal_position column is included merely as a means to retrieve the columns in the order in 
which they were added to the table.
*/

-- Query to retrieve information about the indexes
select
index_name, non_unique, seq_in_index, column_name
from information_schema.statistics
where table_schema = 'sakila' and table_name = 'rental'
order by 1, 3;

-- Query to retrieve different types of constraints
select
constraint_name, table_name, constraint_type
from information_schema.table_constraints
where table_schema = 'sakila'
order by 3, 1;


-- Dynamic SQL Generation
-- How to query using strings (simplified explanation):
-- Assingn a string to a variable called @qry
set @qry = 'select customer_id, first_name, last_name from customer';

-- Submit it to the database engine (parsing, security checking, and optimization)
prepare dynsql1 from @qry;

-- Executing the Dynamic SQL (cool name to say that the SQL is running by a str)
execute dynsql1;

-- After executing the statement, it must be closed using:
deallocate prepare dynsql1;

-- How to generate queries that include placeholders so that conditions can be specified at runtime:
set @qry = 'select customer_id, first_name, last_name
			from customer
			where customer_id = ?;';

prepare dynsql2 from @qry;

-- Main difference from the statments built before:
set @custid = 9;
execute dynsql2 using @custid;

set @custid = 145;
execute dynsql2 using @custid;

deallocate prepare dynsql2;

-- Exercises
/*
Exercise 15-1
Write a query that lists all of the indexes in the Sakila schema. Include the table names.
*/
select
table_name, index_name
from information_schema.statistics
where table_schema = 'sakila';