CREATE PROC WareHouse.GetColor(@CountRows INT) AS
BEGIN
    SELECT TOP (@CountRows) 
       ColorId
     , ColorName
     , LastEditedBy
    FROM Warehouse.Colors
END;