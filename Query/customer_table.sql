-- Grab the user and their associated order information
with transaction_info as (
    select customer_id, 
           cast(date_parse(transaction_date,'%m/%d/%y') as timestamp) as transaction_date,
           transaction_id, 
           unit_price
    from transactions
    where transaction_date <> 'transaction_date' -- If headers were loaded in as data, they need to be removed.
)
-- Grab information from the users table
, customer_info as (
    select customer_id as customer_id, 
           -- grab each user's sign up date
           case when sign_up_date='' then NULL else cast(date_parse(sign_up_date,'%m/%d/%y') as timestamp) end as signup
    from customers
    where sign_up_date not in ('sign_up_date')
)
-- Aggregate the information from the orders table
, aggregate_transactions as (
    select count(transaction_id) as num_prod_purchased, 
           sum(unit_price) as ltv, 
           -- grab each customers first and last purchase on file
           max(transaction_date) as last_purchase_date, 
           min(transaction_date) as first_purchase_date,
           customer_id
    from transaction_info 
    group by customer_id
)
-- Combine the information from the users table and the orders table and compute features (More details explaining the features are described in the Jupyter Notebook).
, combine_info as (
    select c.customer_id, 
           num_prod_purchased,  -- Number of products purchased
           ltv,  -- Lifetime Value
           date_diff('day', last_purchase_date, cast('2019-08-31' as timestamp)) as days_since_last_purchase, -- Days since last product was purchased (Assuming that today's date is August 15, 2018)
           first_purchase_date, -- First purchase in a customer's lifetime
           date_diff('week', signup, cast('2019-08-31' as timestamp)) as tenure, -- Assuming that the date is August 15, 2018,
           -- Binary variables showing 1) how long ago the customer's last purchase date was and 2) how many purchases they made.
           case when date_diff('day',last_purchase_date,cast('2019-08-31' as timestamp)) > 180 and num_prod_purchased=1 then 1 else 0 end as single_more6,
           case when date_diff('day',last_purchase_date,cast('2019-08-31' as timestamp)) < 180 and num_prod_purchased=1 then 1 else 0 end as single_less6,
           case when date_diff('day',last_purchase_date,cast('2019-08-31' as timestamp)) < 180 and num_prod_purchased>1 then 1 else 0 end as multi_buyer_less6,
           case when date_diff('day',last_purchase_date,cast('2019-08-31' as timestamp)) > 180 and num_prod_purchased>1 then 1 else 0 end as multi_buyer_more6
    from customer_info c
    left join aggregate_transactions t on c.customer_id = t.customer_id
)
-- Finalize the output of the customer table
  select c.customer_id,
         coalesce(num_prod_purchased,0) as num_prod_purchased, -- If no products were purchased, mark the customer with a 0.
         coalesce(ltv,0) as ltv,
         coalesce(days_since_last_purchase,-1) as days_since_last_purchase, 
         -- If the customer doesn't have a tenure, use first purchase date. If first purchase date doesn't exist, then mark the customer with a -1.
         case when tenure is null and first_purchase_date is null then -1
              when tenure is null and first_purchase_date is not null then date_diff('week',first_purchase_date, cast('2019-08-31' as timestamp))
              else tenure end as tenure,  
         single_more6,
         single_less6,
         multi_buyer_less6,
         multi_buyer_more6
  from combine_info c
  group by 1,2,3,4,5,6,7,8,9 -- Remove duplicate values