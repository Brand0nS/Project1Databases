--Brandon 20 Queries
--Query #1

--Simple Query #1
USE Northwinds2022TSQLV7;  
SELECT  orderid, orderdate, CustomerId, EmployeeId 
From Sales.[Order]
WHERE orderdate=(SELECT MAX(orderdate) FROM Sales.[Order])
ORDER BY orderdate DESC
FOR JSON PATH, ROOT('Sales');

--Simple Query #2

USE AdventureWorks2017;
SELECT P.FirstName, P.LastName,  E.Gender, E.BirthDate 
FROM HumanResources.[Employee] AS E 
  INNER JOIN Person.[Person] AS P  
    ON E.Gender = P.FirstName
	WHERE YEAR(E.BirthDate) < 1960
FOR JSON PATH, ROOT('Sales');




--Simple Query #3

USE WideWorldImportersDW;
SELECT [Sale Key], [City Key], (Quantity*[Unit Price]) AS price
FROM Fact.[Sale]
for json path, root(' Fact '), include_null_values; 


--Simple Query #4
USE Northwinds2022TSQLV7;
-- Customers from Spain who placed orders
SELECT customerID, CustomerCompanyName
FROM Sales.[Customer] AS C 
WHERE CustomerCompanyName = N'Spain'
  AND EXISTS
    (SELECT * FROM Sales.[Order] AS O
     WHERE O.customerID = C.customerID)
	 for json path, root(' Sales '), include_null_values; 



--Simple Query #5

USE WideWorldImporters;
-- Comparison operators: =, >, <, >=, <=, <>, !=, !>, !< 
SELECT orderid, orderdate
FROM Sales.Orders
WHERE orderdate >= '20160101'
for json path, root(' Sales '), include_null_values; 



--Medium Query #1
USE Northwinds2022TSQLV7
SELECT
  C.CustomerId, C.CustomerCompanyName, O.OrderId,  --Returns customerid, company name, orderid
  O2.orderdate, O2.EmployeeId  -- productid and quantity, from the Customer and Order table from Sales.
FROM Sales.[Customer] AS C  --Maps Customer to Order, and OrderDetail.
  INNER JOIN Sales.[Order] AS O
    ON C.CustomerId = O.CustomerId
  FULL JOIN Sales.[Order2] AS O2
    ON O.orderid = O2.orderid;



--Medium Query #2

USE Northwinds2022TSQLV7;
SELECT
  C.CustomerId, C.CustomerCompanyName, O.orderid,
  OD.productid, OD.Quantity
FROM Sales.[Customer] AS C
  INNER JOIN Sales.[Order] AS O
    ON C.CustomerId = O.CustomerId
  INNER JOIN Sales.[OrderDetail] AS OD
    ON O.orderid = OD.orderid
	for json path, root(' sales '), include_null_values; 



--Medium Query #3

SELECT C.CustomerId, C.CustomerCompanyName, O.orderid
FROM Sales.[Customer] AS C
  LEFT OUTER JOIN Sales.[Order] AS O
    ON C.CustomerId = O.CustomerId
	for json path, root(' Sales '), include_null_values; 


--Medium Query #4
USE Northwinds2022TSQLV7;
SELECT orderid, orderdate, EmployeeID, customerID,
  (SELECT MAX(O2.orderid)
   FROM Sales.[Order] AS O2
   WHERE O2.orderid < O1.orderid) AS prevorderid
FROM Sales.[Order] AS O1
for json path, root(' Sales '), include_null_values; 




--Medium Query #5
USE Northwinds2022TSQLV7;
SELECT C.customerid, COUNT(*) AS numorders
FROM Sales.[Customer] AS C
  LEFT OUTER JOIN Sales.[Order] AS O
    ON C.CustomerId = O.CustomerId
GROUP BY C.CustomerId
for json path, root(' Sales '), include_null_values; 


--Medium Query #6
USE Northwinds2022TSQLV7;

SELECT TOP (5)
E.EmployeeId, C.CustomerID, E.ShipToAddress
FROM Sales.[Order] AS E
RIGHT OUTER JOIN  Sales.Customer AS C
ON C.CustomerId = E.CustomerId
for json path, root('Sales'), include_null_values; 



--Medium Query #7
--
USE Northwinds2022TSQLV7;
SELECT C.customerId, O.orderid, OD.productid, OD.Quantity
FROM Sales.[Order] AS O
  INNER JOIN Sales.[OrderDetail] AS OD
    ON O.orderid = OD.orderid
  RIGHT OUTER JOIN Sales.[Customer] AS C
     ON O.customerid = C.CustomerId
	 for json path, root(' Sales '), include_null_values; 




--Medium Query #8
USE AdventureWorksDW2017
SELECT P.ProductKey, P.EnglishDescription, P.Weight 
FROM dbo.DimProduct AS P 
FULL JOIN dbo.FactAdditionalInternationalProductDescription AS F
ON P.ProductKey = F.ProductKey
ORDER BY P.ProductKey
 for json path, root(' dbo '), include_null_values; 


--Complex Query #1


USE Northwinds2022TSQLV7;
GO


DROP FUNCTION IF EXISTS Sales.CustomerNumbers;
GO

CREATE FUNCTION  Sales.CustomerNumbers (@orderid AS INT)
RETURNS TABLE
AS
RETURN 

SELECT TOP (20) 
C.CustomerId, 
C.CustomerPhoneNumber, 
O.OrderDate,
O.orderid,
OD.productid,
OD.Quantity
FROM Sales.[Order] AS O
  INNER JOIN Sales.[OrderDetail] AS OD
    ON O.orderid = OD.orderid
  RIGHT OUTER JOIN Sales.[Customer] AS C
     ON O.CustomerId = C.CustomerId


GO
    SELECT CustomerId,
	       CustomerPhoneNumber,
           OrderDate,
		   OrderId,
		   ProductId,
		   Quantity
From Sales.CustomerNumbers(6)
 for json path, root(' Sales '), include_null_values; 












--Complex Query #2


USE Northwinds2022TSQLV7;
GO
DROP FUNCTION IF EXISTS Production;
GO
CREATE FUNCTION  Production (@product AS NVARCHAR)
RETURNS TABLE
AS
RETURN 

SELECT O.OrderDate, HR.EmployeeFirstName, P.OrderId,P.UnitPrice
FROM Sales.[Order] AS O
  FULL JOIN HumanResources.[Employee] AS HR
    ON O.EmployeeId = HR.EmployeeId
  FULL JOIN Sales.OrderDetail AS P
     ON O.OrderId = P.OrderId


GO
    SELECT EmployeeFirstName,
           OrderDate,
		   OrderId,
		   UnitPrice
    From Production('HHYDP')
	Where EmployeeFirstName = N'S'
	 for json path, root(' Sales '), include_null_values;


--Complex Query #3


USE Northwinds2022TSQLV7;
GO
DROP FUNCTION IF EXISTS TripleJoin;
GO
CREATE FUNCTION  TripleJoin (@p1 AS INT)
RETURNS TABLE
AS
RETURN 

SELECT C.CustomerId, O.orderid, OD.productid, OD.Quantity,S.shipperid,S.ShipperCompanyName
FROM Sales.[Order] AS O
  INNER JOIN Sales.[OrderDetail] AS OD
    ON O.orderid = OD.orderid
  RIGHT OUTER JOIN Sales.[Customer] AS C
     ON O.CustomerId = C.CustomerId
	FULL JOIN Sales.[Shipper] AS S
	ON S.shipperid = O.orderid



GO
    SELECT CustomerId,
           orderid
		   shipperid
    From TripleJoin(6)
	 for json path, root(' Sales '), include_null_values;


--Complex Query #4



USE WideWorldImportersDW;
GO


DROP FUNCTION IF EXISTS PriceWePaid;
GO
CREATE FUNCTION  PriceWePaid (@p1 AS INT)
RETURNS TABLE
AS
RETURN 

SELECT
S.[Customer Key],
S.[Unit Price], 
S.Quantity,
S.Profit, 
(S.[Unit Price]-(S.[Profit] /S.[Quantity] )) AS StockPrice,
S.Description

FROM Fact.[Sale] AS S
  FULL JOIN Fact.[Transaction] AS T
    ON T.[Customer Key]= S.[Customer Key]
  INNER JOIN Fact.[Order] AS O
     ON S.[City Key] = O.[City Key]
	 WHERE S.[Customer Key]= @p1


GO
    SELECT TOP 1000
	      [Customer Key],
           [Unit Price],
		   Profit,
		   StockPrice,
		   Quantity
	    From PriceWePaid(292) 
		 for json path, root(' Sales '), include_null_values;
		 


--Complex Query #5


USE Northwinds2022TSQLV7;
GO
DROP FUNCTION IF EXISTS SalesFunction;
GO
CREATE FUNCTION  SalesFunction (@p1 AS INT)
RETURNS TABLE
AS
RETURN 

SELECT C.CustomerId, O.orderid, S.ShipperId
FROM Sales.[Order] AS O
  RIGHT OUTER JOIN Sales.[Shipper] AS S
    ON O.orderid = S.
  FULL JOIN Sales.[Customer] AS C
     ON O.CustomerId = C.CustomerId


GO
    SELECT CustomerId,
           orderid
	FROM SalesFunction(4)
    



--Complex Query #6

USE WideWorldImporters;
GO
DROP FUNCTION IF EXISTS countriesOfTheWorld;
GO
CREATE FUNCTION  countriesOfTheWorld (@city AS BIGINT)
RETURNS TABLE
AS
RETURN 

SELECT 
StateProvinceID,
CityID,
CityName,
Location,
LatestRecordedPopulation


FROM Application.Cities_Archive
WHERE LatestRecordedPopulation = @city
GO

    SELECT TOP (30)
	CO.Continent,
	CO.Region,
	CO.Subregion,
	CO.Border,
	CO.CountryType,
	CO.LatestRecordedPopulation
    From Application.Countries_Archive AS CO
	CROSS APPLY countriesOfTheWorld(947) AS CT
	FULL JOIN Application.StateProvinces_Archive AS SP
	ON CT.LatestRecordedPopulation=SP.LatestRecordedPopulation
	
	





--Complex Query #7



USE Northwinds2022TSQLV7;
GO
DROP FUNCTION IF EXISTS Sales.CustomerNumbers2;
GO
CREATE FUNCTION  Sales.CustomerNumbers2 (@CustomerId AS INT)
RETURNS TABLE
AS
RETURN 

SELECT CustomerId,
        o.OrderId, 
		productid, 
		Quantity,
		OrderDate,
		ShipToCountry
FROM Sales.[Order] as O
CROSS JOIN Sales.OrderDetail 
WHERE CustomerId = @CustomerId
GO

SELECT O2.orderid productid, 
		Quantity,
		O2.orderdate,
		ShipToCountry
FROM Sales.Order2 as O2
CROSS APPLY Sales.CustomerNumbers2(O2.orderid)
  INNER JOIN Sales.[Customer] AS C
     ON O2.CustomerId = C.CustomerId
	

GO
