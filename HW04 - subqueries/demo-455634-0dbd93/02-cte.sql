--------------------
-- cte
-- подзапрос - продажи сотрудников
SELECT P.PersonID, P.FullName, I.SalesCount
FROM Application.People AS P
JOIN (
	SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20140101' AND InvoiceDate < '20150101'
	GROUP BY SalespersonPersonID
	) AS I ON P.PersonID = I.SalespersonPersonID

-- cte (не забыть про ;)
-- имя InvoicesCTE [(список колонок)]
; WITH InvoicesCTE (SalespersonPersonID, SalesCount) AS (
	SELECT SalespersonPersonID, Count(InvoiceId)
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20140101' AND InvoiceDate < '20150101'
	GROUP BY SalespersonPersonID
	)
-- следующий оператор - обращение к cte
SELECT P.PersonID, P.FullName, I.SalesCount
FROM Application.People AS P
JOIN InvoicesCTE AS I ON P.PersonID = I.SalespersonPersonID


-- Несколько CTE (и без названия колонок)
; WITH InvoicesCTE AS (
	SELECT SalespersonPersonID, Count(InvoiceId) AS SalesCount
	FROM Sales.Invoices
	WHERE InvoiceDate >= '20140101' AND InvoiceDate < '20150101'
	GROUP BY SalespersonPersonID
	)
, InvoicesLinesCTE AS (-- через запятую, без WITH
 	SELECT Invoices.SalespersonPersonID, SUM(Lines.Quantity) AS TotalQuantity, SUM(Lines.Quantity * Lines.UnitPrice) AS TotalSumm
	FROM Sales.Invoices
	JOIN Sales.InvoiceLines AS Lines ON Invoices.InvoiceID = Lines.InvoiceID
	GROUP BY Invoices.SalespersonPersonID
	)
-- обращение к cte
SELECT P.PersonID, P.FullName, I.SalesCount, L.TotalQuantity, L.TotalSumm
FROM Application.People AS P
JOIN InvoicesCTE AS I ON P.PersonID = I.SalespersonPersonID
JOIN InvoicesLinesCTE AS L ON P.PersonID = L.SalespersonPersonID
ORDER BY L.TotalSumm DESC, I.SalesCount DESC

-- использование 
-- delete top N order by 
DROP TABLE IF EXISTS Sales.Invoices_DeleteDemo

SELECT TOP 300 *
INTO Sales.Invoices_DeleteDemo
FROM Sales.Invoices

-- нет сортировки
DELETE TOP (10) FROM Sales.Invoices_DeleteDemo ORDER BY InvoiceID
DELETE TOP (10) FROM Sales.Invoices_DeleteDemo
-- удалились не первые Ид
SELECT TOP 50 InvoiceId FROM Sales.Invoices_DeleteDemo ORDER BY InvoiceID

; WITH OrdDelete AS (
	SELECT TOP 10 InvoiceId
	FROM Sales.Invoices_DeleteDemo
	ORDER BY InvoiceID
	)
DELETE FROM OrdDelete

SELECT TOP 10 InvoiceId
FROM Sales.Invoices_DeleteDemo
ORDER BY InvoiceID

-- Как выполнить следующий SQL запрос, если предыдущий не вернул результат?
; WITH cte AS (
  SELECT StockItemName FROM Warehouse.StockItems WHERE 1=0
)
SELECT StockItemName FROM cte
UNION ALL
SELECT StockItemName FROM Warehouse.StockItems
WHERE NOT EXISTS (SELECT * FROM cte)

-- рекурсия - обращение к результатам предыдущего шага
-- n! = 1 * 2 * 3... * n
-- в цикле, но каждый раз будем обращаться к результату из предыдущего шага
declare @n int = 5
declare @i int = 1, @res int = 1 -- задаем для 1го шага
while @i < @n begin
	set @i = @i + 1
	set @res = @res * @i /*все, что получилось на предыдущем шаге * i из текущего шага*/

	print concat(@i, '! = ', @res)
end

declare @n int = 5
; with cte as ( -- цикл по i от 1 до @n, приращение на каждом шаге +1, переменная, для накопления результата - res
	select 1 as i, 1 as res -- начальные значения (якорь)
   	union all
   	select i + 1 as i, res * (i + 1) from cte /*обращение к данным предыдущего шага*/ where i < @n /*условие окончания цикла*/
)
select * from cte

-- сумма от 1 до m
declare @m int = 200 -- 1 + 2 + 3 + 4 + 5 ... + 200
; with cte as ( -- цикл по i от 1 до @n, приращение на каждом шаге +1, переменная, для накопления результата - res
   	select 1 as i, 1 as res
   	union all
   	select i + 1, res + (i + 1) from cte where i < @m --!!! на этом шаге доступны данные только предыдущей итерации
)
select * from cte --option(maxrecursion 200)
	
-- как начать с 10?
-- как генерить только нечетные?


-----------------------------
--вывод структуры подчиненности
DROP TABLE IF EXISTS #Employees
CREATE TABLE #Employees (EmployeeID INT PRIMARY KEY, FullName VARCHAR(256), Title VARCHAR(256), ManagerID INT);
INSERT INTO #Employees (EmployeeId, FullName, Title, ManagerID)
VALUES (1, 'John Mann', 'CEO', NULL), (2, 'Irvin Bow', 'CEO Deputy', 1), (3, 'Abby Gold', 'HR', 1), (4, 'Mary Wang', 'HR', 3), (5, 'Jim Johnson', 'HR', 4), (6, 'Linda Smith', 'HR', 3)
select * from #Employees

/*
кто кому подчиняется
John Mann - главный босс
	Irvin Bow
	Abby Gold
		Mary Wang 
			Jim Johnson 	
		Linda Smith
*/

; with cte as (
	-- точка старта (i = 1)
	select EmployeeId, ManagerId, cast(FullName as varchar(1000)) as val, 0 as level 
	from #Employees as em 
	where ManagerId is null --самый главный босс 
	--where ManagerId = 2 --всех подчиненных Irvin Bow

	union all 
	-- обращение к результатам предыдущего шага (запрос к cte)
	-- подчиненные главного босса (#Employees)
	select em.EmployeeId, em.ManagerId, cast(FullName + '->' + val as varchar(1000)) as val, level + 1
	from cte as t
	inner join #Employees as em on em.ManagerId = t.EmployeeId

)

select * from cte as t