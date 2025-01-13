--Пример использования APPLY при работе с XML(JSON)

declare @xml XML 
SET @xml = 
(SELECT top 100
	Invoices.InvoiceID,
	Invoices.InvoiceDate,
	Invoices.SalespersonPersonID,
	InvoiceLines.InvoiceLineID,
	InvoiceLines.Quantity,
	InvoiceLines.UnitPrice,
	InvoiceLines.TaxAmount
FROM Sales.Invoices 
	JOIN Sales.InvoiceLines 
		ON Invoices.InvoiceID = InvoiceLines.InvoiceID
FOR XML AUTO, Elements, root('invoices'));

select @xml;


select Ids.InvoiceId, 
	InvoiceDate,
	LineId
from @xml.nodes('./invoices') AS invoicesDoc(Invoices)
	cross apply 
		Invoices.nodes('(./Sales.Invoices)') SI(InvoiceEx)
	cross apply 
		(select InvoiceEx.value('(./InvoiceID[1])', 'INT') AS InvoiceId) AS Ids
	cross apply 
		(select InvoiceEx.value('(./InvoiceDate[1])', 'DATE') AS InvoiceDate) AS Dates
	cross apply 
		InvoiceEx.nodes('(./Sales.InvoiceLines)') AS SIL(T)
	cross apply 
		(select T.value('(./InvoiceLineID[1])', 'INT') AS LineId) AS lines;