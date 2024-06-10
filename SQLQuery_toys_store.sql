-- data clensing --
alter table products$
add  price int;
alter table products$
add  cost int;

update products$
set price = cast(cast(replace(Product_Price, '$', '') as decimal(10, 2)) as int),
update products$
set cost =cast(cast(replace(Product_Cost, '$', '') as decimal(10, 2)) as int)


--Which product categories drive the biggest profits? Is this the same across store locations?
with data_raw as(
select b.Product_category, c.store_location,
year(date) as year,
(b.price*a.units)-(b.cost*a.units) as profit
from [dbo].[sales$] a
join products$ b
on b.Product_id = a.Product_id
join store$ c
on a.store_id = c.store_id
)
SELECT Product_category, store_location,
[2017] as year2017,
[2018] as year2018
from (select Product_category, store_location, year, profit from data_raw) as source_pivot
PIVOT
(
sum(profit)
 for year in ([2017],[2018])
 )as pivot_table;

-- find any seasonal trends or patterns in the sales data? 

select b.Product_category,
year(date) as year,
DATENAME(MONTH, Date) AS MonthName,
sum(a.units) as total_product_sale
from [dbo].[sales$] a
join products$ b
on b.Product_id = a.Product_id
group by  b.Product_category,
year(date),
DATENAME(MONTH, Date)
order by sum(a.units) desc

-- How much money is tied up in inventory at the toy stores? How long will it last?


select c.Store_Name,b.Product_name,
cast(avg(d.units) as INT) as avg_perday,
sum((b.cost*a.stock_On_Hand))as money_in_inventory
from [dbo].[inventory$] a
join [dbo].[products$] b
on a.product_id = b.product_id
join [dbo].[store$]  c
on a.Store_ID = c.Store_ID
join [dbo].[sales$] d
on a.Store_ID = d.Store_ID
group by c.Store_Name,b.Product_Name