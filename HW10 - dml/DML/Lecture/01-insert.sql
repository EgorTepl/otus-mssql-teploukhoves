USE Example;
DELETE FROM OrderLines;
DELETE FROM Products;

INSERT INTO Products ([ID], [Name]) VALUES
 (1, N'Молоко')
,(2, N'Кефир')
,(3, N'Творог')
,(4, N'Сыр');

SELECT *
FROM Products
ORDER BY ID;

GO
--CONSTRAINT PK
INSERT INTO Products VALUES
 (1, N'Масло');
 GO
 --CONSTRAINT UNIQUE
INSERT INTO Products VALUES
 (5, N'Молоко');
 GO
 --SET VALUE IN NVARCHAR() Field
INSERT INTO Products VALUES
  (5, 'Масло');
  --SELECT
INSERT INTO Products VALUES
  (6, '油');

SELECT *
FROM Products
ORDER BY ID;

INSERT INTO Products VALUES
  (7, N'油');

SELECT *
FROM OrderLines;

INSERT INTO OrderLines VALUES
 (1, 1, 10, GETDATE(), 100)
,(2, 2, 20, GETDATE(), 200)
,(3, 3, 30, GETDATE(), 300)
,(4, 4, 40, GETDATE(), 400)
,(5, 5, 50, GETdATE(), 500);

SELECT o.[ID], p.[Name], o.[Date], o.[Price], o.[Count]
FROM OrderLines o
INNER JOIN Products p
ON p.ID = o.ID_Product;

--FK
INSERT INTO OrderLines VALUES
 (6, 100, 10, GETDATE(), 100);

 