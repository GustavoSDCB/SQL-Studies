-- =====================================================================================================
-- Chapter 12: Transactions
-- Based on "Learning SQL" by Alan Beaulieu
-- Topics: Multiuser Databases; Locking; Lock Granularities; What is a Transaction;
-- Starting a Transaction; Ending a Transaction; Transaction Savepoints.
-- =====================================================================================================

/* This chapter was all about theory and concepts of Transactions, therefore, no queries were created in this 
context */

-- Exercises
/*
Generate a unit of work to transfer $50 from account 123 to account 789. You will need to insert two rows into 
the transaction table and update two rows in the account table. Use the following table definitions/data:

			Account:
account_id	avail_balance	last_activity_date
----------	-------------	------------------
123				500			2019-07-10 20:53:27
789				75			2019-06-22 15:18:35

						Transaction:
txn_id		txn_date	account_id	  txn_type_cd		amount
---------	---------	-----------	  -----------		--------
1001		2019-05-15		123			   C			  500
1002		2019-06-01		789			   C			  75
*/
START TRANSACTION;

-- Debit to 123 account and input of a new transaction
update account
set avail_balance = avail_balance - 50,
 last_activity_date = current_timestamp()
where account_id = 123;

insert into transaction(txn_date, account_id, txn_type_cd, amount)
values(current_date(), 123, 'D', 50);

-- Credit to 789 and input of a new transaction
update account
set avail_balance = avail_balance + 50,
 last_activity_date = current_timestamp()
where account_id = 789;

insert into transaction(txn_date, account_id, txn_type_cd, amount)
values(current_date(), 789, 'C', 50);

COMMIT;