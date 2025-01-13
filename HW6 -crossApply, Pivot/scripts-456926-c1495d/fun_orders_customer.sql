create function sales.orders_customer( @cust_id int )
returns table
as
return
(
SELECT TOP 2 *
                FROM Sales.Orders O
                WHERE O.CustomerID = @cust_id
					AND OrderDate < '2014-01-01'
                ORDER BY O.OrderDate DESC, O.OrderID DESC
)
go

--drop function sales.orders_customer