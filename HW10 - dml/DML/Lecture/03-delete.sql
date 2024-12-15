---DELETE
USE Example;
SELECT *
FROM Products
ORDER BY ID;

DELETE FROM Products
WHERE ID = 6;

USE WideWorldImporters;
DELETE FROM Warehouse.Colors
WHERE ColorName LIKE N'Серобуромалиновый';

DELETE FROM Warehouse.Colors
WHERE ColorName LIKE N'Фиолетовый';

DELETE FROM Warehouse.Colors
WHERE ColorName LIKE N'Синий';

DELETE FROM Warehouse.Colors
WHERE ColorName LIKE N'Красный';
---OR---
DELETE FROM Warehouse.Colors
WHERE ColorName IN (N'Серобуромалиновый', N'Синий', N'Фиолетовый', N'Красный');

SELECT *
FROM Warehouse.Colors;

SELECT * FROM Application.Countries;

DELETE FROM Application.Countries
WHERE CountryName LIKE N'Луна';

---Удаление одинаковых строк из разных таблиц---
---Make table's COPY-------

USE WideWorldImporters;
DROP TABLE IF EXISTS [Application].Countries_Copy;

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

SELECT * FROM [Application].Countries_Copy;

---Add new values to COPY
INSERT INTO [Application].Countries_Copy
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
    , 1),
    (NEXT VALUE FOR Sequences.CountryID
    , N'Фобос'
    , N'Спутник планеты Марс'
    , 'FOB'
    , 896
    , 'UN Member State'
    , 0
    , N'Вне Земли'
    , N'Вне Земли'
    , N'Вне Земли'
    , 1);

--Select INTERSECT
SELECT * FROM [Application].Countries_Copy
WHERE EXISTS (
    SELECT *
	FROM [Application].Countries
	WHERE [Application].Countries_Copy.CountryName =
          [Application].Countries.CountryName);

--DELETE INTERSECT
DELETE FROM [Application].Countries_Copy
WHERE EXISTS (
    SELECT *
	FROM [Application].Countries
	WHERE [Application].Countries_Copy.CountryName = 
          [Application].Countries.CountryName);

 ------------------
 --Такой же результат можно получить:----
 ------------------
SELECT [Countries].CountryName
FROM [Application].Countries_Copy AS [Copy]
INNER JOIN [Application].Countries [Countries]
ON [Countries].CountryName = [Copy].CountryName;


DELETE FROM [Copy]
--SELECT [Countries].CountryName
FROM [Application].Countries_Copy AS [Copy]
INNER JOIN [Application].Countries [Countries]
ON [Countries].CountryName = [Copy].CountryName;

---------------------------------------------
---DELETE Дубликат
--1. SELECT * INTO...
DROP TABLE IF EXISTS [Application].Countries_Copy;

SELECT * INTO [Application].Countries_Copy
FROM [Application].Countries;

--2. INSERT INTO
INSERT INTO [Application].Countries_Copy
SELECT *
FROM [Application].Countries
WHERE CountryID BETWEEN 10 AND 20;

--3. -- наши дубликаты:
SELECT
      CountryID
    , CountryName
    , COUNT(*)
FROM [Application].Countries_Copy
GROUP BY CountryID, CountryName
HAVING COUNT(*) > 1;

--или
SELECT
      CountryID
    , CountryName
    , ROW_NUMBER() OVER (
		PARTITION BY CountryName ORDER BY CountryName) AS N
FROM [Application].Countries_Copy;

--или
WITH Dubl AS
(
    SELECT
          CountryID
        , CountryName
        , ROW_NUMBER() OVER (PARTITION BY CountryName ORDER BY CountryName) AS N
    FROM [Application].Countries_Copy
)
SELECT *
FROM Dubl
WHERE N > 1;

---удаление
WITH Dubl AS
(
    SELECT
          CountryID
        , CountryName
        , ROW_NUMBER() OVER (PARTITION BY CountryName ORDER BY CountryName) AS N
    FROM [Application].Countries_Copy
)
DELETE
FROM Dubl
WHERE N > 1;

---------------

--Вопросы?