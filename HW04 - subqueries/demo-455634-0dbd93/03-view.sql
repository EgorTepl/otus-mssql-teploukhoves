DROP VIEW IF EXISTS Website.CustomerDelivery
Go 

CREATE VIEW Website.CustomerDelivery
AS
SELECT s.CustomerID, s.CustomerName, s.PhoneNumber, s.FaxNumber, s.WebsiteURL, c.CityName AS CityName, s.DeliveryLocation AS DeliveryLocation, s.DeliveryRun, s.RunPosition
FROM Sales.Customers AS s
LEFT OUTER JOIN Application.Cities AS c ON s.DeliveryCityID = c.CityID
GO

SELECT *
FROM Website.CustomerDelivery
order by CustomerID


-- view с подзапросом
DROP VIEW IF EXISTS Website.SalesManager
Go 

CREATE VIEW Website.SalesManager 
AS
SELECT s.PersonID,
       s.FullName,      
       s.PhoneNumber,
       s.FaxNumber,                
       (SELECT COUNT(*)
	   FROM Sales.Orders
	   WHERE SalespersonPersonID = s.PersonID) AS AmountOfSales
FROM Application.People AS s
WHERE s.IsSalesperson = 1
GO
select * 
FROM Website.SalesManager


-- view с прив€зкой к схеме
DROP VIEW IF EXISTS Website.SalesManagerIX
Go 

CREATE VIEW Website.SalesManagerIX 
WITH SCHEMABINDING
AS
SELECT s.PersonID,
       s.FullName,      
       s.PhoneNumber,
       s.FaxNumber
	   --, (SELECT COUNT(*) FROM Sales.Orders WHERE SalespersonPersonID = s.PersonID) AS AmountOfSales
FROM Application.People AS s
WHERE s.IsSalesperson = 1	
GO

-- error
alter table Application.People add FullName nvarchar(300)

-- материализованное view (индекс будет хранитс€ на диске)
-- подзапросы невозможны
CREATE UNIQUE CLUSTERED INDEX IXV_WebsiteSalesManager ON Website.SalesManagerIX (PersonID)
GO

-- планы - индекс не используетс€ (Ctrl + M)
SELECT * FROM Website.SalesManager WHERE PersonID = 7
SELECT * FROM Website.SalesManagerIX WHERE PersonID = 7
SELECT * FROM Website.SalesManagerIX with (noexpand) WHERE PersonID = 7

GO
