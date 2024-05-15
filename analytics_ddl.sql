CREATE SCHEMA IF NOT EXISTS analytics;

CREATE SCHEMA IF NOT EXISTS transaction_concept;

CREATE  TABLE analytics.dim_category ( 
	category_key         integer  NOT NULL  ,
	category_name        varchar(100)    ,
	category_description varchar(1000)    ,
	src_update_ts        timestamp  NOT NULL  ,
	dw_update_ts         timestamp  NOT NULL  ,
	CONSTRAINT pk_dim_category PRIMARY KEY ( category_key )
 );

CREATE  TABLE analytics.dim_customer ( 
	customer_key         integer  NOT NULL  ,
	cust_name            varchar(100)    ,
	cust_address         varchar(100)    ,
	cust_phone           varchar    ,
	cust_email           varchar    ,
	src_update_ts        timestamp  NOT NULL  ,
	dw_update_ts         timestamp  NOT NULL  ,
	CONSTRAINT pk_dim_customer PRIMARY KEY ( customer_key )
 );

CREATE  TABLE analytics.dim_date ( 
	calendar_date        date  NOT NULL  ,
	year_num             integer    ,
	month_num            integer    ,
	day_num              integer    ,
	quarter_num          integer    ,
	day_of_week_name     varchar    ,
	month_name           varchar(100)    ,
	end_of_year_flg      boolean    ,
	end_of_quarter_flg   boolean    ,
	end_of_month_flg     boolean    ,
	end_of_week_flg      boolean    ,
	CONSTRAINT pk_dim_date PRIMARY KEY ( calendar_date )
 );

CREATE  TABLE analytics.dim_driver ( 
	driver_key           integer  NOT NULL  ,
	driver_name          varchar(100)    ,
	driver_license_number varchar(20)    ,
	driver_phone         varchar    ,
	driver_address       varchar(100)    ,
	src_update_ts        timestamp  NOT NULL  ,
	dw_update_ts         timestamp  NOT NULL  ,
	CONSTRAINT pk_dim_driver PRIMARY KEY ( driver_key )
 );

CREATE  TABLE analytics.dim_location ( 
	location_key         integer  NOT NULL  ,
	delivery_address     varchar(100)    ,
	delivery_city        varchar    ,
	delivery_state       varchar    ,
	delivery_region      integer    ,
	delivery_lat         double precision    ,
	delivery_long        double precision    ,
	src_update_ts        timestamp  NOT NULL  ,
	dw_update_ts         timestamp  NOT NULL  ,
	CONSTRAINT pk_dim_location PRIMARY KEY ( location_key )
 );

CREATE  TABLE analytics.dim_menu_item ( 
	menu_item_key        integer  NOT NULL  ,
	menu_item_name       varchar(100)    ,
	menu_item_description varchar(1000)    ,
	menu_item_price      double precision    ,
	src_update_ts        timestamp  NOT NULL  ,
	dw_update_ts         timestamp  NOT NULL  ,
	effective_start_ts   timestamp  NOT NULL  ,
	effective_end_ts     timestamp  NOT NULL  ,
	CONSTRAINT pk_dim_menu_item PRIMARY KEY ( menu_item_key )
 );

CREATE  TABLE analytics.dim_menu_item_scd1 ( 
	menu_item_key        integer  NOT NULL  ,
	menu_item_name       varchar(100)    ,
	menu_item_description varchar(1000)    ,
	menu_item_price      double precision    ,
	src_update_ts        timestamp  NOT NULL  ,
	dw_update_ts         timestamp  NOT NULL  ,
	CONSTRAINT pk_dim_menu_item_0 PRIMARY KEY ( menu_item_key )
 );

CREATE  TABLE analytics.dim_menu_item_scd2 ( 
	menu_item_key        integer  NOT NULL  ,
	menu_item_name       varchar(100)    ,
	menu_item_description varchar(1000)    ,
	menu_item_price      double precision    ,
	src_update_ts        timestamp  NOT NULL  ,
	dw_update_ts         timestamp  NOT NULL  ,
	effective_start_ts   timestamp  NOT NULL  ,
	effective_end_ts     timestamp  NOT NULL  ,
	CONSTRAINT pk_dim_menu_item_1 PRIMARY KEY ( menu_item_key, effective_start_ts )
 );

CREATE  TABLE analytics.dim_restaurant ( 
	restaurant_key       integer  NOT NULL  ,
	restaurant_name      varchar(100)    ,
	restaurant_address   varchar(100)    ,
	restaurant_lat       double precision    ,
	restaurant_long      double precision    ,
	src_update_ts        timestamp  NOT NULL  ,
	dw_update_ts         timestamp  NOT NULL  ,
	CONSTRAINT pk_dim_restaurant PRIMARY KEY ( restaurant_key )
 );

CREATE  TABLE analytics.fact_category_delivery ( 
	food_delivery_key    integer  NOT NULL  ,
	category_key         integer  NOT NULL  ,
	customer_key         integer  NOT NULL  ,
	driver_key           integer  NOT NULL  ,
	location_key         integer  NOT NULL  ,
	order_date           date  NOT NULL  ,
	delivery_request_date date    ,
	delivery_date        date    ,
	dw_update_ts         timestamp  NOT NULL  ,
	food_amount          double precision    ,
	tax_amount           double precision    ,
	tip_amount           double precision    ,
	delivery_fee_amount  double precision    ,
	CONSTRAINT pk_fact_food_delivery PRIMARY KEY ( food_delivery_key )
 );


CREATE  TABLE analytics.fact_menu_item_delivery_scd ( 
	food_delivery_key    integer  NOT NULL  ,
	category_key         integer  NOT NULL  ,
	customer_key         integer  NOT NULL  ,
	driver_key           integer  NOT NULL  ,
	location_key         integer  NOT NULL  ,
	restaurant_key       integer  NOT NULL  ,
	menu_item_key        integer  NOT NULL  ,
	order_date           date  NOT NULL  ,
	delivery_request_date date    ,
	delivery_date        date    ,
	food_amount          double precision    ,
	dw_update_ts         timestamp  NOT NULL  ,
	CONSTRAINT pk_fact_food_delivery_1 PRIMARY KEY ( food_delivery_key )
 );

CREATE  TABLE transaction_concept.category ( 
	category_id          integer  NOT NULL  ,
	category_name        varchar(100)    ,
	category_description varchar(1000)    ,
	update_ts            timestamp  NOT NULL  ,
	CONSTRAINT pk_category PRIMARY KEY ( category_id )
 );

CREATE  TABLE transaction_concept.customer ( 
	customer_id          integer  NOT NULL  ,
	cust_name            varchar(100)    ,
	cust_address         varchar(100)    ,
	cust_phone           varchar    ,
	cust_email           varchar    ,
	update_ts            timestamp  NOT NULL  ,
	CONSTRAINT pk_customer PRIMARY KEY ( customer_id )
 );

CREATE  TABLE transaction_concept.delivery_location ( 
	delivery_location_id integer  NOT NULL  ,
	delivery_address     varchar(100)    ,
	delivery_city        varchar    ,
	delivery_state       varchar    ,
	delivery_region      integer    ,
	delivery_lat         double precision    ,
	delivery_long        double precision    ,
	update_ts            timestamp  NOT NULL  ,
	CONSTRAINT pk_delivery_location PRIMARY KEY ( delivery_location_id )
 );

CREATE  TABLE transaction_concept.driver ( 
	driver_id            integer  NOT NULL  ,
	driver_name          varchar(100)    ,
	driver_license_number varchar(20)    ,
	driver_phone         varchar    ,
	driver_address       varchar(100)    ,
	update_ts            timestamp  NOT NULL  ,
	CONSTRAINT pk_driver PRIMARY KEY ( driver_id )
 );

CREATE  TABLE transaction_concept.restaurant ( 
	restaurant_id        integer  NOT NULL  ,
	restaurant_name      varchar(100)    ,
	restaurant_address   varchar(100)    ,
	restaurant_lat       double precision    ,
	restaurant_long      double precision    ,
	update_ts            timestamp  NOT NULL  ,
	category_id          integer  NOT NULL  ,
	CONSTRAINT pk_restaurant PRIMARY KEY ( restaurant_id ),
	CONSTRAINT fk_restaurant_category FOREIGN KEY ( category_id ) REFERENCES transaction_concept.category( category_id )   
 );

CREATE  TABLE transaction_concept.customer_delivery_location ( 
	customer_deliver_location_id integer  NOT NULL  ,
	customer_id          integer  NOT NULL  ,
	delivery_location_id integer  NOT NULL  ,
	update_ts            timestamp  NOT NULL  ,
	CONSTRAINT pk_customer_delivery_location PRIMARY KEY ( customer_deliver_location_id ),
	CONSTRAINT fk_customer_delivery_location_customer FOREIGN KEY ( customer_id ) REFERENCES transaction_concept.customer( customer_id )   ,
	CONSTRAINT fk_customer_delivery_location_delivery_location FOREIGN KEY ( delivery_location_id ) REFERENCES transaction_concept.delivery_location( delivery_location_id )   
 );

CREATE  TABLE transaction_concept.delivery ( 
	delivery_id          integer  NOT NULL  ,
	driver_id            integer  NOT NULL  ,
	requested_time       timestamp    ,
	pick_up_time         timestamp    ,
	delivery_time        timestamp    ,
	delivery_location_id integer  NOT NULL  ,
	delivery_fee         double precision    ,
	tax                  double precision    ,
	tip                  double precision    ,
	update_ts            timestamp  NOT NULL  ,
	CONSTRAINT pk_tbl_0 PRIMARY KEY ( delivery_id ),
	CONSTRAINT fk_order_driver_0 FOREIGN KEY ( driver_id ) REFERENCES transaction_concept.driver( driver_id )   ,
	CONSTRAINT fk_order_delivery_location_0 FOREIGN KEY ( delivery_location_id ) REFERENCES transaction_concept.delivery_location( delivery_location_id )   
 );

CREATE  TABLE transaction_concept.menu_item ( 
	menu_item_id         integer  NOT NULL  ,
	menu_item_name       varchar(100)    ,
	menu_item_description varchar(1000)    ,
	menu_item_price      double precision    ,
	update_ts            timestamp  NOT NULL  ,
	restaurant_id        integer  NOT NULL  ,
	CONSTRAINT pk_menu PRIMARY KEY ( menu_item_id ),
	CONSTRAINT fk_menu_item_restaurant FOREIGN KEY ( restaurant_id ) REFERENCES transaction_concept.restaurant( restaurant_id )   
 );

CREATE  TABLE transaction_concept."order" ( 
	order_id             integer  NOT NULL  ,
	delivery_id          integer  NOT NULL  ,
	menu_item_id         integer    ,
	item_price           double precision    ,
	quantity             integer    ,
	update_ts            timestamp  NOT NULL  ,
	CONSTRAINT pk_tbl PRIMARY KEY ( order_id ),
	CONSTRAINT fk_order_menu_item FOREIGN KEY ( menu_item_id ) REFERENCES transaction_concept.menu_item( menu_item_id )   ,
	CONSTRAINT fk_order_delivery FOREIGN KEY ( delivery_id ) REFERENCES transaction_concept.delivery( delivery_id )   
 );

CREATE  TABLE transaction_concept.customer_order ( 
	customer_order_id    integer  NOT NULL  ,
	customer_id          integer  NOT NULL  ,
	order_id             integer  NOT NULL  ,
	update_ts            timestamp  NOT NULL  ,
	CONSTRAINT pk_customer_order PRIMARY KEY ( customer_order_id ),
	CONSTRAINT fk_customer_order_customer FOREIGN KEY ( customer_id ) REFERENCES transaction_concept.customer( customer_id )   ,
	CONSTRAINT fk_customer_order_order FOREIGN KEY ( order_id ) REFERENCES transaction_concept."order"( order_id )   
 );

COMMENT ON TABLE transaction_concept.category IS 'food categories';

COMMENT ON TABLE transaction_concept.customer IS 'customers of the service';

COMMENT ON TABLE transaction_concept.customer_delivery_location IS 'associative table between customer and delivery location';



-- This view simulates updated menu_item data that can be inserted
-- into the dimensional model tables.  This allows us
-- to demonstrate how a type I and a II slowly changing dimension work
-- and can be populated.
-- It gives all of the original records, and then unions to them
--   a sample of half of the rows with updates, keeping the 
--   original source system's primary key value.
-- You will end up with all of the original rows, plus about half as
--   many rows with updates.
create view transaction_concept.menu_item_newstuff as
select menu_item_id
     , menu_item_name
     , menu_item_description
     , menu_item_price
     , update_ts
     , restaurant_id
  from transaction_concept.menu_item
 union all 
select menu_item_id
     , menu_item_name || ' v2.0'
     , 'An all new ' || menu_item_description
     , menu_item_price
     , update_ts + (trunc(random() * 50) + 1) * '1 day'::interval
     , restaurant_id
  from transaction_concept.menu_item
 where mod(cast(random()*10 as integer),2) = 0  -- randomly pick half of them to change
;
