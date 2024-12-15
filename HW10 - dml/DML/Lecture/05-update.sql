USE WideWorldImporters;
DROP TABLE IF EXISTS Purchasing.Suppliers_Copy;

SELECT 
    s.BankAccountName
  , s.PhoneNumber
  , s.FaxNumber
  , s.SupplierName
INTO Purchasing.Suppliers_Copy
FROM Purchasing.Suppliers s;

SELECT * FROM Purchasing.Suppliers_Copy;

UPDATE Purchasing.Suppliers_Copy
SET PhoneNumber = '+7(495)485-75-47'
WHERE SupplierName LIKE '%Graphic Design Institute%';

UPDATE Purchasing.Suppliers_Copy
SET 
	PhoneNumber = '+7(495) 555-01-02',
	FaxNumber = '+7(495) 555-01-03'
OUTPUT 
    inserted.PhoneNumber as new_phon
  , inserted.FaxNumber as new_fax
  , deleted.PhoneNumber as old_phon
  , deleted.FaxNumber old_fax
WHERE SupplierName LIKE '%Fabrikam%';
---------------------------------------
---Вопросы?---