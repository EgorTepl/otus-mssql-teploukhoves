use WideWorldImporters;

-------------
-- where - фильтрация строк по условию 
-- условие - логическое выражение
-- принимает 3 значения: true, false, unknown (неопределено - если в поле null)
-- в итог попадут строки, у которых условие выполнено ( = true )
-------------
select Size, * from Warehouse.StockItems where 0=1 --сколько строк?
select Size, * from Warehouse.StockItems where 1=1 --вся таблица
select Size, * from Warehouse.StockItems where Size = '1/12 scale'

-- остальные: Size = null (неопределено, нет информации)
select Size, * from Warehouse.StockItems where Size = null -- так не работает 

-- null в where: is null, is not null
select Size, * from Warehouse.StockItems where Size is null

-- null в колонке: isnull(), coalesce()
-- isnull () - замена null на 2й параметр функции
-- coalisce () - вывод первого не null-значения
select Size, ColorId, isnull(Size, 0) as [isnull], coalesce(Size, ColorId, -10) as [coalesce]
from Warehouse.StockItems 
where Size is null

-------------
-- функции в WHERE см. Programmability - Functions - System Functions
-------------

select OrderID, OrderDate, year(OrderDate)
from Sales.Orders o
where year(OrderDate) = 2013
-- Но не может использоваться индекс (если он когда-нибудь появится)

-- Лучше через BETWEEN
select OrderDate, OrderID
from Sales.Orders o
where OrderDate BETWEEN '2013-01-01' AND '2013-12-31'

-- WHERE по выражению
select  OrderLineID, Quantity, UnitPrice, (Quantity * UnitPrice) AS [TotalCost]
from Sales.OrderLines
where (Quantity * UnitPrice) > 1000

--like 
select * from Warehouse.StockItems where StockItemName like 'USB%' -- начинается
select * from Warehouse.StockItems where StockItemName like '%USB%' --где угодно USB
select * from Warehouse.StockItems where StockItemName like '%USB' -- заканчиввется

-------------
-- несколько условий: AND, OR, NOT
-------------
-- вывести StockItems, где цена от 350 до 500 и название начинается с USB или Ride

-- попали строки с ценой < 350, как исправить?
select RecommendedRetailPrice, StockItemName
from Warehouse.StockItems
where
    RecommendedRetailPrice between 350 and 500 --цена от 350 до 500
	AND StockItemName like 'USB%' --название начинается с USB
 	OR StockItemName like 'Ride%' --название начинается с Ride


--pgdn







-- скобки если есть OR 
select RecommendedRetailPrice, *
from Warehouse.StockItems
where
    RecommendedRetailPrice between 350 and 500 --цена от 350 до 500
	and (StockItemName like 'USB%' --название начинается с USB
    or StockItemName like 'Ride%') --название начинается с Ride

-------------
--работа с датами функции - см. Programmability - Function - System Function...
-------------
declare @dt datetime2 = sysdatetime()

select year(@dt) as [Год] --алиас/псевдоним
	, [Месяц] = month(@dt)
	, datepart(quarter, @dt) as 'Квартал'
	, datename(month, @dt) as "Месяц "
	, FORMAT(@dt, 'MMMM', 'ru-ru') as [Месяц Ru]
	, FORMAT(@dt, 'D', 'ru-ru') as 'Russian'
	, FORMAT(@dt, 'D', 'en-US' ) 'US English'  
	, convert(varchar, @dt, 104) as [Дата] 
	, datetrunc(month, @dt) as begin_of_month_SQL2022  --c SQL2022
	, eomonth(@dt) as end_of_month

-- почему разное кол-во?
select count(*) from Sales.Orders where OrderDate = '2015-05-02'
select count(*) from Sales.Orders where OrderDate = '02.05.2015' 

--pgdn



select @@language, FORMAT(cast('02.05.2015' as date), 'D', 'ru-ru') 
select @@language, FORMAT(cast('2015-05-02' as date), 'D', 'ru-ru') 

-- язык указывается при установке SQL-сервера - см. Server - Properties
set language 'Russian' --на уровне сеанса
select @@language, FORMAT(cast('02.05.2015' as date), 'D', 'ru-ru') 

set language 'English' --верну обратно
select @@language, FORMAT(cast('02.05.2015' as date), 'D', 'ru-ru') 

-- используем универсальный формат 'yyyyMMdd' или 'yyyy-mm-dd'