/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "10 - Операторы изменения данных".

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

DECLARE @MaxCustumerId INT = (SELECT MAX(CustomerID) FROM Sales.Customers)
DECLARE @CustomerId INT;
DECLARE @InsertedRowsCounter INT = 0
-- Дамми переменные для заполнения обязательных полей
DECLARE @BillToCustomerID INT = 1061,
		@CustomerCategoryID INT = 5,
		@PrimaryContactPersonID INT = 3261,
		@DeliveryMethodID INT = 3,
		@DeliveryCityID INT = 19881,
		@PostalCityID INT = 19881,
		@AccountOpenedDate DATE = '2016-05-07',
		@StandardDiscountPercentage DECIMAL(18, 3) = '0.000',
		@IsStatementSent BIT = 0,
		@IsOnCreditHold BIT = 0,
		@PaymentDays INT = 7,
		@PhoneNumber NVARCHAR(20) = '(206) 555-0100',
		@FaxNumber NVARCHAR(20) = '(206) 555-0101',
		@WebsiteURL NVARCHAR(256) = 'http://www.microsoft.com/',
		@DeliveryAddressLine1 NVARCHAR(60) = 'Shop 12',
		@DeliveryPostalCode NVARCHAR(10) = '90243',
		@PostalAddressLine1 NVARCHAR(60) = 'PO Box 8112',
		@PostalPostalCode NVARCHAR(10) = '90243',
		@LastEditedBy INT = 1,
		@ValidFrom DATETIME2(7) = GETDATE(),
		@ValidTo DATETIME2(7) = GETDATE()
-- Создадим временную таблицу для того, чтобы не нарушать целостность данных хранилища
DROP TABLE IF EXISTS #CustomersTemp
SELECT *
INTO #CustomersTemp
FROM Sales.Customers

WHILE(@InsertedRowsCounter < 5)
BEGIN
	SET @InsertedRowsCounter = @InsertedRowsCounter + 1
	SET @CustomerId = @MaxCustumerId + @InsertedRowsCounter

	INSERT INTO #CustomersTemp
	(
		CustomerID,
		CustomerName,
		BillToCustomerID,
		CustomerCategoryID,
		PrimaryContactPersonID,
		DeliveryMethodID,
		DeliveryCityID,
		PostalCityID,
		AccountOpenedDate,
		StandardDiscountPercentage,
		IsStatementSent,
		IsOnCreditHold,
		PaymentDays,
		PhoneNumber,
		FaxNumber,
		WebsiteURL,
		DeliveryAddressLine1,
		DeliveryPostalCode,
		PostalAddressLine1,
		PostalPostalCode,
		LastEditedBy,
		ValidFrom,
		ValidTo
	)
	VALUES
	(
		NEXT VALUE FOR Sequences.CustomerID,
		CONCAT('InsertedRow', CAST(@CustomerId AS nvarchar)),
		@BillToCustomerID,
		@CustomerCategoryID,
		@PrimaryContactPersonID,
		@DeliveryMethodID,
		@DeliveryCityID,
		@PostalCityID,
		@AccountOpenedDate,
		@StandardDiscountPercentage,
		@IsStatementSent,
		@IsOnCreditHold,
		@PaymentDays,
		@PhoneNumber,
		@FaxNumber,
		@WebsiteURL,
		@DeliveryAddressLine1,
		@DeliveryPostalCode,
		@PostalAddressLine1,
		@PostalPostalCode,
		@LastEditedBy,
		@ValidFrom,
		@ValidTo
	)
END

SELECT *
FROM #CustomersTemp
ORDER BY CustomerID

/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM #CustomersTemp
WHERE CustomerName = N'InsertedRow1062'


/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE #CustomersTemp
SET CustomerName = N'ValueToUpdate'
WHERE CustomerName = N'InsertedRow1063'

/*
4. Написать MERGE, который вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

DROP TABLE IF EXISTS #CustomersForMerging
SELECT * INTO #CustomersForMerging
FROM sales.Customers

;WITH CustomersSourceCTE AS
(
	-- Селект для операции вставки в таблицу #CustomersForMerging
	SELECT
		cust.CustomerID + 1 AS CustomerId,
		N'ValueToInsertByMergeOperator' AS CustomerName,
		BillToCustomerID,
		CustomerCategoryID,
		PrimaryContactPersonID,
		DeliveryMethodID,
		DeliveryCityID,
		PostalCityID,
		AccountOpenedDate,
		StandardDiscountPercentage,
		IsStatementSent,
		IsOnCreditHold,
		PaymentDays,
		PhoneNumber,
		FaxNumber,
		WebsiteURL,
		DeliveryAddressLine1,
		DeliveryPostalCode,
		PostalAddressLine1,
		PostalPostalCode,
		LastEditedBy,
		ValidFrom,
		ValidTo
	FROM #CustomersForMerging AS cust
	WHERE cust.CustomerID = (SELECT MAX(CustomerID) FROM #CustomersForMerging)	

	UNION ALL
	-- Селект для операции обновления данных в таблице #CustomersForMerging
	SELECT
		cust.CustomerID,
		N'ValueToUpdateByMergeOperator' AS CustomerName,
		BillToCustomerID,
		CustomerCategoryID,
		PrimaryContactPersonID,
		DeliveryMethodID,
		DeliveryCityID,
		PostalCityID,
		AccountOpenedDate,
		StandardDiscountPercentage,
		IsStatementSent,
		IsOnCreditHold,
		PaymentDays,
		PhoneNumber,
		FaxNumber,
		WebsiteURL,
		DeliveryAddressLine1,
		DeliveryPostalCode,
		PostalAddressLine1,
		PostalPostalCode,
		LastEditedBy,
		ValidFrom,
		ValidTo
	FROM #CustomersForMerging AS cust
	WHERE cust.CustomerID = (SELECT MAX(CustomerID) FROM #CustomersForMerging)
)

MERGE #CustomersForMerging AS target
USING CustomersSourceCTE AS source
	ON target.CustomerID = source.CustomerId
WHEN MATCHED
	THEN UPDATE
		SET target.CustomerName = source.CustomerName
WHEN NOT MATCHED
	THEN INSERT
		(
			CustomerID,
			CustomerName,	
			BillToCustomerID,
			CustomerCategoryID,
			PrimaryContactPersonID,
			DeliveryMethodID,
			DeliveryCityID,
			PostalCityID,
			AccountOpenedDate,
			StandardDiscountPercentage,
			IsStatementSent,
			IsOnCreditHold,
			PaymentDays,
			PhoneNumber,
			FaxNumber,
			WebsiteURL,
			DeliveryAddressLine1,
			DeliveryPostalCode,
			PostalAddressLine1,
			PostalPostalCode,
			LastEditedBy,
			ValidFrom,
			ValidTo
		)
		VALUES
		(
			CustomerID,
			CustomerName,
			BillToCustomerID,
			CustomerCategoryID,
			PrimaryContactPersonID,
			DeliveryMethodID,
			DeliveryCityID,
			PostalCityID,
			AccountOpenedDate,
			StandardDiscountPercentage,
			IsStatementSent,
			IsOnCreditHold,
			PaymentDays,
			PhoneNumber,
			FaxNumber,
			WebsiteURL,
			DeliveryAddressLine1,
			DeliveryPostalCode,
			PostalAddressLine1,
			PostalPostalCode,
			LastEditedBy,
			ValidFrom,
			ValidTo
		);

SELECT *
FROM #CustomersForMerging
ORDER BY CustomerID

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/
-- Копирование данных из таблицы Sales.Customers в файл с форматом .txt с именем "Customers"
-- bcp WideWorldImporters.Sales.Customers out ".\bcpExportCustomersToTxtFile\Customers.txt" -c -T

-- Импорт данных из файла Customers.txt в таблицу Sales.CustomersCopy базы данных WideWorldImporters
DROP TABLE IF EXISTS WideWorldImporters.Sales.CustomersCopy
SELECT * INTO WideWorldImporters.Sales.CustomersCopy
FROM WideWorldImporters.Sales.Customers
WHERE 1 = 2

BULK INSERT WideWorldImporters.Sales.CustomersCopy
	FROM 'D:\MyProjects\otus-mssql-teploukhoves\HW10 - dml\bcpExportCustomersToTxtFile\Customers.txt'

SELECT *
FROM WideWorldImporters.Sales.CustomersCopy