CREATE DATABASE sales;
USE sales;

-- DROP DATABASE sales;

-- Create individual table to load the csv files into
CREATE TABLE customer (
	customer_id SMALLINT NOT NULL,
     customer_names VARCHAR(20) NOT NULL,
     
     PRIMARY KEY (customer_id)
) ENGINE=INNODB;


CREATE TABLE product (
	product_id SMALLINT NOT NULL,
     product_name VARCHAR(19) NOT NULL,
     
     PRIMARY KEY (product_id)
) ENGINE=INNODB;


CREATE TABLE regions (
	state_code VARCHAR(3) NOT NULL,
     state VARCHAR(21) NOT NULL,
     region  VARCHAR(10) NOT NULL,
     
     PRIMARY KEY (state_code)
) ENGINE=INNODB;


CREATE TABLE sales_team (
	sales_team_id SMALLINT NOT NULL,
     sales_team VARCHAR(20) NOT NULL,
     region  VARCHAR(10),
     
     PRIMARY KEY (sales_team_id)
) ENGINE=INNODB;


CREATE TABLE store (
	store_id SMALLINT NOT NULL,
     city_name VARCHAR(30) NOT NULL,
     county  TEXT,                        -- VARCHAR(60)
     state_code VARCHAR(3) NOT NULL,
     state VARCHAR(21) NOT NULL,
     type VARCHAR(24),
     latitude FLOAT,
     longitude FLOAT,
     area_code INT,
     population INT,
     household_income FLOAT,
     median_income FLOAT,
     land_area INT,
     water_area INT,
     time_zone VARCHAR(29),
     location VARCHAR(36),
     
     PRIMARY KEY (store_id),
     
     FOREIGN KEY (state_code)
		REFERENCES regions(state_code)
) ENGINE=INNODB;


CREATE TABLE sales_order (
	order_number VARCHAR(12) CHARACTER SET ascii NOT NULL,
     sales_channel VARCHAR(12) NOT NULL,
     warehouse_code CHAR(12) CHARACTER SET ascii,
     procured_date DATE NOT NULL,
     order_date DATE NOT NULL,
     ship_date DATE NOT NULL,
     delivery_date DATE NOT NULL,
     currency_code CHAR(3),
     sales_team_id SMALLINT NOT NULL,
     customer_id SMALLINT NOT NULL,
     store_id SMALLINT NOT NULL,
     product_id SMALLINT NOT NULL,
     order_quantity TINYINT,
     discount_applied FLOAT,
     unit_price FLOAT,
     unit_cost DOUBLE,
     
     PRIMARY KEY (order_number),
     
     FOREIGN KEY (sales_team_id)
		REFERENCES sales_team(sales_team_id),
          
	FOREIGN KEY (customer_id)
		REFERENCES customer(customer_id),
          
	FOREIGN KEY (store_id)
		REFERENCES store(store_id),
          
	FOREIGN KEY (product_id)
		REFERENCES product(product_id)
) ENGINE=INNODB;

-- DROP TABLE sales_order;

-- Loading Data into database
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/customers_sheet.csv"
	INTO TABLE customer
     FIELDS TERMINATED BY ','
     ENCLOSED BY '"'  
     LINES TERMINATED BY '\n'
     IGNORE 1 ROWS;

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products_sheet.csv"
	INTO TABLE product
     FIELDS TERMINATED BY ','
     -- ENCLOSED BY '"'
     LINES TERMINATED BY '\n'
     IGNORE 1 ROWS;


LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/regions_sheet.csv"
	INTO TABLE regions 
     FIELDS TERMINATED BY ','
     LINES TERMINATED BY '\n'
     IGNORE 1 ROWS;
     

LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_team_sheet.csv"
	INTO TABLE sales_team 
     FIELDS TERMINATED BY ','
     LINES TERMINATED BY '\n'
     IGNORE 1 ROWS;
     
-- 
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/store_locations_sheet.csv"
	INTO TABLE store 
     FIELDS TERMINATED BY ','
     ENCLOSED BY '"'  
     LINES TERMINATED BY '\n'
     IGNORE 1 ROWS;
     
     
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_orders_sheet.csv"
	INTO TABLE sales_order 
     FIELDS TERMINATED BY ','
     LINES TERMINATED BY '\n'
     IGNORE 1 ROWS;