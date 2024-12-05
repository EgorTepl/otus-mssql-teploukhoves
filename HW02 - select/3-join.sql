use WideWorldImporters;
-- презентация + gif

----------------------------
-- как понять, по какому полю соединять
-- заказы дополнить именем клиента
select top 5 * from Sales.Orders -- Alt + F1 -- полное название fk 
-- FK_Sales_Orders_CustomerID_Sales_Customers => Sales_Orders_CustomerID = Sales_Customers.?
select top 5 * from Sales.Customers

select top 5 * 
from Sales.Orders
join Sales.Customers on Sales.Customers.CustomerID = Sales.Orders.CustomerID

-- обычно используют алиасы (псевдонимы)
select top 5 * 
from Sales.Orders as o --алиас 
join Sales.Customers as c on c.CustomerID = o.CustomerID

----------------------------
--разные типы join
drop table if exists #cafe1, #cafe2
create table #cafe1 (id int identity, name nvarchar(10))
create table #cafe2 (id int identity, name nvarchar(10))

insert #cafe1 (name) values(N'яблоки'), (N'груши'), (N'бананы')
insert #cafe2 (name) values(N'яблоки'), (N'груши'), (null)

select * from #cafe1
select * from #cafe2

----------------------------
-- cross join -все комбинации из строк двух таблиц
select *
from #cafe1
cross join #cafe2

-- или так
select * from #cafe1, #cafe2


--типовая задача: составить все возможные варианты рецептов смузи из 2х фруктов для кафе1
-- самоджоин
select c1.name, c2.name 
from #cafe1 as c1
cross join #cafe1 as c2 

-- а здесь без алиасов не обойтись 
select #cafe1.name, #cafe1.name 
from #cafe1
cross join #cafe1
----------------------------
-- задача: найти фрукты, которые есть в кафе1 и кафе2
-- какой тип соединения будем использовать? cross/inner/left/right/full
select * from #cafe1
select * from #cafe2

--pgdn






-- inner join - внутреннее соединение по условию (самое быстрое)
select c1.name, c2.name 
from #cafe1 as c1
inner join #cafe2 as c2 on c2.name = c1.name

-- или так
select c1.name, c2.name 
from #cafe1 as c1
join #cafe2 as c2 on c2.name = c1.name


--проблема - если связываем таблицы по неуникальному полю
--добавим дубли
insert #cafe1 (name) values(N'яблоки')
insert #cafe2 (name) values(N'яблоки')

select * from #cafe1
select * from #cafe2

-- та же задача: найти фрукты, которые есть в кафе1 и кафе2
-- есть дубли
select c1.name, c2.name, * 
from #cafe1 as c1
inner join #cafe2 as c2 on c2.name = c1.name


--удалим дубли (но помним про проблемы)
delete from #cafe1 where id = 4
delete from #cafe2 where id = 4

select * from #cafe1
select * from #cafe2

----------------------------
-- left join
-- типовая задача: какие фрукты есть в кафе1, но нет в кафе2
-- какой фильтр в where задать, чтобы отфильтровать отсутствие фруктов в кафе2
select *
from #cafe1 as c1
left join #cafe2 as c2 on c2.name = c1.name



--дополнить список фруктов из кафе1 данными по фруктам из кафе2, название которых начинается на Я 

select *
from #cafe1 as c1
left join #cafe2 as c2 on c2.name = c1.name 
where c2.name like N'я%' --проверка на true

-- данные теряются, потому что фильтруем по левой части, а там null
-- решение - фильтруем во время джоина
select *
from #cafe1 as c1
left join #cafe2 as c2 on c2.name = c1.name and c2.name like N'я%'

----------------------------
-- right join - применяется редко, обычно пишем left join
select *
from #cafe1 as c1
right join #cafe2 as c2 on c2.name = c1.name

----------------------------
--full join = left join + right join
--вначале left& затем дполняем из right
select *
from #cafe1 as c1
full join #cafe2 as c2 on c2.name = c1.name

--------------------------------
-- "Съедание данных" LEFT JOIN
--------------------------------
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  t.TransactionDate,
  t.TransactionTypeID --дополнить наименованием транзакции
FROM Purchasing.Suppliers s
LEFT JOIN Purchasing.SupplierTransactions t ON t.SupplierID = s.SupplierID
ORDER BY s.SupplierID;

-- Добавим TransactionTypes через INNER JOIN
SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  tt.TransactionTypeName
FROM Purchasing.Suppliers s
LEFT JOIN Purchasing.SupplierTransactions t ON t.SupplierID = s.SupplierID
INNER JOIN Application.TransactionTypes tt ON tt.TransactionTypeID = t.TransactionTypeID
ORDER BY s.SupplierID;

-- Как сделать так, чтобы данные не пропали?
-- pgdn










SELECT
  s.SupplierID,
  s.SupplierName,
  t.SupplierTransactionID,
  tt.TransactionTypeName
FROM Purchasing.Suppliers s
LEFT JOIN Purchasing.SupplierTransactions t ON t.SupplierID = s.SupplierID
LEFT JOIN Application.TransactionTypes tt ON tt.TransactionTypeID = t.TransactionTypeID
ORDER BY s.SupplierID;