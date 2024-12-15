USE WideWorldImporters;

---INSERT INTO---
SELECT *
FROM Warehouse.Colors;
--DELETE FROM Warehouse.Colors WHERE ColorID > 36;

INSERT INTO Warehouse.Colors
	( ColorId
    , ColorName
    , LastEditedBy)
VALUES
	(NEXT VALUE FOR Sequences.ColorID
    , N'Серобуромалиновый'
    , 1);

INSERT INTO Warehouse.Colors
	(  ColorName
    , LastEditedBy)
VALUES
	(
     N'темно-ф'
    , 1);

SELECT *
FROM [Application].Countries;

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

----USING Varibles
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

--ВОПРОСЫ?----