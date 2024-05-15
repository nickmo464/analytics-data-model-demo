-- Populate the dimensional models.  First populate the dims, then the facts.
--  This follows a classical approach to populating a star schema, where the 
--  dims and facts cannot be populated in parallel because the fact SQL relies on data
--  in the dim tables.

----------------------------
-- Dim Tables
----------------------------
truncate table analytics.dim_date;

with dg as (
select rn + '2015-01-01'::date as dte
  from GENERATE_SERIES(0, 6208) rn
)
insert into analytics.dim_date
select dte::date as calendar_date
     , date_part('year', dte) as year_num
     , date_part('month', dte) as month_num
     , date_part('day', dte) as day_num
     , date_part('quarter', dte) as quarter_num
     , to_char(dte,'Day') AS day_of_week_name
     , to_char(dte, 'Month') AS month_name
     , case when date_trunc('YEAR',dte) + interval '1 year - 1 day' = dte then true else false end as end_of_year_flg  -- flags when at the last day of the period
     , case when date_trunc('QUARTER',dte) + interval '3 month - 1 day' = dte then true else false end as end_of_quarter_flg  -- flags when at the last day of the period
     , case when date_trunc('MONTH',dte) + interval '1 month - 1 day' = dte then true else false end as end_of_month_flg  -- flags when at the last day of the period
     , case when date_trunc('WEEK',dte) + interval '1 week - 2 day' = dte then true else false end as end_of_week_flg  -- flags when at the last day of the period
  from dg;
  


truncate table analytics.dim_category;

insert into analytics.dim_category
select category_id
     , category_name
     , category_description
     , update_ts as src_update_ts
     , now() as dw_update_ts
  from transaction_concept.category
 union all
select -1 as category_id
     , 'Unknown' as category_name
     , 'Unknown' as category_description
     , '2099-12-31' as src_update_ts
     , now() as dw_update_ts;
     


truncate table analytics.dim_customer;

insert into analytics.dim_customer
select customer_id
     , cust_name
     , cust_address
     , cust_phone
     , cust_email
     , update_ts as src_update_ts
     , now() as dw_update_ts
  from transaction_concept.customer
 union all
select -1 as customer_id
     , 'Unknown' as cust_name
     , 'Unknown' as cust_address
     , '000-000-0000' as cust_phone
     , 'Unknown' as cust_email
     , '2099-12-31' as src_update_ts
     , now() as dw_update_ts;
     

truncate table analytics.dim_driver;

insert into analytics.dim_driver
select driver_id
     , driver_name
     , driver_license_number
     , driver_phone
     , driver_address
     , update_ts as src_update_ts
     , now() as dw_update_ts
  from transaction_concept.driver
 union all
select -1 as driver_id
     , 'Unknown' as driver_name
     , '000-000-0000' as driver_license_number
     , '000-000-0000' as driver_phone
     , 'Unknown' as driver_address
     , '2099-12-31' as src_update_ts
     , now() as dw_update_ts;


truncate table analytics.dim_location;

insert into analytics.dim_location
select delivery_location_id
     , delivery_address
     , delivery_city
     , delivery_state
     , delivery_region
     , delivery_lat
     , delivery_long
     , update_ts as src_update_ts
     , now() as dw_update_ts
  from transaction_concept.delivery_location
 union all
select -1 as delivery_location_id
     , 'Unknown' as delivery_address
     , 'Unknown' as delivery_city
     , 'Unknown' as delivery_state
     , -1 as delivery_region
     , 0 as delivery_lat
     , 0 as delivery_long
     , '2099-12-31' as src_update_ts
     , now() as dw_update_ts;

truncate table analytics.dim_restaurant;

insert into analytics.dim_restaurant
select restaurant_id
     , restaurant_name
     , restaurant_address
     , restaurant_lat
     , restaurant_long
     , update_ts as src_update_ts
     , now() as dw_update_ts
  from transaction_concept.restaurant
 union all
select -1 as restaurant_id
     , 'Unknown' as restaurant_name
     , 'Unknown' as restaurant_address
     , 0 as restaurant_lat
     , 0 as restaurant_long
     , '2099-12-31' as src_update_ts
     , now() as dw_update_ts;



-- initially, show how to populate menu_item_scd1 from the original source data
truncate table analytics.dim_menu_item_scd1;

insert into analytics.dim_menu_item_scd1
select menu_item_id
     , menu_item_name
     , menu_item_description
     , menu_item_price
     , src_update_ts
     , dw_update_ts
  from (
        select row_number() over (partition by menu_item_id order by update_ts desc rows between unbounded preceding and unbounded following) as rownum
             , menu_item_id
             , menu_item_name
             , menu_item_description
             , menu_item_price
             , update_ts as src_update_ts
             , now() as dw_update_ts
          from transaction_concept.menu_item
       ) r
 where r.rownum = 1
 union all
select -1 as menu_item_id
     , 'Unknown' as menu_item_name
     , 'Unknown' as menu_item_description
     , 0 as menu_item_price
     , '2099-12-31' as src_update_ts
     , now() as dw_update_ts;
     

-- initially, show how to populate menu_item_scd2 from the original source data
truncate table analytics.dim_menu_item_scd2;

insert into analytics.dim_menu_item_scd2
select menu_item_id
     , menu_item_name
     , menu_item_description
     , menu_item_price
     , update_ts as src_update_ts
     , now() as dw_update_ts
     , update_ts as effective_start_ts
     , coalesce(lead(update_ts) over (partition by menu_item_id order by update_ts rows between unbounded preceding and unbounded following),'2099-12-31') as effective_end_ts
  from transaction_concept.menu_item
 union all
select -1 as menu_item_id
     , 'Unknown' as menu_item_name
     , 'Unknown' as menu_item_description
     , 0 as menu_item_price
     , '2099-12-31' as src_update_ts
     , now() as dw_update_ts
     , '1960-01-01' as effective_start_ts
     , '2099-12-31' as effective_end_ts;
  

-- Later, simulate new menu item data being added.  The row_number function
--   allows us to capture just the latest version of each record for a type I SCD.
truncate table analytics.dim_menu_item_scd1;

insert into analytics.dim_menu_item_scd1
select menu_item_id
     , menu_item_name
     , menu_item_description
     , menu_item_price
     , src_update_ts
     , dw_update_ts
  from (
        select row_number() over (partition by menu_item_id order by update_ts desc rows between unbounded preceding and unbounded following) as rownum
             , menu_item_id
             , menu_item_name
             , menu_item_description
             , menu_item_price
             , update_ts as src_update_ts
             , now() as dw_update_ts
          from transaction_concept.menu_item_newstuff
       ) r
 where r.rownum = 1
 union all
select -1 as menu_item_id
     , 'Unknown' as menu_item_name
     , 'Unknown' as menu_item_description
     , 0 as menu_item_price
     , '2099-12-31' as src_update_ts
     , now() as dw_update_ts;
     

-- Later, simulate new menu item data being added.  effective_start_ts
--   allows us to capture all the versions of each record for a type II SCD.
truncate table analytics.dim_menu_item_scd2;

insert into analytics.dim_menu_item_scd2
select menu_item_id
     , menu_item_name
     , menu_item_description
     , menu_item_price
     , update_ts as src_update_ts
     , now() as dw_update_ts
     , update_ts as effective_start_ts
     , coalesce(lead(update_ts) over (partition by menu_item_id order by update_ts rows between unbounded preceding and unbounded following),'2099-12-31') as effective_end_ts
  from transaction_concept.menu_item_newstuff
 union all
select -1 as menu_item_id
     , 'Unknown' as menu_item_name
     , 'Unknown' as menu_item_description
     , 0 as menu_item_price
     , '2099-12-31' as src_update_ts
     , now() as dw_update_ts
     , '1960-01-01' as effective_start_ts
     , '2099-12-31' as effective_end_ts;
  



----------------------------
-- Fact Tables
----------------------------

insert into analytics.fact_category_delivery
select row_number() over () as food_delivery_key
     , coalesce(cat.category_key,-1) as category_key
     , coalesce(cust.customer_key,-1) as customer_key
     , coalesce(drv.driver_key,-1) as driver_key
     , coalesce(loc.location_key,-1) as location_key
     , o.update_ts as order_date
     , date(del.requested_time) as delivery_request_date
     , date(del.delivery_time) as delivery_date
     , now() as dw_update_ts
     , o.item_price * o.quantity as food_amount
     , del.tax as tax_amount
     , del.tip as tip_amount
     , del.delivery_fee as delivery_fee_amount
  from transaction_concept.order o
  join transaction_concept.delivery del
    on o.delivery_id = del.delivery_id
  left join transaction_concept.menu_item mi
    on o.menu_item_id = mi.menu_item_id
  left join transaction_concept.restaurant res
    on mi.restaurant_id = res.restaurant_id
  left join analytics.dim_category cat
    on res.category_id = cat.category_key
  left join transaction_concept.customer_order co
    on o.order_id = co.order_id
  left join analytics.dim_customer cust
    on co.customer_id = cust.customer_key
  left join analytics.dim_driver drv
    on del.driver_id = drv.driver_key
  left join analytics.dim_location loc
    on del.delivery_location_id = loc.location_key
  





insert into analytics.fact_menu_item_delivery_scd
select row_number() over () as food_delivery_key
     , coalesce(cat.category_key,-1) as category_key
     , coalesce(cust.customer_key,-1) as customer_key
     , coalesce(drv.driver_key,-1) as driver_key
     , coalesce(loc.location_key,-1) as location_key
     , coalesce(dres.restaurant_key,-1) as restaurant_key
     , coalesce(dmi.menu_item_key,-1) as menu_item_key
     , o.update_ts as order_date
     , date(del.requested_time) as delivery_request_date
     , date(del.delivery_time) as delivery_date
     , o.item_price * o.quantity as food_amount
     , now() as dw_update_ts
  from transaction_concept.order o
  join transaction_concept.delivery del
    on o.delivery_id = del.delivery_id
  left join transaction_concept.menu_item mi
    on o.menu_item_id = mi.menu_item_id
  left join analytics.dim_menu_item dmi
    on mi.menu_item_id = dmi.menu_item_key
  left join transaction_concept.restaurant res
    on mi.restaurant_id = res.restaurant_id
  left join analytics.dim_restaurant dres
    on res.restaurant_id = dres.restaurant_key
  left join analytics.dim_category cat
    on res.category_id = cat.category_key
  left join transaction_concept.customer_order co
    on o.order_id = co.order_id
  left join analytics.dim_customer cust
    on co.customer_id = cust.customer_key
  left join analytics.dim_driver drv
    on del.driver_id = drv.driver_key
  left join analytics.dim_location loc
    on del.delivery_location_id = loc.location_key
  


