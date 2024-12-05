use WideWorldImporters;

drop table if exists #t1, #t2;

create table #t1 (id int identity, name varchar(1))
create table #t2 (id int identity, name varchar(1))

insert #t1 (name) values ('a'), ('b'), ('b'), (null) --множество 1
insert #t2 (name) values ('a'), ('c'), (null) --множество 2

select * from #t1 
select * from #t2 

--вывести данные 2х таблиц - в одну 
--сколько строк получится в union и union all?
--какой вариант быстрее? (Ctrl + M)
select name from #t1 --множество строк t1
union all
select name from #t2 --множество строк t2

select name from #t1 --множество строк t1
union
select name from #t2 --множество строк t2

--нужна cовместимость по типам 
select 'a' as col
union all
select 123 

--------------------
--except - вычитание
select * from #t1 
select * from #t2

--найти name из t1, которые не встречаются в t2
select name from #t1 
except 
select name from #t2

----------------
-- intersect - пересечение множества строк 2х таблиц
select * from #t1 
select * from #t2

select name from #t1 
intersect 
select name from #t2


