create table #t(mes int, fio nvarchar(45), kol int)

insert into #t(mes, fio, kol) values
 (1,'IvanovII',200)
,(1,'IvanovII',100)
,(1,'PetrovPP',100)
,(1,'PetrovPP',90)
,(1,'SidorovVV',600)
,(1,'VasilevMM',600)
,(2,'IvanovII',99)
,(2,'PetrovPP',88)
,(2,'SidorovVV',77)
,(2,'VasilevMM',60)

select * from #t order by fio


select 'AVGkol' as NameAVGCol --Содержимое первой колонки в развернутой строке данных(обычно краткое описание строки = среднее количество)
      ,IvanovII ,PetrovPP
from
(select fio, kol from #t) --то как выглядит исходный набор данных
as SourceTable
pivot
(
avg(kol) --взять среднее по этому столбцу
for fio  --в этой колонке из SourceTable ищем названия колонок для будущей развернутой таблицы
in (IvanovII ,PetrovPP) --только эти названия колонок для будущей развернутой таблицы берем из строк в колонке fio
)
as PivotTable

select fio,avg(kol) from #t where fio in ('IvanovII' ,'PetrovPP')  group by fio 

--drop table #t



--Пример, показывающий, что внутри PIVOT аггрегация происходит по всем полям перечисленным в исходном наборе данных кроме поля указанного в функции агрегирования(kol)
--Это обязывает быть осторожным при перечислении полей в исходном наборе и не использовать *
select * from #t order by mes, fio

select 'AVGkol' as NameAVGCol --Содержимое первой колонки в развернутой строке данных(обычно краткое описание строки = среднее количество)
      ,IvanovII ,PetrovPP
from
(select mes,fio, kol from #t) -- !!! ДОБАВИЛИ mes !!! -> группировка происходит  по всем полям перечисленным в исходном наборе данных кроме поля указанного в функции агрегирования(kol)
as SourceTable
pivot
(
avg(kol) --взять среднее по этому столбцу
for fio  --в этой колонке из SourceTable ищем названия колонок для будущей развернутой таблицы
in (IvanovII ,PetrovPP) --только эти названия колонок для будущей развернутой таблицы берем из строк в колонке fio
)
as PivotTable

select mes,fio,avg(kol) from #t where fio in ('IvanovII' ,'PetrovPP')  group by mes,fio 



--Этот пример показывает, что можно усложнить запрос и для 3-х колонок, если добавить использование номера месяца в результирующем наборе
select * from #t order by mes, fio

select mes --'AVGkol' as NameAVGCol --Содержимое первой колонки в развернутой строке данных(обычно краткое описание строки = среднее количество)
      ,IvanovII ,PetrovPP
from
(select mes,fio, kol from #t) --то как выглядит исходный набор данных  !!! ДОБАВИЛИ mes !!!
as SourceTable
pivot
(
avg(kol) --взять среднее по этому столбцу
for fio  --в этой колонке из SourceTable ищем названия колонок для будущей развернутой таблицы
in (IvanovII ,PetrovPP) --только эти названия колонок для будущей развернутой таблицы берем из строк в колонке fio
)
as PivotTable



--Этот пример показывает, что можно использовать не существующие в исходном наборе значения для формирования колонок
select * from #t order by mes, fio

select 'AVGkol' as NameAVGCol --Содержимое первой колонки в развернутой строке данных(обычно краткое описание строки = среднее количество)
      ,IvanovII ,PetrovPP, VasechkinKK -- !!! ДОБАВИЛИ VasechkinKK !!! -> этот набор полей должен соответствовать тому который в PIVOT IN
from
(select fio, kol from #t) --то как выглядит исходный набор данных 
as SourceTable
pivot
(
avg(kol) --взять среднее по этому столбцу
for fio  --в этой колонке из SourceTable ищем названия колонок для будущей развернутой таблицы
in (IvanovII ,PetrovPP, VasechkinKK) --только эти названия колонок для будущей развернутой таблицы берем из строк в колонке fio !!! ДОБАВИЛИ VasechkinKK !!!
)
as PivotTable


--Этот пример показывает, что алиас развернутого(PivotTable) можно использовать для соединения через JOIN
select 'AVGkol' as NameAVGCol --Содержимое первой колонки в развернутой строке данных(обычно краткое описание строки = среднее количество)
      ,IvanovII ,PetrovPP, VasechkinKK -- этот набор полей должен соответствовать тому который в PIVOT IN
	  ,t.* --!!! ДОБАВИЛИ список полей из присоединенной таблицы !!!
from
(select mes,fio, kol from #t) --то как выглядит исходный набор данных 
as SourceTable 
pivot
(
avg(kol) --взять среднее по этому столбцу
for fio  --в этой колонке из SourceTable ищем названия колонок для будущей развернутой таблицы
in (IvanovII ,PetrovPP, VasechkinKK) --только эти названия колонок для будущей развернутой таблицы берем из строк в колонке fio
)
as PivotTable
inner join #t t on t.kol = PivotTable.IvanovII --!!! ДОБАВИЛИ inner join !!!


--Ссылка на описание FROM c участием PIVOT(для понимания наличия бОльших возможностей при работе с PIVOT)
https://learn.microsoft.com/ru-ru/sql/t-sql/queries/from-transact-sql?view=sql-server-ver16

drop table #t