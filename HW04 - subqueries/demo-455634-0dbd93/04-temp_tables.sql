-- область видимости - текущий сеанс

drop table if exists #test
CREATE TABLE #test (PersonID INT, PetName VARCHAR(50));

INSERT INTO #test (PersonID, PetName)
VALUES (1, 'Alice'), (2, 'Jacky'), (3, 'Layka');

SELECT * FROM #test -- в текущем сеансе
SELECT * FROM #test -- в новом сеансе

--------------------
--глобальные временные таблицы - видны всем
drop table if exists ##test
CREATE TABLE ##test (PersonID INT, PetName VARCHAR(50));

-- в другом сеансе
CREATE TABLE ##test (PersonID2 INT, PetName2 VARCHAR(50));

INSERT INTO ##test (PersonID, PetName)
VALUES (1, 'Alice'), (2, 'Jacky'), (3, 'Layka');

SELECT * FROM ##test; 
DROP TABLE ##test;

---
-- область видимости - текущий пакет операций
DECLARE @test_var TABLE (PersonID INT, PetName VARCHAR(50))

INSERT INTO @test_var (PersonID, PetName)
VALUES (1, 'Alice'), (2, 'Jacky'), (3, 'Layka')

SELECT * FROM @test_Var

SELECT *
FROM #test AS test
JOIN Application.People AS P ON P.PersonID = test.PersonID

SELECT *
FROM @test_var AS test
JOIN Application.People AS P ON P.PersonID = test.PersonID

---------------------------------------
drop table if exists #test
CREATE TABLE #test (PersonID INT PRIMARY KEY, PetName VARCHAR(50));

---------------------------------------
INSERT INTO #test (PersonID, PetName)
SELECT PersonID, RIGHT(PreferredName, 4)
FROM Application.People;

DECLARE @test_var TABLE (PersonID INT PRIMARY KEY, PetName VARCHAR(50));

INSERT INTO @test_var (PersonID, PetName)
SELECT PersonID, RIGHT(PreferredName, 4)
FROM Application.People;

SELECT *
FROM #test AS test
JOIN Application.People AS P ON P.PersonID = test.PersonID;

SELECT *
FROM @test_var AS test
JOIN Application.People AS P ON P.PersonID = test.PersonID;

---
-- в каких из этих 3 таблиц могут быть индексы ?
create table #T1 (a int, b int)
create table ##T2 (a int, b int) 
declare @T3 table (a int, b int) 