select OrderId
      ,UnitPrice
	  ,PickedQuantity
	  ,UnitPrice*PickedQuantity as cost
	  --Место по стоимости внутри заказа, причем 1=самая дорогая покупка
	  ,rank() over (partition by OL.OrderId order by UnitPrice*PickedQuantity desc) as NumberPos_rank
	  ,row_number() over (partition by OL.OrderId order by UnitPrice*PickedQuantity desc) as NumberPos_rownumber

	  ,СамаяДешевая   = last_value (PickedQuantity) over  (partition by OL.OrderId order by UnitPrice*PickedQuantity desc rows between unbounded preceding and unbounded following)
	  ,СамаяДешевая2  = last_value (PickedQuantity) over  (partition by OL.OrderId order by UnitPrice*PickedQuantity desc rows between 1 preceding and 1 following)

	  ,СамаяДорогая   = first_value (PickedQuantity) over  (partition by OL.OrderId order by UnitPrice*PickedQuantity desc rows between unbounded preceding and unbounded following)
	  ,СамаяДорогая2  = first_value (PickedQuantity) over  (partition by OL.OrderId order by UnitPrice*PickedQuantity desc rows between 1 preceding and 1 following)

from sales.OrderLines OL 
where OrderID = 2090 or OrderID = 8
order by OrderID, NumberPos_rownumber

--update o
--set o.PickedQuantity = 1
--from sales.OrderLines o 
--where OrderID = 8 and UnitPrice=13

select OrderId
      ,UnitPrice
	  ,PickedQuantity
	  ,UnitPrice*PickedQuantity as cost
	
	  ,Следующая = last_value (PickedQuantity) over  (partition by OL.OrderId order by UnitPrice*PickedQuantity rows between 1 following and 1 following)
	  ,Предыдущее = last_value (PickedQuantity) over  (partition by OL.OrderId order by UnitPrice*PickedQuantity rows between 1 preceding and 1 preceding)

from sales.OrderLines OL 
where OrderID = 2090 or OrderID = 8
order by OrderID, cost


--RANGE
select OrderId
      ,UnitPrice
	  ,PickedQuantity
	  ,UnitPrice*PickedQuantity as cost
	  --Место по стоимости внутри заказа, причем 1=самая дорогая покупка
	  ,rank() over (partition by OL.OrderId order by UnitPrice*PickedQuantity desc) as NumberPos_rank
	  ,row_number() over (partition by OL.OrderId order by UnitPrice*PickedQuantity desc) as NumberPos_rownumber
	  --Текущей строкой RANGE считает все строки с одинаковыми "UnitPrice*PickedQuantity"
	  ,Сумма  = sum(PickedQuantity) over  (partition by OL.OrderId order by UnitPrice*PickedQuantity desc range CURRENT ROW)

from sales.OrderLines OL 
where OrderID = 2090 or OrderID = 8
order by OrderID, NumberPos_rownumber