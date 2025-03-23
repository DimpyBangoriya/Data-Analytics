Create Database bank;

create table bank.customers (
customer_id varchar(50) Primary Key,
first_name varchar(100),
last_name varchar(100),
email varchar(100),
phone_no varchar(100),
state varchar(100),
postal_code varchar(100),
age varchar(50),
gender varchar(50),
join_date varchar(50)
);

create table bank.credit_card (
credit_card_id int(100) Primary Key,
customer_id varchar(100),
card_type varchar(100),
card_limit varchar(100),
current_balance varchar(200),
last_payment_date varchar(100),
payment_due_date varchar(100),
payment_status varchar(100),
credit_utilization varchar(100),
credit_card_number varchar(100),
bank_name varchar(100),
FOREIGN KEY(customer_id) REFERENCES customers(customer_id)
);


create table bank.transaction_detail(
transaction_id int(100) Primary Key,
credit_card_id int(100),
transaction_date varchar(100),
transaction_time varchar(100),
transaction_amount varchar(100),
transaction_category varchar(100),
customer_location varchar(100),
merchant_name varchar(100),
merchant_location varchar(100),
transaction_mode varchar(100),
amount_paid varchar(100),
previous_transactions_count varchar(100),
merchant_category varchar(100),
status_detail varchar(100),
Foreign Key(credit_card_id) References credit_card(credit_card_id)
);

SET SQL_SAFE_UPDATES = 0;

UPDATE customers 
SET join_date = STR_TO_DATE(join_date, '%m-%d-%Y');


-- STEP 1 Cleaning Data

-- Checking for Missing Data:	

		--  Find transactions where credit_card_id is missing.
       
       select * 
         from bank.transaction_detail t1
         where t1.credit_card_id is Null;

		-- Identify credit cards that reference a non-existing customer.
       
		SELECT * 
		FROM credit_card cc
		LEFT JOIN customers c ON cc.customer_id = c.customer_id
		WHERE c.customer_id IS NULL;

--  Removing Invalid Data:
        
		--  Delete transactions with a missing or incorrect credit_card_id.
            
				select *  FROM transaction_detail 
WHERE credit_card_id IS NULL OR credit_card_id NOT IN (SELECT credit_card_id FROM credit_card);
            
            
		--  Remove credit cards linked to customers who don’t exist in the customer table.
            
            select * 
            from credit_card where customer_id Not in (select customer_id from customers);

			SELECT cc.* FROM credit_card cc
			LEFT JOIN customers c ON cc.customer_id = c.customer_id
			WHERE c.customer_id IS NULL;

-- STEP 2 ANALYZING TRANSACTION
				
	-- Total Number Of Transaction
    
    select count(*) from  
    transaction_detail;
    
    -- What is the total amount spent?
    
    SELECT SUM(transaction_amount) AS total_spent FROM transaction_detail;
    
    -- Avg Transaction Spent
    
    SELECT AVG(transaction_amount) AS avg_transaction FROM transaction_detail;
    
    --  How does spending change month by month?
    
    select *,MONTH(transaction_date) as Month_Of_Transaction
    from bank.transaction_detail t1;
    
    Select x.Month_Of_Transaction,sum(amount_paid) 
    from (select *,MONTH(transaction_date) as Month_Of_Transaction
    from bank.transaction_detail t1)x
    group by Month_Of_Transaction;
    
    -- Top 5 customers by total spending

	select c1.customer_id,sum(t1.amount_paid) as Total_Spending
    from  bank.customers c1
    Left Join bank.credit_card cc1
    on c1.customer_id=cc1.customer_id
    Left Join bank.transaction_detail t1
    on cc1.credit_card_id=t1.credit_card_id
    group by c1.customer_id
    order by Total_Spending Desc
    Limit 5;
    
    -- STEP 3 : BUSINESS INSIGHTS
    
    -- Most frequently used credit cards by bank
    
    select cc1.bank_name,count(t1.transaction_id) as Transaction_Count
    from bank.transaction_detail t1
    Left Join bank.credit_card cc1
    on t1.credit_card_id=cc1.credit_card_id
    group by cc1.bank_name
    order by Transaction_Count Desc;
    
    
    
    -- Customers with highest average transaction value


select c1.customer_id,avg(t1.transaction_amount) as Average_Transaction_Amount
from bank.customers c1
Left Join bank.credit_card cc1
on c1.customer_id=cc1.customer_id
Left Join bank.transaction_detail t1
on cc1.credit_card_id=t1.credit_card_id
group by c1.customer_id
Order by Average_Transaction_Amount Desc;
    
    -- Top 5 banks by total transaction value

    select cc1.bank_name,sum(t1.transaction_amount) as Total_Transaction_Value
    from bank.transaction_detail t1
    Left Join bank.credit_card cc1
    on t1.credit_card_id=cc1.credit_card_id
    group by cc1.bank_name
    order by Total_Transaction_Value Desc
    Limit 5;
    
    

    