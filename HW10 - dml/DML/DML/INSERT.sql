USE WideWorldImporters;

SELECT *
FROM Warehouse.Colors;

INSERT INTO Warehouse.Colors
	( ColorId
    , ColorName
    , LastEditedBy)
VALUES
	(NEXT VALUE FOR Sequences.ColorID
    , N'Серобуромалиновый'
    , 1);

SELECT *
FROM Application.Countries;

INSERT INTO Application.Countries
    ( CountryID
    , CountryName
    , FormalName
    , IsoAlpha3Code
    , IsoNumericCode
    , CountryType
    , LatestRecordedPopulation
    , Continent
    , Region
    , Subregion
    , LastEditedBy)
VALUES
    ( NEXT VALUE FOR Sequences.CountryID
    , N'Луна'
    , N'Спутник планеты Земля'
    , 'MON'
    , 895
    , 'UN Member State'
    , 0
    , N'Вне Земли'
    , N'Вне Земли'
    , N'Вне Земли'
    , 1);

DECLARE 
	@colorId INT, 
	@LastEditedBySystemUser INT,
	@SystemUserName NVARCHAR(50) = 'Data Conversion Only'
		
SET @colorId = NEXT VALUE FOR Sequences.ColorID;

SELECT @LastEditedBySystemUser = PersonID
FROM [Application].People
WHERE FullName = @SystemUserName;

INSERT INTO Warehouse.Colors
	(ColorId, ColorName, LastEditedBy)
VALUES
	(@colorId, N'Фиолетовый', @LastEditedBySystemUser);

SELECT ColorId, ColorName, LastEditedBy INTO Warehouse.Color_Copy 
FROM Warehouse.Colors
WHERE 1 = 2;

select * from Warehouse.Color_Copy;
DROP TABLE if exists Warehouse.Color_Copy;

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
        ,N'Синий'
        , 1), 
		(NEXT VALUE FOR Sequences.ColorID
        ,N'Красный'
        , 1);

SELECT @@ROWCOUNT;
------------
DROP TABLE if exists Sales.Invoices_2016;

SELECT TOP 1 * INTO Sales.Invoices_2016
FROM Sales.Invoices
WHERE InvoiceDate >= '2016-01-01' 
	AND InvoiceDate < '2016-12-31';

select * from Sales.Invoices_2016
ORDER BY LastEditedWhen DESC;

-----------------
DELETE FROM  Warehouse.Color_Copy;
INSERT INTO Warehouse.Color_Copy
SELECT TOP(5)
   ColorId
 , ColorName
 , LastEditedBy
FROM Warehouse.Colors
ORDER BY ColorId DESC;

select * from Warehouse.Color_Copy;

---------
INSERT INTO Warehouse.Color_Copy(
   ColorId
 , ColorName
 , LastEditedBy)
EXEC WareHouse.GetColor 7;

---DELETE
DELETE TOP(4)
FROM Warehouse.Color_Copy;