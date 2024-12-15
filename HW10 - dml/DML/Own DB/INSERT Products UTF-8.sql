USE Example;

INSERT INTO Products VALUES
 (1, N'Молоко')
,(2, N'Кефир')
,(3, N'Творог')
,(4, N'Сыр');
GO
--CONSTRAINT PK
INSERT INTO Products VALUES
 (1, N'Масло');
 GO
 --CONSTRAINT UNIQUE
INSERT INTO Products VALUES
 (5, N'Молоко');
 GO
 --SET VALUE IN NVARCHAR() Field
 INSERT INTO Products VALUES
  (5, 'Масло');
 INSERT INTO Products VALUES
  (6, '油');

  SELECT *
  FROM Products;

INSERT INTO Products VALUES
  (7, N'油');