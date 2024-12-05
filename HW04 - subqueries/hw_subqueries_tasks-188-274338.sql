/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "03 - Подзапросы, CTE, временные таблицы".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- Для всех заданий, где возможно, сделайте два варианта запросов:
--  1) через вложенный запрос
--  2) через WITH (для производных таблиц)
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Выберите сотрудников (Application.People), которые являются продажниками (IsSalesPerson), 
и не сделали ни одной продажи 04 июля 2015 года. 
Вывести ИД сотрудника и его полное имя. 
Продажи смотреть в таблице Sales.Invoices.
*/

SELECT
	peop.PersonID,
	peop.FullName
FROM Application.People AS peop
WHERE
	peop.IsSalesperson = 1
	AND NOT EXISTS
		(
			SELECT inv.SalespersonPersonID
			 FROM Sales.Invoices AS inv
			  WHERE inv.InvoiceDate = '2015-07-04'
			   AND (inv.SalespersonPersonID = peop.PersonID)
		);
--//////////////////////////////////////////////////////////////////////////////
; WITH SalesPersonsWhoMadeSale_2015_07_04_CTE AS
(
	SELECT DISTINCT
		inv.SalespersonPersonID
	FROM Sales.Invoices AS inv
	WHERE inv.InvoiceDate = '2015-07-04'
)
SELECT
	peop.PersonID,
	peop.FullName
FROM Application.People AS peop
WHERE
	peop.IsSalesperson = 1
	 AND NOT EXISTS
	 (
		 SELECT cte.SalespersonPersonID
		  FROM SalesPersonsWhoMadeSale_2015_07_04_CTE as cte
		  WHERE cte.SalespersonPersonID = peop.PersonID
	 );

/*
2. Выберите товары с минимальной ценой (подзапросом). Сделайте два варианта подзапроса. 
Вывести: ИД товара, наименование товара, цена.
*/

SELECT
	itm.StockItemID,
	itm.StockItemName,
	itm.UnitPrice
FROM Warehouse.StockItems AS itm
WHERE itm.UnitPrice = (SELECT MIN(itmByMinPrice.UnitPrice) FROM Warehouse.StockItems AS itmByMinPrice)

--//////////////////////////////////////////////////////////////////////////////

SELECT
	itm.StockItemID,
	itm.StockItemName,
	itm.UnitPrice
FROM Warehouse.StockItems AS itm
JOIN
(
	SELECT MIN(UnitPrice) AS MinUnitPrice
	FROM Warehouse.StockItems
) AS itmByMinPrice
	ON itm.UnitPrice = itmByMinPrice.MinUnitPrice

/*
3. Выберите информацию по клиентам, которые перевели компании пять максимальных платежей 
из Sales.CustomerTransactions. 
Представьте несколько способов (в том числе с CTE). 
*/

;WITH MaxTransAmountByCustomerIdCTE AS
(
	SELECT
		custTrans.CustomerID,
		MAX(custTrans.TransactionAmount) AS MaxTransAmount
	FROM Sales.CustomerTransactions AS custTrans
	GROUP BY custTrans.CustomerID
)
SELECT TOP 5
	cte.CustomerID,
	cte.MaxTransAmount
FROM MaxTransAmountByCustomerIdCTE AS cte
ORDER BY cte.MaxTransAmount DESC;
--//////////////////////////////////////////////////////////////////////////////
SELECT TOP 5
	cust.CustomerID,
	MaxTransAmountByCustomerId.MaxTransAmount
FROM Sales.Customers AS cust
INNER JOIN
(
	SELECT
		custTrans.CustomerID,
		MAX(custTrans.TransactionAmount) AS MaxTransAmount
	 FROM Sales.CustomerTransactions AS custTrans
	 GROUP BY custTrans.CustomerID
) AS MaxTransAmountByCustomerId
	ON MaxTransAmountByCustomerId.CustomerID = cust.CustomerID
ORDER BY MaxTransAmountByCustomerId.MaxTransAmount DESC;

/*
4. Выберите города (ид и название), в которые были доставлены товары, 
входящие в тройку самых дорогих товаров, а также имя сотрудника, 
который осуществлял упаковку заказов (PackedByPersonID).
*/

DECLARE @Top3MostExpensiveItemsTableVariable TABLE (StockItemID INT NOT NULL)

INSERT INTO @Top3MostExpensiveItemsTableVariable (StockItemID)
SELECT TOP 3 WITH ties
	item.StockItemID
FROM Warehouse.StockItems AS item
ORDER BY item.UnitPrice DESC

SELECT DISTINCT
	city.CityID,
	city.CityName,	
	peop.FullName AS PackedByPersonFullName
FROM Sales.InvoiceLines AS invLin
INNER JOIN sales.Invoices AS inv
	ON invLin.InvoiceID = inv.InvoiceID
INNER JOIN Application.People AS peop
	ON inv.PackedByPersonID = peop.PersonID
INNER JOIN sales.Customers AS cust
	ON inv.CustomerID = cust.CustomerID
INNER JOIN Application.Cities AS city
	ON cust.DeliveryCityID = city.CityID
WHERE invLin.StockItemID IN (SELECT StockItemID FROM @Top3MostExpensiveItemsTableVariable);
--//////////////////////////////////////////////////////////////////////////////
SELECT DISTINCT
	city.CityID,
	city.CityName,	
	peop.FullName AS PackedByPersonFullName
FROM
(
	SELECT TOP 3 WITH ties
		item.StockItemID, item.UnitPrice
	FROM Warehouse.StockItems AS item
	ORDER BY item.UnitPrice DESC
) AS TopMostExpensiveItemsTableVariable
JOIN Sales.InvoiceLines AS invLin
	ON invLin.StockItemID = TopMostExpensiveItemsTableVariable.StockItemID
JOIN sales.Invoices AS inv
	ON invLin.InvoiceID = inv.InvoiceID
JOIN Application.People AS peop
	ON inv.PackedByPersonID = peop.PersonID
JOIN sales.Customers AS cust
	ON inv.CustomerID = cust.CustomerID
JOIN Application.Cities AS city
	ON cust.DeliveryCityID = city.CityID
--//////////////////////////////////////////////////////////////////////////////

-- ---------------------------------------------------------------------------
-- Опциональное задание
-- ---------------------------------------------------------------------------
-- Можно двигаться как в сторону улучшения читабельности запроса, 
-- так и в сторону упрощения плана\ускорения. 
-- Сравнить производительность запросов можно через SET STATISTICS IO, TIME ON. 
-- Если знакомы с планами запросов, то используйте их (тогда к решению также приложите планы). 
-- Напишите ваши рассуждения по поводу оптимизации. 

-- 5. Объясните, что делает и оптимизируйте запрос

SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(SELECT People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = (SELECT Orders.OrderId 
			FROM Sales.Orders
			WHERE Orders.PickingCompletedWhen IS NOT NULL	
				AND Orders.OrderId = Invoices.OrderId)	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
	JOIN
	(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
		ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC

-- --
SET STATISTICS IO ON
SET STATISTICS TIME ON
--
-- Данный селект получает информацию о чеках за выполненные заказы клиентам с общей суммой более 27 000, 
-- стоимость итого выбранных клиентом товаров, а также сотрудниках, выполнивших данный заказ.
-- Одному коду квитанции о заказе Invoices.InvoiceID соответствует один код заказа на продажу Orders.OrderId. Заказы попадают в таблицу
-- Invoices.OrderId только после того как они будут собраны и реализованы.
-- Поэтому проверку Orders.PickingCompletedWhen IS NOT NULL можно не выполнять и напрямую установить соединение с таблицей OrderLines.OrderId.
SELECT 
	Invoices.InvoiceID, 
	Invoices.InvoiceDate,
	(
		SELECT
			People.FullName
		FROM Application.People
		WHERE People.PersonID = Invoices.SalespersonPersonID
	) AS SalesPersonName,  -- Получаем полное имя сотрудника, который оформил заказ для клиента
	SalesTotals.TotalSumm AS TotalSummByInvoice, 
	(
		SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
		FROM Sales.OrderLines
		WHERE OrderLines.OrderId = Invoices.OrderId	
	) AS TotalSummForPickedItems
FROM Sales.Invoices 
JOIN
(
	SELECT
		InvoiceId,
		SUM(Quantity * UnitPrice) AS TotalSumm
	FROM Sales.InvoiceLines
	GROUP BY InvoiceId
	HAVING SUM(Quantity * UnitPrice) > 27000
) AS SalesTotals
	ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC;