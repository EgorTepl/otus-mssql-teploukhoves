USE Example;
DROP TABLE IF EXISTS TargetTable;
DROP TABLE IF EXISTS SourceTable;

SELECT *
FROM Products
ORDER BY ID;

----Make Target
SELECT * INTO TargetTable
FROM Products;

DELETE FROM TargetTable
WHERE ID IN (4, 5);

SELECT *
FROM TargetTable
ORDER BY ID;

---Make Source
SELECT * INTO SourceTable
FROM Products;

DELETE FROM SourceTable
WHERE ID NOT IN (1, 2, 7);

UPDATE SourceTable
SET [Name] = N'Масло'
WHERE ID = 7;

---SELECT---
SELECT *
FROM TargetTable
ORDER BY ID;
GO
SELECT *
FROM SourceTable
ORDER BY ID;

---MERGE---
MERGE TargetTable AS Target
USING SourceTable AS Source
    ON (Target.ID = Source.ID)
WHEN MATCHED 
    THEN UPDATE 
        SET [Name] = Source.[Name]
WHEN NOT MATCHED 
    THEN INSERT 
        VALUES (Source.ID, Source.[Name])
WHEN NOT MATCHED BY SOURCE
    THEN 
        DELETE
OUTPUT deleted.*, $action, inserted.*;
---Вопросы?---