
/*_______________________ Task 5 _______________________*/

/* Should be 1 - we check to not have the same employee on 2 or more departaments, sanity check*/
select MAX("cnt")
from ( 
	select count(edh."EmployeeID") as "cnt"
	from employeedepartmenthistory as edh
	where (edh."EndDate" > '1999-05-01' or edh."EndDate" is null) and edh."StartDate" <= '1999-05-01'
	group by edh."EmployeeID"
)

with "A" as (
	select edh."DepartmentID",
	count(edh."DepartmentID") as "Nr of employees"
	from employeedepartmenthistory as edh
	where (edh."EndDate" > '1999-05-1' or edh."EndDate" is null) and edh."StartDate" <= '1999-05-01'
	group by edh."DepartmentID"
)
select d."Name" as "Department",  
	"A"."Nr of employees" 
from "A"
join department as d 
on "A"."DepartmentID" = d."DepartmentID" 

/*_______________________ Task 6 _______________________*/

with "ChangeRates" as (
	select abs(c."AverageRate" - c."EndOfDayRate") as "ChangeRate",
		c."CurrencyRateDate" as "Date"
	from currencyrate as c 
	where c."FromCurrencyCode" = 'USD' and c."ToCurrencyCode" = 'CAD'
)
select "Diff", "Date"
from (
	select abs("ChangeRate" - lag("ChangeRate") over (order by "Date")) as "Diff",
		"Date" as "Date"
	from "ChangeRates"
)
where "Diff" is not null
order by "Diff" desc
limit 1


/*_______________________ Task 7 _______________________*/

with recursive subordination_chains as (
  select 
    "EmployeeID",
    "ManagerID",
    cast("EmployeeID" as varchar) as "chain",
    1 as "depth"
  from employee
  union all
  select
    sc."EmployeeID",
    e."ManagerID",
    cast(e."EmployeeID" as varchar) || ' -> ' ||  sc."chain",
    sc."depth" + 1
  from subordination_chains as sc
  inner join Employee as e 
  on e."EmployeeID" = sc."ManagerID"
  where sc."depth" < 10
)
select "EmployeeID", "chain"
from (
	select
	  "EmployeeID",
	  "chain",
	  row_number() over (partition by "EmployeeID" order by "depth" desc) as "RowNumber"
	from subordination_chains
)
where "RowNumber" = 1
order by "EmployeeID"


/*_______________________ Task 8 _______________________*/


select v."CreditRating",
	count(v."CreditRating") as "Count Vendors"
from vendor as v
group by v."CreditRating"
order by v."CreditRating"

select v."CreditRating",
	count(v."CreditRating") as "Count Vendors With Orders"
from vendor as v
where v."VendorID" in 
	(select "VendorID" from purchaseorderheader)
group by v."CreditRating"
order by v."CreditRating"

select v."VendorID",
	v."CreditRating",
	sum(pod."OrderQty" * pod."UnitPrice") as "TotalMoney",
	count(poh."PurchaseOrderID") as "TotalOrders"
from vendor as v
full join purchaseorderheader as poh 
on v."VendorID" = poh."VendorID"
full join purchaseorderdetail as pod
on poh."PurchaseOrderID" = pod."PurchaseOrderID" 
group by v."VendorID"
order by "CreditRating", "TotalMoney"


with tmp as (
	select v."VendorID",
		v."CreditRating",
		sum(pod."OrderQty" * pod."UnitPrice") as "TotalMoney",
		count(poh."PurchaseOrderID") as "TotalOrders"
	from vendor as v
	join purchaseorderheader as poh 
	on v."VendorID" = poh."VendorID"
	join purchaseorderdetail as pod
	on poh."PurchaseOrderID" = pod."PurchaseOrderID" 
	group by v."VendorID"
	order by "CreditRating", "TotalMoney"
)
select
	"CreditRating",
	avg("TotalOrders") as "Avg Total Orders", 
	avg("TotalMoney") as "Avg Total Money", 
	min("TotalMoney") as "Min Total Money",
	max("TotalMoney") as "Max Total Money" 
from tmp
group by tmp."CreditRating"


/*_______________________ Task 9 _______________________*/

select 
	"Gender",
	avg("Rate"),
	min("Rate"),
		max("Rate"),
		stddev("Rate")
from (
	select e."Gender",
		eph."Rate", 
		rank() over (partition by e."EmployeeID" order by eph."RateChangeDate" desc ) as "rank"
	from employee as e
	left join employeepayhistory as eph
	on e."EmployeeID" = eph."EmployeeID" 
	order by e."EmployeeID" 
)
where "rank" = 1
group by "Gender"

select 
	"MaritalStatus",
	avg("Rate"),
	min("Rate"),
	max("Rate"),
	stddev("Rate")
from (
	select
		e."MaritalStatus",
		eph."Rate", 
		rank() over (partition by e."EmployeeID" order by eph."RateChangeDate" desc ) as "rank"
	from employee as e
	left join employeepayhistory as eph
	on e."EmployeeID" = eph."EmployeeID" 
	order by e."EmployeeID" 
)
where "rank" = 1
group by "MaritalStatus"

select 
	"years",
	avg("Rate"),
	min("Rate"),
	max("Rate"),
	stddev("Rate")
from (
	select
		extract(year from age(eph."RateChangeDate", e."BirthDate")) as "years",
		eph."Rate", 
		rank() over (partition by e."EmployeeID" order by eph."RateChangeDate" desc ) as "rank"
	from employee as e
	left join employeepayhistory as eph
	on e."EmployeeID" = eph."EmployeeID" 
	order by e."EmployeeID" 
)
where "rank" = 1
group by "years"
order by "years"

select 
	cast("years"*10 as varchar)|| '-' || cast("years"*10+9 as varchar) as "Years",
	avg("Rate"),
	min("Rate"),
	max("Rate"),
	stddev("Rate")
from (
	select
		floor(extract(year from age(eph."RateChangeDate", e."BirthDate"))/10) as "years",
		eph."Rate", 
		rank() over (partition by e."EmployeeID" order by eph."RateChangeDate" desc ) as "rank"
	from employee as e
	left join employeepayhistory as eph
	on e."EmployeeID" = eph."EmployeeID" 
	order by e."EmployeeID" 
)
where "rank" = 1
group by "years"
order by "years"







