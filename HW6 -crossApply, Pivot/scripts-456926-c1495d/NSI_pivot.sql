create table #nsi(id int primary key, names nvarchar(45), zn int)

insert into #nsi(id, names, zn) values
 (1,'Set diagnostik ON\OF',1)
,(2,'Set visible Col',4)
,(3,'Set visible NULL ',1)

select * from #nsi

select --'AVGkol' as NameAVGCol --Содержимое первой колонки в развернутой строке данных(обычно краткое описание строки = среднее количество)
      [1], [2], [3]
from
(select id, zn from #nsi) --то как выглядит исходный набор данных
as SourceTable
pivot
(
max(zn) --поскольку в исходном наборе вычисляться будет только одна строка, т.к. группируем по primary key, то можно использовать любую ф-ю
for id  --в этой колонке из SourceTable ищем названия колонок для будущей развернутой таблицы
in ([1], [2], [3]) --только эти названия колонок для будущей развернутой таблицы берем из строк в колонке fio
)
as PivotTable

drop table #nsi