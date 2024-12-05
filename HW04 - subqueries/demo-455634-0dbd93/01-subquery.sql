-- независимый
SELECT StockItemID, StockItemName, UnitPrice, (
		SELECT MAX(UnitPrice)
		FROM Warehouse.StockItems
		) AS MaxPrice
FROM Warehouse.StockItems

-- зависимый (от People.PersonID)
-- Сколько продаж было у менеджеров по продажам
-- Ctlr + M
set statistics time, io on;

SELECT PersonId, FullName
	, (
		-- считаю продажи по каждому сотруднику
		SELECT COUNT(InvoiceId) AS SalesCount
		FROM Sales.Invoices
		WHERE Invoices.SalespersonPersonID = People.PersonID -- зависимость от основного запроса
		) AS TotalSalesCount
FROM Application.People
WHERE IsSalesperson = 1

-- то же самое только через join
SELECT 
	p.PersonId, 
	p.FullName, 
	count(*) as TotalSalesCount
FROM Application.People p
JOIN Sales.Invoices i ON i.SalespersonPersonID = p.PersonID
WHERE p.IsSalesperson = 1
GROUP BY p.PersonID, p.FullName


-- в подзапросе только 1 значение!
SELECT PersonId, FullName, (
		SELECT top 1 InvoiceId -- <- изменение
		FROM Sales.Invoices
		WHERE Invoices.SalespersonPersonID = People.PersonID -- зависимость от основного запроса
		) AS TotalSalesCount
FROM Application.People
WHERE IsSalesperson = 1

----------------------------------
-- подзапросы в where: in, exists [any - каждый, all - любой]
----------------------------------

----------------
-- IN
----------------

-- Показать информацию по людям, которые продавали товары
SELECT *
FROM Application.People
WHERE PersonId IN (SELECT SalespersonPersonID FROM Sales.Invoices); --in = список

SELECT *
FROM Application.People
WHERE PersonId IN (SELECT distinct SalespersonPersonID FROM Sales.Invoices); --то же самое

--

-- NULL
SELECT *
FROM (
	select PersonId from Application.People 
	union all 
	select null -- добавлен NULL
) t
WHERE PersonId IN (1,2,NULL); --true

-- эквивалентно
SELECT *
FROM (
	select PersonId from Application.People 
	union all 
	select null -- добавлен NULL
) t
WHERE PersonId = 1 OR PersonID = 2 OR PersonId = NULL; --поэтому NULL в списке не обработается



-- обработка NULL
SELECT *
FROM (
	select PersonId from Application.People 
	union all 
	select null -- добавлен NULL
) t
WHERE PersonId IN (1,2) OR PersonId IS NULL;

SELECT *
FROM Application.People
WHERE PersonId NOT IN (1,2, NULL);

SELECT *
FROM Application.People
WHERE NOT (PersonId = 1 OR PersonID = 2 OR PersonId = NULL);

--PersonId <> 1 AND PersonID <> 2 and PersonId <> NULL;
-- запросов с отрицанием лучше избегать - не самые оптимальные

----------------
-- EXISTS
----------------
SELECT *
FROM Application.People
WHERE PersonId IN (SELECT SalespersonPersonID FROM Sales.Invoices) 
ORDER BY PersonID;

SELECT *
FROM Application.People
WHERE EXISTS (
    SELECT *
	FROM Sales.Invoices
	WHERE SalespersonPersonID = People.PersonID) -- зависит от основной таблицы
ORDER BY PersonID;

-- Плохо ли здесь "SELECT *" ?
-- Не лучше ли "SELECT TOP 1 *" или "SELECT 1"?
-- посмотрим планы Ctrl + M
SELECT *
FROM Application.People
WHERE EXISTS (
    SELECT 1
	FROM Sales.Invoices
	WHERE SalespersonPersonID = People.PersonID)
ORDER BY PersonID;

SELECT DISTINCT Application.People.*
FROM Application.People
	JOIN Sales.Invoices 
		ON Invoices.SalespersonPersonID = People.PersonID
ORDER BY People.PersonID;

---------------------------
--- NOT EXISTS / NOT IN
SELECT *
FROM Application.People
WHERE NOT EXISTS ( 
    SELECT SalespersonPersonID
	FROM Sales.Invoices
	WHERE SalespersonPersonID = People.PersonID)
ORDER BY PersonID;


-- SELECT 1 vs count 

SELECT *
FROM Application.People
WHERE EXISTS (
		SELECT 1
		FROM Sales.Invoices
		WHERE SalespersonPersonID = People.PersonID
		);


SELECT *
FROM Application.People
WHERE (
		SELECT count(*)
		FROM Sales.Invoices
		WHERE SalespersonPersonID = People.PersonID
		) > 0


----------------
-- ALL (= любой из списка), ANY (= существует в списке)
----------------
-- минимальная цена
SELECT MIN(UnitPrice)
FROM Warehouse.StockItems;
GO

-- Товары с минимальной ценой
SELECT StockItemID, StockItemName, UnitPrice 
FROM Warehouse.StockItems
WHERE UnitPrice <= ALL /*любой*/(SELECT UnitPrice FROM Warehouse.StockItems);

-- эквивалентно
SELECT StockItemID, StockItemName, UnitPrice 
FROM Warehouse.StockItems
WHERE UnitPrice = (SELECT min(UnitPrice) FROM Warehouse.StockItems);


-- IN, = ANY
SELECT StockItemID, StockItemName, UnitPrice	
FROM Warehouse.StockItems
WHERE UnitPrice IN /*существует*/ (SELECT UnitPrice FROM Warehouse.StockItems);

SELECT StockItemID, StockItemName, UnitPrice	
FROM Warehouse.StockItems
WHERE UnitPrice = ANY /*существует*/(SELECT UnitPrice FROM Warehouse.StockItems);

