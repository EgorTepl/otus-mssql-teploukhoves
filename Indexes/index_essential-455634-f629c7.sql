
drop table if exists Employees

create table Employees (
	id int identity constraint pk_employees primary key
	, fname varchar(100)
	, lname varchar(100)
	, gender char(1)
	, datestarted date
)
--есть ли индексы? Alt + F1
exec sp_helpindex Employees

/*
50 000 rows - все поля случайные величины
fname - название месяца = 12
lname - случайные 7 букв = 50 000
gender - {F, M, X} - 3
datestarted - текущая дата +- 3000 дней - примерно 16 лет, есть повторы 
*/

insert Employees (fname, lname, gender, datestarted)
select 
	fname = datename(mm, dateadd(dd, num % 365, getdate())) --название месяца
	, lname = char(65 + abs(num0 % 26)) -- 7 букв
		+ char(97 + abs(num1 % 26))
		+ char(97 + abs(num2 % 26))
		+ char(97 + abs(num3 % 26))
		+ char(97 + abs(num4 % 26))
		+ char(97 + abs(num5 % 26))
		+ char(97 + abs(num6 % 26))
	, gender = iif(num % 700 = 0, 'X', iif(num % 30 = 0, 'F', 'M')) --самый редкий X (NULL)
	, datestarted = dateadd(dd, num5 % 3000, getdate())
from (
	select convert(binary(8), newid()) as num
		, convert(binary(8), newid()) as num0
		, convert(binary(8), newid()) as num1
		, convert(binary(8), newid()) as num2
		, convert(binary(8), newid()) as num3
		, convert(binary(8), newid()) as num4
		, convert(binary(8), newid()) as num5
		, convert(binary(8), newid()) as num6
	) t, string_split(space(999), ' ') t1, string_split(space(49), ' ') 

-- X - самый редкий, M - самый частый
select gender, count(*) from Employees group by gender

-- ****************************
-- план запроса - actual plan - CtrL + M
-- чтение данных: scan vs seek 
-- ****************************

-- чтение без фильтров => scan clustered index
select count(*) from Employees -- scan pk_employees

-- ****************************
-- использование индексов
-- ****************************
-- индекс на каждое поле
create index x1_fn on Employees (fname)
create index x2_ln on Employees (lname)
create index x3_ds on Employees (datestarted)
create index x4_ge on Employees (gender)

exec sp_helpindex Employees

--изменится или нет план запроса?
select count(*) from Employees 






--scan index x4_ge (меньше страниц читать + не важно по какой структуре считать count(*))

-- сколько страниц в индексе
select i.name, sum(s.used_page_count) as pages
from sys.dm_db_partition_stats as s
inner join sys.indexes as i on s.object_id = i.object_id and s.index_id = i.index_id
where s.object_id = object_id('Employees')
group by i.name
order by pages

-- фильтр => нужно выбрать scan vs seek (читать всю таблицу или искать в индексе)
select * from Employees where fname = 'January' 
select * from Employees where gender = 'M' 
-- индекс на поле из фильтра есть, но нужно прочитать все колонки (*)

-- изменится ли план?
select fname from Employees where fname = 'January' 
select gender from Employees where gender = 'M' 

-- а так? будет ли использоваться index seek?
select fname, gender from Employees where gender = 'M' 
select fname, gender from Employees where gender = 'X' 
-- толщина стрелки

--seek - один и тот же план, почему?
select count(*) from Employees where gender = 'M' 
select count(*) from Employees where gender = 'X' 


--будут ли отличаться? почему?
select gender from Employees where gender = 'X' 
select lname, gender from Employees where gender = 'X' 

--будут ли отличаться?
select lname, gender from Employees where gender = 'X' 
select id, gender from Employees where gender = 'X' 
--некластерный индекс включает кластерный


--scan vs seek
select count(*) from Employees where lname like '%L%'
select count(*) from Employees where lname like '%L'
select count(*) from Employees where lname like 'L%'
--почему scan x2_ln, а не по кластерному?

-- like vs not like => seek vs scan 
select count(*) from Employees where lname like 'L%'
select count(*) from Employees where lname not like 'L%' --проверяем всю выборку

-- разные планы (зависит от кол-ва записей/толщины стрелки)
select gender, count(*) from Employees where lname like 'L%' group by gender --scan pk
select gender, count(*) from Employees where lname like 'LA%' group by gender --seek x2_ln + lookup

-- оптимизатор смотрит на толщину стрелок и принимает решение: scan pk vs seek + lookup = nested loop

-- seek vs scan
select count(*) from Employees where year(datestarted) = 2022




-- исправим
select count(*) from Employees where datestarted between '2022-01-01' and '2022-12-31'

-- поиск по 2м полям
select count(*) from Employees where datestarted between '2022-01-01' and '2022-12-31' and gender = 'X'

-- составной индекс - одни и те же поля, но в разном порядке
create index x6_ds_ge on Employees (datestarted, gender)
create index x7_ge_ds on Employees (gender, datestarted)

-- выбор индекса
-- см. какой из фильтров отсечет максимум строк:
-- /*1*/ gender = 'X' (максимальное уменьшение выборки) => x7_ge_ds
-- /*2*/ gender != 'X' почти не отсечет => x6_ds_ge
/*1*/ select count(*) from Employees where datestarted between '2022-01-01' and '2022-12-31' and gender = 'X'
/*2*/ select count(*) from Employees where datestarted between '2022-01-01' and '2022-12-31' and gender != 'X'

-- if не работает => dbcc freeproccache -- очистить процедурный кэш (не делать на рабочих серверах)
-- есть ли вопросы?