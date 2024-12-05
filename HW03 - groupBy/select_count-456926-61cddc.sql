--проверка на то, где можно использовать подзапросы
select (select CityID from Application.Cities cc where cc.CityID = c.CityID)
      ,c.CityName
from Application.Cities c
inner join (select * from Application.StateProvinces where StateProvinceCode='CA') a on c.StateProvinceID = a.StateProvinceID
where exists(select * from Application.StateProvinces) 
group by c.CityID, c.CityName--, (select CityID from Application.Cities cc where cc.CityID = c.CityID)
having (select CityID from Application.Cities cc where cc.CityID = c.CityID) > count(*)
order by (select CityID from Application.Cities cc where cc.CityID = c.CityID)

--ѕро COUNT и COUNT_BIG(смотреть планы)
select count(*) as cnt
from Application.Cities
select count_big(*) as cnt
from Application.Cities



