SELECT *
FROM OrderLines;

SELECT *
FROM Products;

DELETE FROM Products
WHERE ID = 6;

INSERT INTO OrderLines VALUES
 (1, 1, 10, GETDATE(), 100)
,(2, 2, 20, GETDATE(), 200)
,(3, 3, 30, GETDATE(), 300)
,(4, 4, 40, GETDATE(), 400)
,(5, 5, 50, GETdATE(), 500);

--FK
INSERT INTO OrderLines VALUES
 (6, 100, 10, GETDATE(), 100);
 ----

 SELECT TOP(3) * INTO OrderLines_Copy
 FROM OrderLines;

 INSERT INTO OrderLines_Copy
 VALUES
   (1, 2, 10, GETDATE(), 100)
 , (3, 3, 30, GETDATE(), 250)
 , (6, 1, 10, GETDATE(), 100);

 CREATE TABLE Total
 (
    ID INT
  , TotalSum MONEY
  , TotalCount INT
  , ProductName NVARCHAR(25)
 );
 SELECT * FROM Total;
 TRUNCATE TABLE Total;
 --DROP TABLE Total;

 MERGE Total AS target
 USING
 (
    SELECT 
           COUNT(o.ID)
         , COUNT(o.[Count])
         , SUM(o.Price)
         , p.[Name]
    FROM OrderLines o
    INNER JOIN Products p ON p.ID = o.ID
    GROUP BY p.[Name]
 )