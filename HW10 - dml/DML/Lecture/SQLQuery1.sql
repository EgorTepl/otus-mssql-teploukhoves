USE WideWorldImporters;
GO

SELECT *
FROM WideWorldImporters.Warehouse.StockItemTransactions;

SET NOCOUNT ON;

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Warehouse.StockItemTransactions_bcp')
BEGIN
    SELECT * INTO WideWorldImporters.Warehouse.StockItemTransactions_bcp
    FROM WideWorldImporters.Warehouse.StockItemTransactions
    WHERE 1 = 2;

    ALTER TABLE Warehouse.StockItemTransactions_bcp
    ADD CONSTRAINT PK_Warehouse_StockItemTransactions_bcp PRIMARY KEY NONCLUSTERED
    (StockItemTransactionID ASC);
END;

TRUNCATE TABLE WideWorldImporters.Warehouse.StockItemTransactions_bcp;

----
---cmd.exe
--bcp WideWorldImporters.Warehouse.StockItemTransactions out E:\BCP\StockItemTransactions_character.bcp -c -T

--bcp WideWorldImporters.Warehouse.StockItemTransactions_bcp IN D:\BCP\StockItemTransactions_character.bcp -c -T

SELECT * 
FROM WideWorldImporters.Warehouse.StockItemTransactions_bcp;


SELECT * INTO WideWorldImporters.Warehouse.StockItemTransactions_Copy
FROM WideWorldImporters.Warehouse.StockItemTransactions
WHERE 1 = 2;

BULK INSERT [WideWorldImporters].[Warehouse].[Colors_Copy]
    FROM "E:\BCP\WideWorldImporters.Warehouse.Colors.txt"
	WITH 
		(
		BATCHSIZE = 1000,
		DATAFILETYPE = 'char',
		FIELDTERMINATOR = '\t',
		ROWTERMINATOR ='\n',
		KEEPNULLS,
		TABLOCK
		);

