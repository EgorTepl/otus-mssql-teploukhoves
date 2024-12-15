---SELECT ... INTO-----
USE Example;
DROP TABLE IF EXISTS OrderLines_Copy;

SELECT *
FROM OrderLines;

SELECT * INTO OrderLines_Copy
FROM OrderLines;

SELECT *
FROM OrderLines_Copy;

INSERT INTO OrderLines_Copy VALUES
 (6, 100, 10, GETDATE(), 100);
----------------------
USE WideWorldImporters;
DROP TABLE IF EXISTS [Application].Countries_Copy;

SELECT * FROM [Application].Countries;

SELECT 
      CountryID
    , CountryName
    , FormalName
    , IsoAlpha3Code
    , IsoNumericCode
    , CountryType
    , LatestRecordedPopulation
    , Continent
    , Region
    , Subregion
    , LastEditedBy
INTO [Application].Countries_Copy
FROM [Application].Countries;

SELECT * FROM [Application].Countries;
GO
SELECT * FROM [Application].Countries_Copy;

---SELECT TOP(N) ... INTO-----
USE Example;

--DROP TABLE IF EXISTS OrderLines_Copy;

SELECT TOP(3) * INTO OrderLines_Copy
FROM OrderLines;

SELECT *
FROM OrderLines;
GO
SELECT *
FROM OrderLines_Copy
ORDER BY ID;

---INSERT INTO (Columns)---

INSERT INTO OrderLines_Copy
VALUES
   (1, 2, 10, GETDATE(), 100)
 , (3, 3, 30, GETDATE(), 250)
 , (6, 1, 10, GETDATE(), 100);

-----------------------------------------------------
 ---Выборка по отдельному году в отдельную таблицу----

USE WideWorldImporters;
--DROP TABLE if exists Sales.Invoices_2016;

select * from Sales.Invoices
WHERE InvoiceDate >= '2016-01-01'
	AND InvoiceDate < '2016-12-31'
ORDER BY InvoiceDate;


SELECT TOP 10 * INTO Sales.Invoices_2016
FROM Sales.Invoices
WHERE InvoiceDate >= '2016-01-01'
	AND InvoiceDate < '2016-12-31';

select * from Sales.Invoices_2016;

--------------------------
---OUTPUT AND ROWCOUNT-----------
-------------------------
USE WideWorldImporters;

INSERT INTO Warehouse.Colors
		( ColorId
        , ColorName
        , LastEditedBy)
	OUTPUT inserted.*
VALUES
		(NEXT VALUE FOR Sequences.ColorID
        , N'Синий'
        , 1), 
		(NEXT VALUE FOR Sequences.ColorID
        , N'Красный'
        , 1);

SELECT @@ROWCOUNT;

--DROP TABLE if exists Warehouse.Color_Copy;

--DELETE FROM Warehouse.Colors
--WHERE ColorId > 36;

------Логирование------

SELECT ColorId, ColorName, LastEditedBy INTO Warehouse.Color_Copy
FROM Warehouse.Colors
WHERE 1 = 2;

select * from Warehouse.Color_Copy;

INSERT INTO Warehouse.Colors
		( ColorId
        , ColorName
        , LastEditedBy)
	   OUTPUT 
           inserted.ColorId
         , inserted.ColorName
         , inserted.LastEditedBy
		INTO Warehouse.Color_Copy (
            ColorId
          , ColorName
          , LastEditedBy)
	OUTPUT inserted.*
VALUES
		(NEXT VALUE FOR Sequences.ColorID
        , N'Синий'
        , 1), 
		(NEXT VALUE FOR Sequences.ColorID
        , N'Красный'
        , 1);

SELECT @@ROWCOUNT;

select * from Warehouse.Colors;
------------
----INSERT INTO.. FROM QUERY
USE WideWorldImporters;

--DROP TABLE if exists Warehouse.Color_Copy;
SELECT ColorId, ColorName, LastEditedBy INTO Warehouse.Color_Copy
FROM Warehouse.Colors
WHERE 1 = 2;

INSERT INTO Warehouse.Color_Copy
SELECT TOP(5)
   ColorId
 , ColorName
 , LastEditedBy
FROM Warehouse.Colors
ORDER BY ColorId DESC;

select * from Warehouse.Color_Copy;

-----INSERT INTO.. FROM PROC
--DROP TABLE if exists Warehouse.Color_Copy;
SELECT ColorId, ColorName, LastEditedBy INTO Warehouse.Color_Copy
FROM Warehouse.Colors
WHERE 1 = 2;

INSERT INTO Warehouse.Color_Copy(
   ColorId
 , ColorName
 , LastEditedBy)
EXEC WareHouse.GetColor 7;
------
--ВОПРОСЫ?







--DELETE
--FROM WareHouse.Colors
--WHERE ColorName IN ('Светло-Синий', 'Темно-Красный');