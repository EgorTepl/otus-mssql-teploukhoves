/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
	YEAR(inv.InvoiceDate) AS InvoiceYear,
	MONTH(inv.InvoiceDate) AS InvoiceMonth,
	AVG(invLine.UnitPrice) AS AveragePrice,
	SUM(invLine.UnitPrice * invLine.Quantity) AS SalesAmount
FROM sales.InvoiceLines AS invLine
INNER jOIN Sales.Invoices AS inv
	ON invLine.InvoiceID = inv.InvoiceID
GROUP BY
	YEAR(inv.InvoiceDate),
	MONTH(inv.InvoiceDate)
ORDER BY
	YEAR(inv.InvoiceDate),
	MONTH(inv.InvoiceDate);

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
	YEAR(inv.InvoiceDate) AS InvoiceYear,
	MONTH(inv.InvoiceDate) AS InvoiceMonth,	
	SUM(invLine.UnitPrice * invLine.Quantity) AS SalesAmount
FROM sales.InvoiceLines AS invLine
INNER jOIN Sales.Invoices AS inv
	ON invLine.InvoiceID = inv.InvoiceID
GROUP BY
	YEAR(inv.InvoiceDate),
	MONTH(inv.InvoiceDate)
HAVING SUM(invLine.UnitPrice * invLine.Quantity) > 4600000
ORDER BY
	YEAR(inv.InvoiceDate),
	MONTH(inv.InvoiceDate);

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT
	YEAR(inv.InvoiceDate) AS InvoiceYear,
	MONTH(inv.InvoiceDate) AS InvoiceMonth,	
	item.StockItemName,
	SUM(invLine.UnitPrice * invLine.Quantity) AS SalesAmount,
	MIN(inv.InvoiceDate) AS FirstInvoiceDate,
	SUM(invLine.Quantity) AS Quantity
FROM sales.InvoiceLines AS invLine
INNER jOIN Sales.Invoices AS inv
	ON invLine.InvoiceID = inv.InvoiceID
INNER jOIN Warehouse.StockItems AS item
	ON invLine.StockItemID = item.StockItemID
GROUP BY
	YEAR(inv.InvoiceDate),
	MONTH(inv.InvoiceDate),
	item.StockItemName
HAVING SUM(invLine.Quantity) < 50
ORDER BY
	YEAR(inv.InvoiceDate),
	MONTH(inv.InvoiceDate);

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/

-- Создаём временную таблицу для хранения календаря по дате продажи (sales.InvoiceLines).InvoiceDate по значению год-месяц,
-- со сквозной (без пропусков) нумерацией лет и месяцев
DROP TABLE IF EXISTS #YearMonthCalendar
CREATE TABLE #YearMonthCalendar (_year int, _month int)

-- Опредеяем минимальную и максимальную даты продаж для заполнения календаря #YearMonthCalendar
DECLARE
	@minInvoiceDate date = (SELECT MIN(inv.InvoiceDate) FROM Sales.Invoices AS inv),
	-- К максимальной дате добавим 2 месяца (в которых не будет продаж) для тестирования результатов
	@maxInvoiceDate date = (SELECT DATEADD(MONTH, 2, (SELECT MAX(inv.InvoiceDate) FROM Sales.Invoices AS inv))),
	@dateToInsertIntoTempTable date

-- Заполнение календаря #YearMonthCalendar
SET @dateToInsertIntoTempTable = @minInvoiceDate

WHILE @dateToInsertIntoTempTable < @maxInvoiceDate
BEGIN
	INSERT INTO #YearMonthCalendar (_year, _month)
	VALUES (YEAR(@dateToInsertIntoTempTable), MONTH(@dateToInsertIntoTempTable))

	SET @dateToInsertIntoTempTable = DATEADD(MONTH, 1, @dateToInsertIntoTempTable)
END

--SELECT * FROM #YearMonthCalendar

-- Создаём временную таблицу для хранения фактической даты продажи (sales.InvoiceLines).InvoiceDate в виде пары год-месяц.
-- Нумерация несквозная, только фактическая дата продажи
DROP TABLE IF EXISTS #YearMonthInvoiceDate
CREATE TABLE #YearMonthInvoiceDate (InvoiceYear int, InvoiceMonth int)

-- Заполнение временной таблицы #YearMonthInvoiceDate для хранения фактических дат продаж
INSERT INTO #YearMonthInvoiceDate (InvoiceYear, InvoiceMonth)
SELECT
	YEAR(inv.InvoiceDate) AS InvoiceYear,
	MONTH(inv.InvoiceDate) AS InvoiceMonth
FROM Sales.Invoices AS inv
GROUP BY
	YEAR(inv.InvoiceDate),
	MONTH(inv.InvoiceDate)

--SELECT * FROM #InvoiceSalesAmount

-- 2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000
SELECT
	YEAR(inv.InvoiceDate) AS InvoiceYear,
	MONTH(inv.InvoiceDate) AS InvoiceMonth,	
	SUM(invLine.UnitPrice * invLine.Quantity) AS SalesAmount
FROM sales.InvoiceLines AS invLine
INNER jOIN Sales.Invoices AS inv
	ON invLine.InvoiceID = inv.InvoiceID
GROUP BY
	YEAR(inv.InvoiceDate),
	MONTH(inv.InvoiceDate)
HAVING SUM(invLine.UnitPrice * invLine.Quantity) > 4600000

UNION ALL

SELECT
	calen._year,
	calen._month,
	0 AS SalesAmount
FROM #YearMonthCalendar AS calen
WHERE NOT EXISTS
(
	SELECT 1
	FROM #YearMonthInvoiceDate AS salAm
	WHERE (salAm.InvoiceYear = calen._year) AND (salAm.InvoiceMonth = calen._month)
);

/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.
*/

SELECT
	YEAR(inv.InvoiceDate) AS InvoiceYear,
	MONTH(inv.InvoiceDate) AS InvoiceMonth,	
	item.StockItemName,
	SUM(invLine.UnitPrice * invLine.Quantity) AS SalesAmount,
	MIN(inv.InvoiceDate) AS FirstInvoiceDate,
	SUM(invLine.Quantity) AS Quantity
FROM sales.InvoiceLines AS invLine
INNER jOIN Sales.Invoices AS inv
	ON invLine.InvoiceID = inv.InvoiceID
INNER jOIN Warehouse.StockItems AS item
	ON invLine.StockItemID = item.StockItemID
GROUP BY
	YEAR(inv.InvoiceDate),
	MONTH(inv.InvoiceDate),
	item.StockItemName
HAVING SUM(invLine.Quantity) < 50

UNION ALL

SELECT
	calen._year,
	calen._month,
	N'' AS StockItemName,
	0 AS SalesAmount,
	'' AS FirstInvoiceDate,
	0 AS Quantity
FROM #YearMonthCalendar AS calen
WHERE NOT EXISTS
(
	SELECT 1
	FROM #YearMonthInvoiceDate AS salAm
	WHERE (salAm.InvoiceYear = calen._year) AND (salAm.InvoiceMonth = calen._month)
);