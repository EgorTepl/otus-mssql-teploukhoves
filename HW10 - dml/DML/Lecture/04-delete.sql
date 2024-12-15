---DELETE TOP
USE WideWorldImporters;
select * from Warehouse.Color_Copy;

DELETE TOP(4)
FROM Warehouse.Color_Copy;

--Удаление данных по частям----
DROP TABLE IF EXISTS Warehouse.Color_Copy;
DROP TABLE IF EXISTS Warehouse.Color_Archive;

---Создаем копию с данными----
SELECT * INTO Warehouse.Color_Copy
FROM Warehouse.Colors;

SELECT * FROM Warehouse.Colors;
SELECT * FROM Warehouse.Color_Copy;

declare @table TABLE(ColorID INT);

DELETE FROM Warehouse.Color_Copy
OUTPUT  deleted.ColorID
INTO @table
WHERE ColorID > 16;

SELECT * FROM @table;

---Создаем пустую таблицу на основе ...--
SELECT * INTO Warehouse.Color_Archive
FROM Warehouse.Colors
WHERE 1 = 2;

SELECT * FROM Warehouse.Color_Archive;

--создаем переменные
DECLARE @rowcount INT,
		@batchsize INT = 2;
--начальное значение
SET @rowcount = @batchsize;

--- удаление по частям
WHILE @rowcount = @batchsize
BEGIN
	DELETE top (@batchsize) FROM Warehouse.Color_Copy
		OUTPUT
          deleted.ColorID
        , deleted.ColorName
        , deleted.LastEditedBy
        , deleted.ValidFrom
        , deleted.ValidTo
		INTO Warehouse.Color_Archive
		(
          ColorID
        , ColorName
        , LastEditedBy
        , ValidFrom
        , ValidTo
        )
	SET @rowcount = @@ROWCOUNT;
END;
---Вопросы?----