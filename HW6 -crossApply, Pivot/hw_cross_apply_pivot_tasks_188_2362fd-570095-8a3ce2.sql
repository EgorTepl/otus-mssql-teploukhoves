/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

SELECT
	InvoiceMonth,
	[Sylvanite, MT],
	[Peeples Valley, AZ],
	[Medicine Lodge, KS],
	[Gasport, NY],
	[Jessie, ND]
FROM
(
	SELECT
		inv.InvoiceID,
		CONVERT
		(
			NVARCHAR(10),
			DATEADD(MONTH, DATEDIFF(MONTH, 0, inv.InvoiceDate), 0),
			104
		) AS InvoiceMonth,
		CustomerName.CustomerName
	FROM sales.Invoices AS inv
	CROSS APPLY
	(
		SELECT
			SUBSTRING
			(
				cust.CustomerName,
				CHARINDEX('(', cust.CustomerName) + 1,
				CHARINDEX(')', cust.CustomerName) - CHARINDEX('(', cust.CustomerName) - 1
			) AS CustomerName
		FROM Sales.Customers AS cust
		WHERE
			(cust.CustomerID BETWEEN 2 AND 6)
			AND (cust.CustomerID = inv.CustomerID)
	) as CustomerName
) AS Source
PIVOT 
(
	COUNT(InvoiceID)
	FOR CustomerName
	IN ([Sylvanite, MT], [Peeples Valley, AZ], [Medicine Lodge, KS], [Gasport, NY], [Jessie, ND])
) AS PivotTable
ORDER BY InvoiceMonth;

/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

SELECT
	cust.CustomerName,
	cr.DeliveryAddressLine1 AS AddressLine
FROM Sales.Customers AS cust
CROSS JOIN
(
	SELECT
		cust.DeliveryAddressLine1
	FROM Sales.Customers AS cust

	UNION

	SELECT
		cust.DeliveryAddressLine2
	FROM Sales.Customers AS cust

	UNION

	SELECT
		cust.PostalAddressLine1
	FROM Sales.Customers AS cust

	UNION

	SELECT
		cust.PostalAddressLine2
	FROM Sales.Customers AS cust	
) AS cr
WHERE cust.CustomerName LIKE 'Tailspin Toys%';

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

SELECT
	countr.CountryID,
	countr.CountryName,
	countrByIsoAlpha3Code.IsoAlpha3Code AS Code
FROM Application.Countries AS countr
CROSS APPLY
(
	SELECT Countries.IsoAlpha3Code
	FROM Application.Countries
	WHERE countr.CountryID = Countries.CountryID

	UNION

	SELECT CAST(Countries.IsoNumericCode AS nvarchar(10))
	FROM Application.Countries
	WHERE countr.CountryID = Countries.CountryID
) AS countrByIsoAlpha3Code;

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT
	cust.CustomerID,
	cust.CustomerName,
	CustomerInvoices.StockItemID,
	CustomerInvoices.UnitPrice,
	CustomerInvoices.InvoiceDate
FROM Sales.Customers AS cust
CROSS APPLY
(
	SELECT TOP 2 WITH TIES
		invLine.StockItemID,
		invLine.UnitPrice,
		inv.InvoiceDate
	FROM Sales.InvoiceLines AS invLine
	JOIN Sales.Invoices AS inv
		ON invLine.InvoiceID = inv.InvoiceID
	WHERE inv.CustomerID = cust.CustomerID
	ORDER BY
		invLine.UnitPrice DESC
) AS CustomerInvoices;