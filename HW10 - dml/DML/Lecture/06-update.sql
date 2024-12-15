USE Example;
DROP TABLE IF EXISTS OrderLines_Copy;

SELECT *
FROM OrderLines;

SELECT * INTO OrderLines_Copy
FROM OrderLines;

SELECT *
FROM OrderLines_Copy;

-----10%------
UPDATE OrderLines_Copy
SET Price *= 1.1; -- price = price + 10% * price

----set min price-----
DELETE FROM OrderLines_Copy;

INSERT INTO OrderLines_Copy
SELECT *
FROM OrderLines;

SELECT *
FROM OrderLines_Copy;

UPDATE OrderLines_Copy
SET Price = 
    (SELECT MIN(Price) FROM OrderLines_Copy)
WHERE ID_Product > 3;

-------TOP
----set new count
UPDATE TOP(3) OrderLines_Copy
SET [Count] += [Count];

-----Вопросы?----