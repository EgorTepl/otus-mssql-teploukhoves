CREATE TABLE [Warehouse].temp
([ColorID] int, [Name] varchar(25));

--drop TABLE temp;

ALTER TABLE [Warehouse].temp ADD  CONSTRAINT [DF_temp]  DEFAULT (NEXT VALUE FOR [Sequences].[ColorID]) FOR [ColorID]
GO