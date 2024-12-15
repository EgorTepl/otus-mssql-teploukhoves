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

UPDATE TargetTable
SET [Name] = N'Масло'
WHERE ID = 7;

---Make Source
SELECT * INTO SourceTable
FROM Products;

DELETE FROM SourceTable
WHERE ID NOT IN (1, 2, 7);

---SElECT
SELECT *
FROM TargetTable
ORDER BY ID;
GO
SELECT *
FROM SourceTable
ORDER BY ID;