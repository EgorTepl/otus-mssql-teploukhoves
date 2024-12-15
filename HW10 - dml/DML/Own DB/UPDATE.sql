---10%
UPDATE OrderLines
SET Price *= 1.1;

DELETE FROM OrderLines;

SELECT *
FROM Products;

DELETE FROM Products
WHERE ID = 6;

SELECT *
FROM OrderLines;

--- set min price
UPDATE OrderLines
SET Price = 
    (SELECT MIN(Price) FROM OrderLines)
WHERE ID_Product > 3;

-------TOP
UPDATE TOP(3) OrderLines
SET [Count] += [Count];

--DROP TABLE OrderLines;
--DROP TABLE Products;