--Таблица объема поставок фруктов в разрезе поставщиков и лет
create table #HARVESTING_FRUITS(company_id int
                               ,Apple int
							   ,Grape int
							   ,[Year] int
							   )

--Таблица компаний
create table #company(id int primary key
                     ,[Name] nvarchar(45)
					 )

insert into #HARVESTING_FRUITS values
 (1, 1000, 2000, 2015)
,(1, 5000, 3000, 2016)
,(1, 5000, 3000, 2017)
,(1, 5000, 3000, 2018)
,(2, 9995, 8880, 2015)
,(2, 9990, 8880, 2016)
,(2, 9990, 6660, 2017)
,(2, 9990, 5550, 2018)
,(3, 3995, 3880, 2015)
,(3, 3990, 4880, 2016)
,(3, 3990, 5660, 2017)
,(3, 3990, 6550, 2018)

insert into #company values
 (1, 'FGS')
,(2, 'Village')
,(3, 'Best Fruit')

--Имеем сводный набор данных:
select * from #HARVESTING_FRUITS f
inner join #company c on c.id = f.company_id

--APPLAY
--Сначала собираем табличку в разрезе компаний и при этом объединим названия фруктов с годом:
SELECT C.[NAME], FRUITS_BY_YEAR.*
FROM #HARVESTING_FRUITS FRUITS
INNER JOIN #COMPANY c ON FRUITS.COMPANY_ID = c.ID
CROSS APPLY (VALUES (CONCAT('APPLES - ', [YEAR]), APPLE),
                    (CONCAT('GRAPES - ', [YEAR]), GRAPE)
            ) FRUITS_BY_YEAR (FRUIT_YEAR, AMOUNT)



--PIVOT - группируем и разворачиваем только за три выбранных года
SELECT *
FROM 
(

SELECT с.NAME, FRUITS_BY_YEAR.*
FROM #HARVESTING_FRUITS FRUITS
INNER JOIN #COMPANY с ON FRUITS.COMPANY_ID = с.ID
CROSS APPLY (VALUES (CONCAT('APPLES - ', YEAR), APPLE),
                    (CONCAT('GRAPES - ', YEAR), GRAPE)
            ) FRUITS_BY_YEAR (FRUIT_YEAR, AMOUNT)

) COLLECTED_FRUITS --источник

PIVOT 
(
MAX(AMOUNT)
FOR FRUIT_YEAR IN ([APPLES - 2015], [APPLES - 2016], [APPLES - 2017], 
                   [GRAPES - 2015], [GRAPES - 2016], [GRAPES - 2017]
                  )
) COMBINED_FRUITS --итоговый набор после PIVOT


--

drop table #HARVESTING_FRUITS
drop table #company