select *
from b2b_invoices;

create table b2b_staging
like b2b_invoices;

select *
from b2b_staging;

insert into b2b_staging
select *
from b2b_invoices;


-- 1 remove Duplicates

select *,
row_number() over(
partition by `order_date`,invoice_no,customer_id,product_id,product,category,segment,quantity,unit_cost,unit_price,revenue,cost,margin,`ship_date`
) as row_num
from b2b_staging;


with duplicate_cte as
(
select *,
row_number() over(
partition by `order_date`,invoice_no,customer_id,product_id,product,category,segment,quantity,unit_cost,unit_price,revenue,cost,margin,`ship_date`
) as row_num
from b2b_staging
)
select *
from duplicate_cte
where row_num>1;


CREATE TABLE `b2b_staging2` (
  `order_date` text,
  `invoice_no` int DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `customer` text,
  `product_id` int DEFAULT NULL,
  `product` text,
  `category` text,
  `segment` text,
  `quantity` text,
  `unit_cost` int DEFAULT NULL,
  `unit_price` double DEFAULT NULL,
  `revenue` text,
  `cost` int DEFAULT NULL,
  `margin` double DEFAULT NULL,
  `ship_date` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


select *
from b2b_staging2;

insert into b2b_staging2
select *,
row_number() over(
partition by `order_date`,invoice_no,customer_id,product_id,product,category,segment,quantity,unit_cost,unit_price,revenue,cost,margin,`ship_date`
) as row_num
from b2b_staging;


delete
from b2b_staging2
where row_num>1;

select * 
from b2b_staging2
where customer_id=268;


select * 
from b2b_staging2;






-- 2 Standardize Data by handling data and trailing it



select customer,trim(customer)
from b2b_staging2;


update b2b_staging2
set customer=trim(customer);


update b2b_staging2
set product=trim(product);

update b2b_staging2
set category=trim(category);

update b2b_staging2
set segment=trim(segment);

select *
from b2b_staging2; 

SELECT order_date,
 CASE 
       -- 1. YYYY-MM-DD (e.g., 2026-07-31) 
       WHEN `order_date` LIKE '____-%-%' THEN STR_TO_DATE(order_date, '%Y-%m-%d')
       -- 2. MM-DD-YYYY (e.g., 08-17-2026)
       WHEN `order_date` LIKE '__-__-____' THEN STR_TO_DATE(`order_date`, '%m-%d-%Y')
       
       -- 3 & 4. MM/DD/YYYY or DD/MM/YYYY (e.g., 08/19/2026 or 25/08/2026)
       WHEN `order_date` LIKE '%/%/%' THEN 
            COALESCE(
                STR_TO_DATE(`order_date`, '%m/%d/%Y'), 
                STR_TO_DATE(`order_date`, '%d/%m/%Y')
            )
       ELSE NULL
   END AS standardized_date
FROM b2b_staging2;

select *
from b2b_staging2;

update b2b_staging2
set `order_date` =
 CASE 
       
       WHEN `order_date` LIKE '____-%-%' THEN STR_TO_DATE(order_date, '%Y-%m-%d')
       
       WHEN `order_date` LIKE '__-__-____' THEN STR_TO_DATE(`order_date`, '%m-%d-%Y')
       
       
       WHEN `order_date` LIKE '%/%/%' THEN 
            COALESCE(
                STR_TO_DATE(`order_date`, '%m/%d/%Y'), 
                STR_TO_DATE(`order_date`, '%d/%m/%Y')
            )
       ELSE `order_date`
   END ;
   
   set session sql_mode='';
   
   