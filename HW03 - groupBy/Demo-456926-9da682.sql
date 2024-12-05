use WideWorldImporters

-- Исходная таблица
SELECT *	
FROM Sales.Orders

-- Сколько всего строк
SELECT count(*)
      ,count(1)
	  ,count(t.BackorderOrderID)
	  --,t.ExpectedDeliveryDate as dt  --С группировкой по полю
FROM Sales.Orders t
--group by(t.ExpectedDeliveryDate) --С группировкой по полю
--order by dt


-- Работа с NULL, DISTINCT
/*source*/ 
SELECT * FROM Purchasing.SupplierTransactions ORDER BY FinalizationDate

SELECT --t.TransactionTypeID,  --С группировкой по полю
 COUNT(*) TotalRows, -- Количество строк
 COUNT(t.FinalizationDate) AS FinalizationDate_Count, -- Игнорирование NULL
 COUNT(DISTINCT t.SupplierID) AS SupplierID_DistinctCount, -- Количество уникальных значений в столбце
 COUNT(ALL t.SupplierID) AS SupplierID_AllCount, -- Количество всех значений в столбце
 SUM(t.TransactionAmount) AS TransactionAmount_SUM,
 SUM(DISTINCT t.TransactionAmount) AS TransactionAmount_SUM_DISTINCT,
 AVG(t.TransactionAmount) AS TransactionAmount_AVG, 
 MIN(t.TransactionAmount) AS TransactionAmount_MIN,
 MAX(t.TransactionAmount)AS TransactionAmount_MAX
FROM Purchasing.SupplierTransactions t
--group by t.TransactionTypeID  --С группировкой по полю


-- Использование функций (сколько формируются позиции заказа)
SELECT 
    MIN(DATEDIFF(hour, o.OrderDate, l.PickingCompletedWhen)) AS [MIN],
    AVG(DATEDIFF(hour, o.OrderDate, l.PickingCompletedWhen)) AS [AVG],    
    MAX(DATEDIFF(hour, o.OrderDate, l.PickingCompletedWhen)) AS [MAX]
FROM Sales.OrderLines l
JOIN Sales.Orders o ON o.OrderID = l.OrderID
WHERE l.PickingCompletedWhen IS NOT NULL

---- STRING_AGG = объединение полей в строку
SELECT SupplierName
FROM Purchasing.Suppliers s 
JOIN Purchasing.SupplierCategories c ON c.SupplierCategoryID = s.SupplierCategoryID

SELECT STRING_AGG(SupplierName, ', ') as fio --within group(order by SupplierName desc) as fio --сортировка
FROM Purchasing.Suppliers s 
JOIN Purchasing.SupplierCategories c ON c.SupplierCategoryID = s.SupplierCategoryID
order by fio --desc

-- Поставщики в разрезе категорий
SELECT 
  c.SupplierCategoryName,
  s.SupplierName
FROM Purchasing.Suppliers s 
JOIN Purchasing.SupplierCategories c 
  ON c.SupplierCategoryID = s.SupplierCategoryID
ORDER BY c.SupplierCategoryName, s.SupplierName;

SELECT 
  c.SupplierCategoryName AS Category,
  STRING_AGG(s.SupplierName, ', ') AS Suppliers
FROM Purchasing.Suppliers s 
JOIN Purchasing.SupplierCategories c 
  ON c.SupplierCategoryID = s.SupplierCategoryID
GROUP BY c.SupplierCategoryName;


-- Есть обратная функция STRING_SPLIT
-- https://docs.microsoft.com/ru-ru/sql/t-sql/functions/string-split-transact-sql?view=sql-server-ver15

SELECT res.value
FROM STRING_SPLIT('Lorem ipsum dolor sit amet.  ', ' ') res;

-------- Сравнение с агрегатами
-- Неправильно = КАК это расчитать???
SELECT * 
FROM Sales.OrderLines
WHERE UnitPrice * Quantity > AVG(UnitPrice * Quantity)


-------------
-- подзапрос для среднего
SELECT AVG(UnitPrice * Quantity) 
FROM Sales.OrderLines

SELECT * 
FROM Sales.OrderLines 
WHERE UnitPrice * Quantity  > 
	(SELECT 
		AVG(UnitPrice * Quantity) 
	FROM Sales.OrderLines)

--HAVING ???
SELECT UnitPrice,Quantity,AVG(UnitPrice * Quantity)
FROM Sales.OrderLines
group by UnitPrice,Quantity
HAVING UnitPrice * Quantity > AVG(UnitPrice * Quantity)

------
-- Группировка по нескольким полям, по функции, ORDER BY по агрегирующей функции
------
-- Сколько заказов собрал сотрудник по годам
SELECT 
  p.FullName,
  YEAR(o.OrderDate) AS OrderYear, 
  COUNT(*) AS OrdersCount  
FROM Sales.Orders o
JOIN Application.People p ON p.PersonID = o.PickedByPersonID
GROUP BY YEAR(o.OrderDate), p.FullName

 -- HAVING
SELECT 
  YEAR(o.OrderDate) AS OrderYear, 
  p.FullName AS PickedBy,
  COUNT(*) AS OrdersCount  
FROM Sales.Orders o
JOIN Application.People p ON p.PersonID = o.PickedByPersonID
GROUP BY YEAR(o.OrderDate), p.FullName
HAVING COUNT(*) > 1200 -- <========
ORDER BY OrdersCount DESC;



-- -- Но если условия можно написать в WHERE, то лучше писать их в WHERE
SELECT 
  YEAR(o.OrderDate) AS OrderDate, 
  COUNT(*) AS OrdersCount  
FROM Sales.Orders o
GROUP BY YEAR(o.OrderDate)
HAVING YEAR(o.OrderDate) > 2014;

-- -- с WHERE план одинаковый
SELECT 
  YEAR(o.OrderDate) AS OrderDate, 
  COUNT(*) AS OrdersCount  
FROM Sales.Orders o
WHERE YEAR(o.OrderDate) > 2014
GROUP BY YEAR(o.OrderDate);



-- GROUPING SETS
-- -- Что это такое - аналог с UNION

SELECT TOP 5 NULL AS ContactID, YEAR(o.OrderDate) AS [OrderYear], COUNT(*) AS OrderCountPerYear
FROM Sales.Orders o
GROUP BY YEAR(o.OrderDate)

UNION

SELECT TOP 5 o.ContactPersonID AS ContactID, NULL AS [OrderYear], COUNT(*) AS ContactPersonCount
FROM Sales.Orders o
GROUP BY o.ContactPersonID

-- -- GROUPING SETS 
SELECT TOP 10
  o.ContactPersonID,
  YEAR(o.OrderDate) AS OrderYear,
  COUNT(*) AS [Count]
FROM Sales.Orders o
GROUP BY GROUPING SETS (o.ContactPersonID, YEAR(o.OrderDate));




-- ROLLUP (промежуточные итоги)
-- -- запрос для проверки итоговых значений
SELECT 
  YEAR(o.OrderDate) AS OrderYear, 
  COUNT(*) AS OrdersCount  
FROM Sales.Orders o
WHERE o.PickedByPersonID IS NOT NULL
GROUP BY YEAR(o.OrderDate)
ORDER BY YEAR(o.OrderDate);

-- -- rollup
SELECT 
  YEAR(o.OrderDate) AS OrderYear, 
  p.FullName AS PickedBy,
  COUNT(*) AS OrdersCount  
FROM Sales.Orders o
JOIN Application.People p ON p.PersonID = o.PickedByPersonID
WHERE o.PickedByPersonID IS NOT NULL
GROUP BY ROLLUP (YEAR(o.OrderDate), p.FullName)
ORDER BY YEAR(o.OrderDate), p.FullName;
GO


-- ROLLUP и GROUPING
SELECT 
  grouping(YEAR(o.OrderDate)) AS OrderYear_GROUPING,
  grouping(p.FullName) AS PickedBy_GROUPING,
  YEAR(o.OrderDate) AS OrderDate, 
  p.FullName AS PickedBy,
/*  COUNT(*) AS OrdersCount,
  -- -------
  CASE grouping(YEAR(o.OrderDate)) 
    WHEN 1 THEN 'Total'
    ELSE CAST(YEAR(o.OrderDate) AS NCHAR(5))
  END AS Count_GROUPING,

  CASE grouping(p.FullName) 
    WHEN 1 THEN 'Total'
    ELSE p.FullName 
  END AS PickedBy_GROUPING,
*/
  COUNT(*) AS OrdersCount
FROM Sales.Orders o
JOIN Application.People p ON p.PersonID = o.PickedByPersonID
WHERE o.PickedByPersonID IS NOT NULL
GROUP BY ROLLUP (YEAR(o.OrderDate), p.FullName)
ORDER BY YEAR(o.OrderDate), p.FullName;

-- CUBE (тот же ROLLUP, но для всех комбинаций групп)
SELECT 
  grouping(YEAR(o.OrderDate)) AS OrderYear_GROUPING,
  grouping(p.FullName) AS PickedBy_GROUPING,
  grouping_id(YEAR(o.OrderDate),p.FullName), -- битовая маска для grouping 10 = по первому полю grouping дал 1
                                             --                            01 = по второму полю grouping дал 1
                                             --                            11 = по обоим полям  grouping дал 1 = 3(в десятичном исчислении)
  
  YEAR(o.OrderDate) AS OrderDate, 
  p.FullName AS PickedBy,
  COUNT(*) AS OrdersCount  
FROM Sales.Orders o
JOIN Application.People p ON p.PersonID = o.PickedByPersonID
WHERE o.PickedByPersonID IS NOT NULL
GROUP BY CUBE (p.FullName, YEAR(o.OrderDate))
ORDER BY YEAR(o.OrderDate), p.FullName;
