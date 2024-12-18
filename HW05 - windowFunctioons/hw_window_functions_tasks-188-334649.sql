/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "06 - Оконные функции".

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
-- ---------------------------------------------------------------------------

USE WideWorldImporters
/*
1. Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года 
(в рамках одного месяца он будет одинаковый, нарастать будет в течение времени выборки).
Выведите: id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом

Пример:
-------------+----------------------------
Дата продажи | Нарастающий итог по месяцу
-------------+----------------------------
 2015-01-29   | 4801725.31
 2015-01-30	 | 4801725.31
 2015-01-31	 | 4801725.31
 2015-02-01	 | 9626342.98
 2015-02-02	 | 9626342.98
 2015-02-03	 | 9626342.98
Продажи можно взять из таблицы Invoices.
Нарастающий итог должен быть без оконной функции.
*/

DECLARE @MaxInvoiceDate date = (SELECT MAX(InvoiceDate) FROM Sales.Invoices)

;WITH ParsedDataForRunningTotalSumCTE AS
(
	SELECT
		inv.InvoiceID,
		cust.CustomerName,
		inv.InvoiceDate,
		MONTH(inv.InvoiceDate) AS InvoiceMonth,
		YEAR(inv.InvoiceDate) AS InvoiceYear,
		(
			SELECT
				SUM(invLine.UnitPrice * invLine.Quantity) AS SalesAmount
			FROM Sales.InvoiceLines AS invLine
			WHERE inv.InvoiceID = invLine.InvoiceID
		) AS SalesAmount
	FROM Sales.Invoices AS inv
	JOIN sales.Customers AS cust
		ON inv.CustomerID = cust.CustomerID
	WHERE inv.InvoiceDate BETWEEN '01.01.2015' AND @MaxInvoiceDate
)
SELECT
	cte.InvoiceID,
	cte.CustomerName,
	cte.InvoiceDate,
	cte.SalesAmount,
	(
		SELECT
			SUM(cte2.SalesAmount) AS RunningSalesAmount
		FROM ParsedDataForRunningTotalSumCTE AS cte2
		WHERE (cte.InvoiceYear = cte2.InvoiceYear) AND (cte.InvoiceMonth >= cte2.InvoiceMonth)
	) AS RunningSalesAmount
FROM ParsedDataForRunningTotalSumCTE AS cte

/*
2. Сделайте расчет суммы нарастающим итогом в предыдущем запросе с помощью оконной функции.
   Сравните производительность запросов 1 и 2 с помощью set statistics time, io on
*/

DECLARE @MaxInvoiceDate1 date = (SELECT MAX(InvoiceDate) FROM Sales.Invoices)

;WITH ParsedDataForRunningTotalSumCTE AS
(
	SELECT
		inv.InvoiceID,
		cust.CustomerName,
		inv.InvoiceDate,
		MONTH(inv.InvoiceDate) AS InvoiceMonth,
		YEAR(inv.InvoiceDate) AS InvoiceYear,
		(
			SELECT
				SUM(invLine.UnitPrice * invLine.Quantity) AS SalesAmount
			FROM Sales.InvoiceLines AS invLine
			WHERE inv.InvoiceID = invLine.InvoiceID
		) AS SalesAmount
	FROM Sales.Invoices AS inv
	JOIN sales.Customers AS cust
		ON inv.CustomerID = cust.CustomerID
	WHERE inv.InvoiceDate BETWEEN '01.01.2015' AND @MaxInvoiceDate1
)
SELECT
	cte.InvoiceID,
	cte.CustomerName,
	cte.InvoiceDate,
	cte.SalesAmount,
	SUM(cte.SalesAmount) OVER(PARTITION BY cte.InvoiceYear ORDER BY cte.InvoiceYear, cte.InvoiceMonth) AS RunningSalesAmount
FROM ParsedDataForRunningTotalSumCTE AS cte
ORDER BY cte.InvoiceID

/*
3. Вывести список 2х самых популярных продуктов (по количеству проданных) 
в каждом месяце за 2016 год (по 2 самых популярных продукта в каждом месяце).
*/
; WITH CTE AS
(
	SELECT
		inv.InvoiceDate,
		MONTH(inv.InvoiceDate) AS InvoiceMonth,
		itm.StockItemName,
		invLine.Quantity * invLine.UnitPrice as TotalSum,
		DENSE_RANK() OVER(PARTITION BY MONTH(inv.InvoiceDate) ORDER BY invLine.Quantity * invLine.UnitPrice DESC) AS [rank]
	FROM Sales.InvoiceLines AS invLine
	JOIN Sales.Invoices AS inv
		ON invLine.InvoiceID = inv.InvoiceID
	JOIN Warehouse.StockItems AS itm
		ON invLine.StockItemID = itm.StockItemID
	WHERE inv.InvoiceDate BETWEEN '2016-01-01' AND '2016-12-31'
)
SELECT DISTINCT
	cte.InvoiceMonth,
	cte.StockItemName,
	CTE.totalSum,
	CTE.rank
FROM CTE
WHERE cte.rank in (1, 2)
ORDER BY
	cte.InvoiceMonth,
	CTE.rank

/*
4. Функции одним запросом
Посчитайте по таблице товаров (в вывод также должен попасть ид товара, название, брэнд и цена):
* пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
* посчитайте общее количество товаров и выведете полем в этом же запросе
* посчитайте общее количество товаров в зависимости от первой буквы названия товара
* отобразите следующий id товара исходя из того, что порядок отображения товаров по имени 
* предыдущий ид товара с тем же порядком отображения (по имени)
* названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
* сформируйте 30 групп товаров по полю вес товара на 1 шт

Для этой задачи НЕ нужно писать аналог без аналитических функций.
*/

SELECT
	itm.StockItemID,
	itm.StockItemName,
	itm.Brand,
	itm.UnitPrice,
	itm.TypicalWeightPerUnit,
	ROW_NUMBER() OVER(PARTITION BY LEFT(itm.StockItemName, 1) ORDER BY itm.StockItemName) AS ItemsAlphabeticalNumbering,
	COUNT(itm.StockItemID) OVER() AS ItemsTotalNumber,
	COUNT(itm.StockItemID) OVER(PARTITION BY LEFT(itm.StockItemName, 1)) AS ItemsAlphabeticaCount,
	LEAD(itm.StockItemName) OVER(ORDER BY itm.StockItemName) AS NextItemName,
	LAG(itm.StockItemName) OVER(ORDER BY itm.StockItemName) AS PreviousItemName,
	LAG(itm.StockItemName, 2, N'No items') OVER(ORDER BY itm.StockItemName) AS ItemName2LinesBack,
	NTILE(30) OVER(ORDER BY TypicalWeightPerUnit) AS ItemGroupsByTypicalWeightPerUnit
FROM Warehouse.StockItems AS itm

/*
5. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
   В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки.
*/

SELECT
	peop.PersonID AS SalesPersonId,
	peop.FullName AS SalesPersonName,
	cust.CustomerID,
	cust.CustomerName,
	inv.InvoiceDate,
	FIRST_VALUE(cust.CustomerID) OVER(PARTITION BY peop.PersonID ORDER BY inv.InvoiceDate DESC) AS TheLastCustomerBySalesPersonId,
	(
		SELECT
			SUM(invLine.Quantity * invLine.UnitPrice)
		FROM sales.InvoiceLines AS invLine
		WHERE inv.InvoiceID = invLine.InvoiceID
	) AS TransactionAmount
FROM sales.Invoices AS inv
JOIN Sales.Customers AS cust
	ON inv.CustomerID = cust.CustomerID
JOIN Application.People AS peop
	ON inv.SalespersonPersonID = peop.PersonID

/*
6. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/
; WITH CTE AS
(
	SELECT
		cust.CustomerID,
		cust.CustomerName,
		invLine.StockItemID,
		invLine.UnitPrice,
		inv.InvoiceDate,
		DENSE_RANK() OVER(PARTITION BY cust.CustomerID ORDER BY invLine.UnitPrice DESC) AS RankByUnitPrice
	FROM Sales.InvoiceLines AS invLine
	JOIN sales.Invoices AS inv
		ON inv.InvoiceID = invLine.InvoiceID
	JOIN Sales.Customers AS cust
		ON inv.CustomerID = cust.CustomerID
)
SELECT *
FROM CTE
WHERE RankByUnitPrice <= 2

Опционально можете для каждого запроса без оконных функций сделать вариант запросов с оконными функциями и сравнить их производительность. 