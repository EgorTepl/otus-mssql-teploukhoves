SELECT COUNT(*)
FROM WideWorldImporters.Sales.InvoiceLines;

---cmd---
--1. CREATE Folder BCP ( 
--------cd E:\Marina\repos\ 
--------mkdir test

--2. bcp WideWorldImporters.Sales.InvoiceLines out ".\test\Copy.txt" -c -T
-- bcp WideWorldImporters.Sales.InvoiceLines out ".\test\Copy.txt" -c -T -S Diabloalex666\SQLEXPRESS
--ls tests
--3. 
--DROP TABLE IF EXISTS WideWorldImporters.Sales.InvoiceLines_Copy;
--SELECT * INTO WideWorldImporters.Sales.InvoiceLines_Copy 
--FROM WideWorldImporters.Sales.InvoiceLines
--WHERE 1 = 2; 
--4. bcp WideWorldImporters.Sales.InvoiceLines_Copy IN ".\test\Copy.txt" -T -S Diabloalex666\SQLEXPRESS -c
--SELECT *
--FROM WideWorldImporters.Sales.InvoiceLines_Copy;

/*
Msg 15281, Level 16, State 1, Procedure master..xp_cmdshell, Line 1 [Batch Start Line 0]
SQL Server blocked access to procedure 'sys.xp_cmdshell' of component 'xp_cmdshell' because this component is turned off as part of the security configuration for this server. 
A system administrator can enable the use of 'xp_cmdshell' by using sp_configure. For more information about enabling 'xp_cmdshell', search for 'xp_cmdshell' in SQL Server Books Online.
*/
-- To allow advanced options to be changed.  
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

--SELECT @@SERVERNAME;

DECLARE @out varchar(250);
set @out = 'bcp WideWorldImporters.Sales.InvoiceLines OUT "E:\BCP\demo.txt" -T -c -S ' + @@SERVERNAME;
PRINT @out;

EXEC master..xp_cmdshell @out

DROP TABLE IF EXISTS WideWorldImporters.Sales.InvoiceLines_Copy;
SELECT * INTO WideWorldImporters.Sales.InvoiceLines_Copy
FROM WideWorldImporters.Sales.InvoiceLines
WHERE 1 = 2; 


DECLARE @in varchar(250);
set @in = 'bcp WideWorldImporters.Sales.InvoiceLines_Copy IN "E:\BCP\demo.txt" -T -c -S ' + @@SERVERNAME;

EXEC master..xp_cmdshell @in;

SELECT *
FROM WideWorldImporters.Sales.InvoiceLines_Copy;