use WideWorldImporters
go

-- Все, что нам дают оконные функции, можно сделать и без них. Но сложно.
begin -- Производительность: CTRL+M и смотрим на "лошадиные силы"

select  /*без всего*/
	номерЗаказа		= OL.OrderId,
	номерПозиции	= -111,
	заШт			= UnitPrice,
	шт				= PickedQuantity,
	ценаПозиции		= UnitPrice*PickedQuantity,
	покаЧтоВЗаказе	= -222,
	всегоВЗаказе	= -333,
	Позиция			= Description 

from 
		sales.OrderLines OL 
order by 
1,2

select /* с номером позиции*/
	номерЗаказа		= OL.OrderId,
	номерПозиции	= (select		  count(OrderLineId) 
								from  sales.OrderLines OL2 
								where OL.OrderId=OL2.OrderId 
								  and OL.OrderLineId<=OL2.OrderLineID),
	заШт			= UnitPrice,
	шт				= PickedQuantity,
	ценаПозиции		= UnitPrice*PickedQuantity,
	покаЧтоВЗаказе	= -222,
	всегоВЗаказе	= -333,
	Позиция			= Description 
from 
		sales.OrderLines OL 
order by 
1,2

select /* с номером позиции и текущей суммой*/
	номерЗаказа		= OL.OrderId,
	номерПозиции	= (select		  count(OrderLineId) 
								from  sales.OrderLines OL2 
								where OL.OrderId=OL2.OrderId 
								  and OL.OrderLineId<=OL2.OrderLineID),
	заШт			= UnitPrice,
	шт				= PickedQuantity,
	ценаПозиции		= UnitPrice*PickedQuantity,
	покаЧтоВЗаказе	= (select		  sum(UnitPrice*PickedQuantity) 
								from  sales.OrderLines OL2 
								where OL.OrderId=OL2.OrderId 
								  and OL.OrderLineId<=OL2.OrderLineID),
	всегоВЗаказе	= -333,
	Позиция			= Description 
from 
		sales.OrderLines OL 
order by 
1,2

select /* с номером позиции, текущей и общей суммами */
	номерЗаказа		= OL.OrderId,
	номерПозиции	= (select		  count(OrderLineId) 
								from  sales.OrderLines OL2 
								where OL.OrderId=OL2.OrderId 
								  and OL.OrderLineId<=OL2.OrderLineID),
	заШт			= UnitPrice,
	шт				= PickedQuantity,
	ценаПозиции		= UnitPrice*PickedQuantity,
	покаЧтоВЗаказе	= (select		  sum(UnitPrice*PickedQuantity) 
								from  sales.OrderLines OL2 
								where OL.OrderId=OL2.OrderId 
								  and OL.OrderLineId<=OL2.OrderLineID),
	всегоВЗаказе	= (select		  sum(UnitPrice*PickedQuantity) 
								from  sales.OrderLines OL2 
								where OL.OrderId=OL2.OrderId),
	Позиция			= Description 
from 
		sales.OrderLines OL 
order by 
1,2

select /* ! с номером позиции, текущей и общей суммами */
	номерЗаказа		= OL.OrderId,
	ol.OrderLineId as OLid,
	номерПозиции	= row_number() over (partition by OL.OrderId order by OrderLineId),

	заШт			= UnitPrice,
	шт				= PickedQuantity,
	ценаПозиции		= UnitPrice*PickedQuantity,
	покаЧтоВЗаказе	= sum(UnitPrice*PickedQuantity) over(partition by OL.OrderId order by OrderLineId ),

	всегоВЗаказе	= sum(UnitPrice*PickedQuantity) over(partition by OL.OrderId) ,
--	вообщеВсего		= sum(UnitPrice*PickedQuantity) over(),
	Позиция			= Description 
from 
		sales.OrderLines OL 
order by 
1,2
-- сравните execution plans
end -- /Производительность: CTRL+M и смотрим на "лошадиные силы"


select /* ? Почему так не сработает? */
	номерЗаказа		= OL.OrderId,
	номерПозиции	= row_number() over (partition by OL.OrderId order by OrderLineId),
	заШт			= UnitPrice,
	шт				= PickedQuantity,
	ценаПозиции		= UnitPrice*PickedQuantity,
	покаЧтоВЗаказе	= sum(UnitPrice*PickedQuantity) over(partition by OL.OrderId order by OrderLineId ),
	всегоВЗаказе	= sum(UnitPrice*PickedQuantity) over(partition by OL.OrderId) ,
	вообщеВсего		= sum(UnitPrice*PickedQuantity) over(),
	Позиция			= Description 
from 
		sales.OrderLines OL 
group by OL.OrderId
order by 
1,2

select /* ! зачем нужен dense_rank */
	номерЗаказа		= OL.OrderId,
	OL.orderlineid as OLId,
	номерПозиции	= row_number() over (partition by OL.OrderId order by OrderLineId),
	заШт			= UnitPrice,
	шт				= PickedQuantity,
	ценаПозиции		= UnitPrice*PickedQuantity,
	покаЧтоВЗаказе	= sum(UnitPrice*PickedQuantity) over(partition by OL.OrderId order by OrderLineId ),
	всегоВЗаказе	= sum(UnitPrice*PickedQuantity) over(partition by OL.OrderId) ,

	МестоПоДороговизнеВнутриЗаказа = rank() over (partition by OL.OrderId order by UnitPrice*PickedQuantity desc),
	СжатоеМестоПоДороговизнеВнутриЗаказа = dense_rank() over (partition by OL.OrderId order by UnitPrice*PickedQuantity desc),

	Позиция			= Description 
from 
		sales.OrderLines OL 
where OrderID = 268
order by 
1,2

-- тайлы
begin
-- разделим страны на 5 равных групп внутри каждого континента по их населению
select 
		Region, 
		CountryName, 
		ntile(5) over (partition by Region order by LatestRecordedPopulation),
		case 
					ntile(5) over (partition by Region order by LatestRecordedPopulation)
			when 1 then 'XS'
			when 2 then 'S'
			when 3 then 'M'
			when 4 then 'L'
			when 5 then 'XL'
		else '?'
		end size,
		LatestRecordedPopulation
--select * 
from Application.Countries
order by Region,LatestRecordedPopulation

end

-- Для каждого заказа выведем даты предыдущих 3х заказов этого клиента и время, которое прошло между заказами.
-- Если время между заказами увеличивается, возможно, клиент ~задумал недоброе~ требует стимуляции
-- lead(вперед) и lag(назад)
begin -- churn
select 
	OrderId,
	CustomerId, 
	OrderDate
--	,rn=row_number() over (partition by CustomerId order by OrderDate asc)
	,OrderDate1 = lag(OrderDate,1) over (partition by CustomerId order by OrderDate asc)
	,OrderDate2 = lag(OrderDate,2) over (partition by CustomerId order by OrderDate asc)
	,OrderDate3 = lag(OrderDate,3) over (partition by CustomerId order by OrderDate asc)
	,datediff(dd
			,lag(OrderDate,3) over (partition by CustomerId order by OrderDate asc)
			,lag(OrderDate,2) over (partition by CustomerId order by OrderDate asc)
			) diff3_2
	,datediff(dd
			,lag(OrderDate,2) over (partition by CustomerId order by OrderDate asc)
			,lag(OrderDate,1) over (partition by CustomerId order by OrderDate asc)
			) diff2_1
	,datediff(dd
			,lag(OrderDate,1) over (partition by CustomerId order by OrderDate asc)
			,OrderDate
			) diff1_0
--select top 10 *
from Sales.Orders
order by 
	CustomerId, 
	--SalespersonPersonID,
	OrderDate

-- diff3_2<= diff2_1 and diff2_1 <= diff1_0 --> для нас признак того, что клиента надо выделить
-- ? Почему это не сработает?
select 
	OrderId,
	CustomerId, 
	OrderDate
--	,rn=row_number() over (partition by CustomerId order by OrderDate asc)
	,OrderDate1 = lag(OrderDate,1) over (partition by CustomerId order by OrderDate asc)
	,OrderDate2 = lag(OrderDate,2) over (partition by CustomerId order by OrderDate asc)
	,OrderDate3 = lag(OrderDate,3) over (partition by CustomerId order by OrderDate asc)
	,datediff(dd
			,lag(OrderDate,3) over (partition by CustomerId order by OrderDate asc)
			,lag(OrderDate,2) over (partition by CustomerId order by OrderDate asc)
			) diff3_2
	,datediff(dd
			,lag(OrderDate,2) over (partition by CustomerId order by OrderDate asc)
			,lag(OrderDate,1) over (partition by CustomerId order by OrderDate asc)
			) diff2_1
	,datediff(dd
			,lag(OrderDate,1) over (partition by CustomerId order by OrderDate asc)
			,OrderDate
			) diff1_0
from Sales.Orders
where 
/*-*/		datediff(dd																					/*-*/	
/*-*/			,lag(OrderDate,3) over (partition by CustomerId order by OrderDate asc)					/*-*/
/*-*/			,lag(OrderDate,2) over (partition by CustomerId order by OrderDate asc)					/*-*/
/*-*/			)  -- diff3_2																			/*-*/
/*-*/		<=																							/*-*/
/*-*/		datediff(dd																					/*-*/
/*-*/			,lag(OrderDate,2) over (partition by CustomerId order by OrderDate asc)					/*-*/
/*-*/			,lag(OrderDate,1) over (partition by CustomerId order by OrderDate asc)					/*-*/
/*-*/			) --diff2_1																				/*-*/
/*-*/	AND																								/*-*/
/*-*/		datediff(dd																					/*-*/
/*-*/			,lag(OrderDate,2) over (partition by CustomerId order by OrderDate asc)					/*-*/
/*-*/			,lag(OrderDate,1) over (partition by CustomerId order by OrderDate asc)					/*-*/
/*-*/			) --diff2_1																				/*-*/
/*-*/		<=																							/*-*/
/*-*/		datediff(dd																					/*-*/
/*-*/			,lag(OrderDate,1) over (partition by CustomerId order by OrderDate asc)					/*-*/
/*-*/			,OrderDate																				/*-*/
/*-*/			) --diff1_0																				/*-*/
order by 
	CustomerId, 
	OrderDate

; with IncentiveWorkTable as (
select 
	OrderId,
	CustomerId, 
	OrderDate
--	,rn=row_number() over (partition by CustomerId order by OrderDate asc)
	,OrderDate1 = lag(OrderDate,1) over (partition by CustomerId order by OrderDate asc)
	,OrderDate2 = lag(OrderDate,2) over (partition by CustomerId order by OrderDate asc)
	,OrderDate3 = lag(OrderDate,3) over (partition by CustomerId order by OrderDate asc)
	,datediff(dd
			,lag(OrderDate,3) over (partition by CustomerId order by OrderDate asc)
			,lag(OrderDate,2) over (partition by CustomerId order by OrderDate asc)
			) diff3_2
	,datediff(dd
			,lag(OrderDate,2) over (partition by CustomerId order by OrderDate asc)
			,lag(OrderDate,1) over (partition by CustomerId order by OrderDate asc)
			) diff2_1
	,datediff(dd
			,lag(OrderDate,1) over (partition by CustomerId order by OrderDate asc)
			,OrderDate
			) diff1_0
	,SalesPerson = SalespersonPersonID
	,SalesPerson1 = lag(SalesPersonPersonID,1) over (partition by CustomerId order by OrderDate asc)
	,SalesPerson2 = lag(SalesPersonPersonID,2) over (partition by CustomerId order by OrderDate asc)
	,SalesPerson3 = lag(SalesPersonPersonID,3) over (partition by CustomerId order by OrderDate asc)
from Sales.Orders
)
select * from IncentiveWorkTable
where diff3_2<= diff2_1 and diff2_1 <= diff1_0
end

-- first_value и last_value
begin
declare @CRLF nvarchar(4)=char(13)+char(10)
; with Prep as (
select 
	номерЗаказа		= OL.OrderId,
	номерПозиции	= row_number() over (partition by OL.OrderId order by OrderLineId),
	заШт			= UnitPrice,
	шт				= PickedQuantity,
	СтоимостьПозиции= UnitPrice*PickedQuantity,
--	покаЧтоВЗаказе	= sum(UnitPrice*PickedQuantity) over(partition by OL.OrderId order by OrderLineId ),
--	всегоВЗаказе	= sum(UnitPrice*PickedQuantity) over(partition by OL.OrderId) ,
	МестоПоДороговизнеВнутриЗаказа = rank() over (partition by OL.OrderId order by UnitPrice*PickedQuantity desc),
--	СжатоеМестоПоДороговизнеВнутриЗаказа = dense_rank() over (partition by OL.OrderId order by UnitPrice*PickedQuantity desc),
	Позиция			= Description 

	,СамаяДорогая   = first_value(Description) over  (partition by OL.OrderId order by UnitPrice*PickedQuantity desc 
	
	rows between unbounded preceding and unbounded following)
	
	,СамаяДешевая   = last_value (Description) over  (partition by OL.OrderId order by UnitPrice*PickedQuantity desc rows between unbounded preceding and unbounded following)

	,Предыдущая    = first_value(Description) over  (partition by OL.OrderId order by OrderLineId 
	
	rows between 1 preceding and 1 preceding)
	
	,Следующая     = last_value (Description) over  (partition by OL.OrderId order by OrderLineId rows between 1 following and 1 following)
	,ПредСтоимость = first_value(UnitPrice*PickedQuantity) over  (partition by OL.OrderId order by OrderLineId rows between 1 preceding and 1 preceding)
	,СледСтоимость = last_value (UnitPrice*PickedQuantity) over  (partition by OL.OrderId order by OrderLineId rows between 1 following and 1 following)


from 
		sales.OrderLines OL 
where OrderID = 2090
)
select 

	 case when номерПозиции=1 then N'Сначала ' else N'Потом ' end
	 +N'Вы купили ' +cast(шт as nvarchar(max)) +N' '+Позиция	 +N' по '+cast(заШт as nvarchar(max))+N', итого '+cast(СтоимостьПозиции as nvarchar(max))+@CRLF
	 +N' Эта позиция находится на '	+cast (МестоПоДороговизнеВнутриЗаказа as nvarchar(max))
		+N' месте в списке позиций от самого дешевого, '+СамаяДешевая+N','+@CRLF
		+N'  до самого дорогого, '	+СамаяДорогая
		+N'.' +@CRLF
		+case when СтоимостьПозиции>ПредСтоимость	
			then N' Эта позиция дороже предыдущей, '+Предыдущая+N'.'+@CRLF
			else N''
			end
		+case when СтоимостьПозиции<ПредСтоимость	
			then N' Эта позиция дешевле предыдущей, '+Предыдущая+N'.'+@CRLF
			else N''
			end
		+case when СтоимостьПозиции>СледСтоимость	
			then N' Эта позиция дороже следующей, '+Следующая+N'.'+@CRLF
			else N''
			end
		+case when СтоимостьПозиции<СледСтоимость	
			then N' Эта позиция дешевле следующей, '+Следующая+N'.'+@CRLF
			else N''
			end
from Prep
order by номерПозиции
end

-- аггрегатные функции
select 
  CountryId, 
  Countryname,
  Region,
  LatestRecordedPopulation

---- 1 = функция 2 = окно 3 = прогрессия 4 = rows
----,S   = sum(LatestRecordedPopulation) --- is invalid in the select list because it is not contained in either an aggregate 
  ,St  = sum(LatestRecordedPopulation) over (partition by 'земной шар') --окно размеров вся таблица
  ,Sr  = sum(LatestRecordedPopulation) over (partition by Region)
  ,SrP = sum(LatestRecordedPopulation) over (partition by Region 	order by LatestRecordedPopulation ) --нарастающий итог
  ,StP = sum(LatestRecordedPopulation) over (partition by 0 		order by LatestRecordedPopulation desc) --нарстающий итог в обратном порядке для всей таблицы
                                                                                                            --(сортировка в окне и сортировка в запросе это не одно и тоже!!!)
  ,SrP3= sum(LatestRecordedPopulation) over (partition by Region 
			order by LatestRecordedPopulation desc
			rows between 1 preceding and 1 following)
  ,ArP5= avg(LatestRecordedPopulation) over (partition by Region 
			order by LatestRecordedPopulation desc
			rows between 2 preceding and 2 following)
  ,Mt  = max(LatestRecordedPopulation) over (partition by 'земной шар')
  ,Mr  = max(LatestRecordedPopulation) over (partition by Region)
  ,MrP = max(LatestRecordedPopulation) over (partition by Region 
			order by LatestRecordedPopulation asc)
  ,MrP3= max(LatestRecordedPopulation) over (partition by Region 
			order by LatestRecordedPopulation desc
			rows between 1 preceding and 1 following)
			
  ,Сt  = count_big(LatestRecordedPopulation) over (partition by 'земной шар') --возвращает тип int, поэтому иногда нужно использовать count_big()
  ,Сr  = count(LatestRecordedPopulation) over (partition by Region)
  ,СrP = count(LatestRecordedPopulation) over (partition by Region 
			order by LatestRecordedPopulation asc)
  ,СrP3= count(LatestRecordedPopulation) over (partition by Region 
			order by LatestRecordedPopulation desc
			rows between 1 preceding and 1 following)

 from [Application].Countries
 order by 
   region desc,
   LatestRecordedPopulation asc


