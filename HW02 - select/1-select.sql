use WideWorldImporters --выбор базы

-- ****************************************
-- варианты обращения к таблице
-- таблица в другой базе
select * from AdventureWorks2017.Sales.Currency
-- таблица в текущей БД
select * from WideWorldImporters.Application.People 
select * from Application.People
select * from People --только если схема = dbo


-- ****************************************
-- ограничение кол-ва строк
-- ****************************************

-- без дублей в названии
select distinct CityName from Application.Cities

select top 10 * from Application.Cities --любые 10 строк (быстро, но порядок выдачи не гарантирован)
-- задаем сортировку
select top 10 CityID, CityName, StateProvinceID from Application.Cities order by CityName
-- сортировка по нескольким полям
select top 10 CityID, CityName, StateProvinceID from Application.Cities order by CityName asc, StateProvinceID asc
select top 10 CityID, CityName, StateProvinceID from Application.Cities order by 2, 3 desc


--кол-во строк - через переменную
declare @n int = 5
select top @n * from Application.Cities

-- ****************************************
-- Постраничная выборка
-- ****************************************

DECLARE @m INT = 5
SELECT *
FROM Application.Cities as c
ORDER BY c.CityName ASC OFFSET 0 ROWS -- сортировка обязательна 
FETCH NEXT @m ROWS ONLY

-- общая формула
DECLARE @pagesize BIGINT = 10, -- Размер страницы
	@pagenum BIGINT = 1;-- Номер страницы

SELECT StockItemID, StockItemName, UnitPrice
FROM Warehouse.StockItems
ORDER BY UnitPrice DESC OFFSET(@pagenum - 1) * @pagesize ROWS -- сортировка обязательна 
FETCH NEXT @pagesize ROWS ONLY

-- вывести список товаров, входящих в top 3 по цене
select StockItemID, StockItemName, UnitPrice
from Warehouse.StockItems
order by UnitPrice desc

--товары, входящие в 3ку самых дорогих на складе => потеря 1 товара с граничной ценой (285.00)
select top 3 StockItemID, StockItemName, UnitPrice
from Warehouse.StockItems
order by UnitPrice desc

-- SELECT TOP N WITH TIES ... - выводит N строк + все строки с граничным значением столбцов сортировки
-- граница по столбцу сортировки - UnitPrice = 285.00 => 2 строки с UnitPrice = 285.00
select top 3 with ties StockItemID, StockItemName, UnitPrice
from Warehouse.StockItems
order by UnitPrice desc -- сортировка обязательна!!