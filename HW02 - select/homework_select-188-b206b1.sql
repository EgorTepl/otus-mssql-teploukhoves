/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, JOIN".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД WideWorldImporters можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT
	itm.StockItemID,
	itm.StockItemName
FROM Warehouse.StockItems AS itm -- товары на складе
WHERE
	itm.StockItemName LIKE '%urgent%'
	OR itm.StockItemName LIKE 'Animal%';

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT
	suppl.SupplierID,
	suppl.SupplierName
FROM Purchasing.Suppliers AS suppl -- Поставщики
LEFT JOIN Purchasing.PurchaseOrders AS purchOrd -- Заказы на закупку
	ON suppl.SupplierID = purchOrd.SupplierID
WHERE purchOrd.SupplierID IS NULL;

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$ 
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

-- Вариант без постраничной выборки
SELECT
	ord.OrderID,
	FORMAT(ord.OrderDate, 'dd.MM.yyyy') AS OrderDate,
	FORMAT(ord.OrderDate, 'MMMM', 'ru-ru') AS OrderMonthName,
	DATEPART(QUARTER, ord.OrderDate) AS OrderQuarterNumber,
	CASE
		WHEN MONTH(ord.OrderDate) BETWEEN 1 AND 4
		 THEN 1
		WHEN MONTH(ord.OrderDate) BETWEEN 5 AND 8
		 THEN 2
		WHEN MONTH(ord.OrderDate) BETWEEN 9 AND 12
		 THEN 3
		END AS OrderThirdOfTheYear,
	cust.CustomerName
FROM sales.OrderLines AS ordLine -- Строки заказов
INNER JOIN sales.Orders AS ord -- Заказы
	ON ordLine.OrderID = ord.OrderID
INNER JOIN Sales.Customers AS cust -- Клиенты
	ON ord.CustomerID = cust.CustomerID
WHERE
	(ordLine.UnitPrice > 100
	 OR ordLine.Quantity > 20)
	AND ordLine.PickingCompletedWhen IS NOT NULL;

-- Вариант с постраничной выборки
DECLARE
	@numberOfRowsToSkip BIGINT = 1000, -- Количество строк для пропуска
	@numberOfRowsToFetch BIGINT = 100;-- Количество строк для извлечения

;WITH OrderInfo AS
(
	SELECT
		ord.OrderID,
		FORMAT(ord.OrderDate, 'dd.MM.yyyy') AS OrderDate,
		FORMAT(ord.OrderDate, 'MMMM', 'ru-ru') AS OrderMonthName,
		DATEPART(QUARTER, ord.OrderDate) AS OrderQuarterNumber,
		CASE
			WHEN MONTH(ord.OrderDate) BETWEEN 1 AND 4
			 THEN 1
			WHEN MONTH(ord.OrderDate) BETWEEN 5 AND 8
			 THEN 2
			WHEN MONTH(ord.OrderDate) BETWEEN 9 AND 12
			 THEN 3
			END AS OrderThirdOfTheYear,
		cust.CustomerName
	FROM sales.OrderLines AS ordLine -- Строки заказов
	INNER JOIN sales.Orders AS ord -- Заказы
		ON ordLine.OrderID = ord.OrderID
	INNER JOIN Sales.Customers AS cust -- Клиенты
		ON ord.CustomerID = cust.CustomerID
	WHERE
		(ordLine.UnitPrice > 100
		 OR ordLine.Quantity > 20)
		AND ordLine.PickingCompletedWhen IS NOT NULL
)

SELECT *
FROM OrderInfo AS orders
ORDER BY
	orders.OrderQuarterNumber ASC,
	orders.OrderThirdOfTheYear ASC,
	orders.OrderDate ASC
OFFSET @numberOfRowsToSkip ROWS
FETCH NEXT @numberOfRowsToFetch ROWS ONLY;

/*
4. Заказы поставщикам (Purchasing.Suppliers),
которые должны быть исполнены (ExpectedDeliveryDate) в январе 2013 года
с доставкой "Air Freight" или "Refrigerated Air Freight" (DeliveryMethodName)
и которые исполнены (IsOrderFinalized).
Вывести:
* способ доставки (DeliveryMethodName)
* дата доставки (ExpectedDeliveryDate)
* имя поставщика
* имя контактного лица принимавшего заказ (ContactPerson)

Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders, Application.DeliveryMethods, Application.People.
*/

SELECT
	delMeth.DeliveryMethodName,
	pOrd.ExpectedDeliveryDate,
	sup.SupplierName,
	peop.FullName AS ContactPersonFullName
FROM Purchasing.PurchaseOrders AS pOrd -- Заказы на покупку
INNER JOIN Purchasing.Suppliers AS sup -- Поставщики
	ON pOrd.SupplierID = sup.SupplierID
INNER JOIN Application.DeliveryMethods AS delMeth -- Способы доставки
	ON pOrd.DeliveryMethodID = delMeth.DeliveryMethodID
INNER JOIN Application.People AS peop -- Пользователи
	ON pOrd.ContactPersonID = peop.PersonID
WHERE
	pOrd.IsOrderFinalized = 1
	AND delMeth.DeliveryMethodName IN ('Air Freight', 'Refrigerated Air Freight')
	AND (MONTH(pOrd.ExpectedDeliveryDate) = 1
	 AND YEAR(pOrd.ExpectedDeliveryDate) = 2013);
	
/*
5. Десять последних продаж (по дате продажи) с именем клиента и именем сотрудника,
который оформил заказ (SalespersonPerson).
Сделать без подзапросов.
*/

SELECT TOP 10
	cust.CustomerName,
	peop.FullName AS SalesPersonFullName
FROM sales.Invoices AS inv -- Накладные
INNER JOIN Application.People AS peop -- Пользователи
	ON inv.SalespersonPersonID = peop.PersonID
INNER JOIN Sales.Orders AS ord -- Заказы клиентов
	ON inv.OrderID = ord.OrderID
INNER JOIN Sales.Customers AS cust -- Клиенты
	ON ord.CustomerID = cust.CustomerID
ORDER BY ord.OrderDate DESC;

/*
6. Все ид и имена клиентов и их контактные телефоны,
которые покупали товар "Chocolate frogs 250g".
Имя товара смотреть в таблице Warehouse.StockItems.
*/

SELECT
	cust.CustomerID,
	cust.CustomerName,
	cust.PhoneNumber	
FROM sales.OrderLines AS ordLines -- Строки заказов клиентов
INNER JOIN Sales.Orders AS ord -- Заказы клиентов
	ON ordLines.OrderID = ord.OrderID
INNER JOIN Warehouse.StockItems AS itm -- товары на складе
	ON ordLines.StockItemID = itm.StockItemID
INNER JOIN Sales.Customers AS cust -- Клиенты
	ON ord.CustomerID = cust.CustomerID
WHERE itm.StockItemName = 'Chocolate frogs 250g';