CREATE DATABASE Adventureworks2019DW
GO
USE Adventureworks2019DW
GO

CREATE TABLE DimDate(
    DateKey int PRIMARY KEY NOT NULL ,
    FullDate date NOT NULL,
	DayName nvarchar(30),
    DayNumberOfWeek int,
    DayNumberOfMonth int,
    DayNumberOfYear int,
    WeekNumberOfYear int,
    MonthName nvarchar(30),
    MonthNumberOfYear int,
	Quarter varchar(2),
	QuarterName varchar(15),
    Year int
);

--DimDate
INSERT INTO DimDate(DateKey, FullDate, DayName, DayNumberOfWeek, DayNumberOfMonth, DayNumberOfYear, WeekNumberOfYear, MonthName,
MonthNumberOfYear, Quarter, QuarterName, Year)
SELECT DISTINCT
    CONVERT(int,CONVERT(varchar,orderdate,112)) AS DateKey,
    CONVERT(date,orderdate) AS FullDate,
    DATENAME(dw, orderdate) AS DayName,
    DATEPART(dw,orderdate) AS DayNumberOfWeek,
    DATEPART(d,orderdate) AS DayNumberOfMonth,
    DATEPART(dy,orderdate) AS DayNumberOfYear,
    DATEPART(wk, orderdate) AS WeekNumberOfYear,
    DATENAME(month, orderdate) AS MonthName,
    MONTH(orderdate) AS MonthNumberOfYear,
    CASE 
        WHEN MONTH(orderdate) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MONTH(orderdate) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MONTH(orderdate) BETWEEN 7 AND 9 THEN 'Q3'
        ELSE 'Q4'
    END AS Quarter,
    CASE 
        WHEN MONTH(orderdate) BETWEEN 1 AND 3 THEN 'First Quarter'
        WHEN MONTH(orderdate) BETWEEN 4 AND 6 THEN 'Second Quarter'
        WHEN MONTH(orderdate) BETWEEN 7 AND 9 THEN 'Third Quarter'
        ELSE 'Fourth Quarter'
    END AS QuarterName,
    YEAR(orderdate) AS Year

FROM AdventureWorks2019.Sales.SalesOrderHeader


----------------------------------------------------------------------------

CREATE TABLE DimDatePurchasing(
	DateKey int PRIMARY KEY  ,
    FullDate date NOT NULL,
	DayName nvarchar(30),
    DayNumberOfWeek int,
    DayNumberOfMonth int,
    DayNumberOfYear int,
    WeekNumberOfYear int,
    MonthName nvarchar(30),
    MonthNumberOfYear int,
	Quarter varchar(2),
	QuarterName varchar(15),
    Year int
);

--DimDatePurchasing
INSERT INTO DimDatePurchasing(DateKey, FullDate, DayName, DayNumberOfWeek, DayNumberOfMonth, DayNumberOfYear, WeekNumberOfYear, MonthName,
MonthNumberOfYear, Quarter, QuarterName, Year)
SELECT DISTINCT
    CONVERT(int,CONVERT(varchar,orderdate,112)) AS DateKey,
    CONVERT(date,orderdate) AS FullDate,
    DATENAME(dw, orderdate) AS DayName,
    DATEPART(dw,orderdate) AS DayNumberOfWeek,
    DATEPART(d,orderdate) AS DayNumberOfMonth,
    DATEPART(dy,orderdate) AS DayNumberOfYear,
    DATEPART(wk, orderdate) AS WeekNumberOfYear,
    DATENAME(month, orderdate) AS MonthName,
    MONTH(orderdate) AS MonthNumberOfYear,
    CASE 
        WHEN MONTH(orderdate) BETWEEN 1 AND 3 THEN 'Q1'
        WHEN MONTH(orderdate) BETWEEN 4 AND 6 THEN 'Q2'
        WHEN MONTH(orderdate) BETWEEN 7 AND 9 THEN 'Q3'
        ELSE 'Q4'
    END AS Quarter,
    CASE 
        WHEN MONTH(orderdate) BETWEEN 1 AND 3 THEN 'First Quarter'
        WHEN MONTH(orderdate) BETWEEN 4 AND 6 THEN 'Second Quarter'
        WHEN MONTH(orderdate) BETWEEN 7 AND 9 THEN 'Third Quarter'
        ELSE 'Fourth Quarter'
    END AS QuarterName,
    YEAR(orderdate) AS Year
from AdventureWorks2019.Purchasing.PurchaseOrderHeader;

----------------------------------------------------------------------------

CREATE TABLE DimCustomer(
    CustomerKey int IDENTITY(1,1) PRIMARY KEY,
    CustomerID int NOT NULL,
    TerritoryID int NOT NULL,
    FullName nvarchar(255),
    Phone nvarchar(25),
    EmailAddress nvarchar(255),
    Address nvarchar(255),
    StoreName nvarchar(255),
    rowguid uniqueidentifier NOT NULL,
    ModifiedDate datetime NOT NULL
);

--DimCustomer
INSERT INTO DimCustomer( CustomerID, TerritoryID, Fullname, Phone, EmailAddress, StoreName, Address, rowguid, ModifiedDate)
SELECT C.CustomerID as CustomerID,C.TerritoryID as TerritoryID, P.FirstName+' '+P.LastName as FullName,COALESCE(PP.PhoneNumber, '') as Phone, E.EmailAddress as EmailAddress, 
COALESCE(S.Name, 'No store information') as StoreName, COALESCE(A.AddressLine1, '') + ', ' + COALESCE(A.City, '') + ', ' + COALESCE(SP.Name, '') as Address,
 C.rowguid as rowguid , C.ModifiedDate as ModifiedDate
FROM AdventureWorks2019.Sales.Customer C 
LEFT JOIN AdventureWorks2019.Sales.Store S ON C.StoreID = S.BusinessEntityID 
LEFT JOIN AdventureWorks2019.Person.Person P ON P.BusinessEntityID = C.PersonID
LEFT JOIN AdventureWorks2019.Person.EmailAddress E ON E.BusinessEntityID = P.BusinessEntityID
LEFT JOIN AdventureWorks2019.Person.BusinessEntityAddress BEA ON BEA.BusinessEntityID = C.PersonID
LEFT JOIN AdventureWorks2019.Person.Address A ON A.AddressID = BEA.AddressID
LEFT JOIN AdventureWorks2019.Person.StateProvince SP ON SP.StateProvinceID = A.StateProvinceID
LEFT JOIN AdventureWorks2019.Person.PersonPhone PP ON PP.BusinessEntityID = C.PersonID;


----------------------------------------------------------------------------


CREATE TABLE DimProduct(
    ProductKey int IDENTITY(1,1) PRIMARY KEY,
    ProductID int  ,
    ProductNumber nvarchar(255) ,
    ProductName nvarchar(255) ,
    ListPrice money ,
	StandardCost money , --chi phi san xuat
    Size nvarchar(10),
    Weight decimal (8,2),
    Color nvarchar(255),
	SellStartDate date,
	SellEndDate date ,
    ProductSubCategoryID int,
    ProductCategoryID int,
    rowguid uniqueidentifier ,
    ModifiedDate datetime 
);

INSERT INTO DimProduct(ProductID,ProductNumber,ProductName,ListPrice,StandardCost,Size,Weight,
Color,SellStartDate,SellEndDate,ProductCategoryID,ProductSubCategoryID,rowguid,ModifiedDate)
SELECT P.ProductID,P.ProductNumber, P.Name as ProductName,P.ListPrice,P.StandardCost,P.Size,P.Weight,P.Color,P.SellStartDate,P.SellEndDate, P.ProductSubCategoryID, PC.ProductCategoryID
,P.rowguid as rowguid, P.ModifiedDate as ModifiedDate
FROM AdventureWorks2019.Production.Product P 
LEFT JOIN AdventureWorks2019.Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
LEFT JOIN AdventureWorks2019.Production.ProductCategory PC ON PC.ProductCategoryID = PS.ProductCategoryID;

----------------------------------------------------------------------------


CREATE TABLE DimEmployee(
    EmployeeKey int IDENTITY(1,1) PRIMARY KEY,
    EmployeeID int NOT NULL,
	Fullname nvarchar(255) ,
	OrganizationLevel int,
	NationalI DNumber nvarchar(15) , 
	BirthDate date,
	Gender nchar(1),
	MaritalStatus nchar(1),
	HireDate date ,
	JobTitle nvarchar(255),
    rowguid uniqueidentifier ,
    ModifiedDate datetime 
);

--DimEmployee
INSERT INTO DimEmployee(EmployeeID,Fullname,OrganizationLevel,NationalIDNumber,BirthDate,Gender,
MaritalStatus,HireDate,JobTitle,rowguid,ModifiedDate)
SELECT E.BusinessEntityID as EmployeeID, 
	P.FirstName+' '+ P.LastName as Fullname,
	E.OrganizationLevel as OrganizationLevel,
	E.NationalIDNumber as NationalIDNumber,
	E.BirthDate as BirthDate,
	E.Gender as Gender,
	E.MaritalStatus as MaritalStatus,
	E.HireDate as HireDate, 
	E.JobTitle as JobTitle,
    E.rowguid as rowguid,
    E.ModifiedDate as ModifiedDate
FROM AdventureWorks2019.HumanResources.Employee E, 
	AdventureWorks2019.Person.Person P
WHERE E.BusinessEntityID = P.BusinessEntityID;


----------------------------------------------------------------------------

CREATE TABLE DimShip(
    ShipKey int IDENTITY(1,1) PRIMARY KEY,
    ShipMethodID int,
    Name nvarchar(255),
    ShipBase float,
    ShipRate float,
    rowguid uniqueidentifier NOT NULL,
    ModifiedDate datetime NOT NULL
);

--DimShip
INSERT INTO DimShip(ShipMethodID,Name,ShipBase,ShipRate,rowguid,ModifiedDate)
SELECT ShipMethodID as ShipMethodID, Name as Name, ShipBase as ShipBase, ShipRate as ShipRate, 
rowguid as rowguid , ModifiedDate as ModifiedDate
FROM AdventureWorks2019.Purchasing.ShipMethod;

----------------------------------------------------------------------------



CREATE TABLE DimProductSubCategory(
    ProductSubcategoryKey int IDENTITY(1,1) PRIMARY KEY,
    ProductSubCategoryID int,
    Name nvarchar(255),
    rowguid uniqueidentifier NOT NULL,
    ModifiedDate datetime NOT NULL
);

--DimProductSubCategory
INSERT INTO DimProductSubCategory(ProductSubCategoryID,Name, rowguid,ModifiedDate)
SELECT ProductSubcategoryID as ProductSubCategoryID, Name as Name, rowguid,ModifiedDate
FROM AdventureWorks2019.Production.ProductSubcategory
ORDER BY ProductSubcategoryID;

----------------------------------------------------------------------------

CREATE TABLE DimProductCategory(
    ProductCategoryKey int IDENTITY(1,1) PRIMARY KEY,
    ProductCategoryID int,
    Name nvarchar(255),
    rowguid uniqueidentifier NOT NULL,
    ModifiedDate datetime NOT NULL
);

--DimProductCategory
INSERT INTO DimProductCategory(ProductCategoryID,Name,rowguid,ModifiedDate)
SELECT ProductCategoryID as ProductCategoryID, Name as CategoryName,
 rowguid as rowguid, ModifiedDate as ModifiedDate
FROM AdventureWorks2019.Production.ProductCategory;

----------------------------------------------------------------------------

CREATE TABLE DimCurrency(
    CurrencyKey int IDENTITY(1,1) PRIMARY KEY,
    CurrencyCode nchar(3),
    CurrencyName nvarchar(255),
    ModifiedDate datetime
);

--DimCurrency
INSERT INTO DimCurrency(CurrencyCode, CurrencyName,ModifiedDate)
SELECT CurrencyCode as CurrencyCode, Name as CurrencyName, ModifiedDate as ModifiedDate
FROM AdventureWorks2019.Sales.Currency;
 
----------------------------------------------------------------------------

CREATE TABLE DimTerritory(
    TerritoryKey int IDENTITY(1,1) PRIMARY KEY,
    TerritoryID int NOT NULL,
    Region nvarchar(255),
    Country nvarchar(255),
    CountryGroup nvarchar(255),
    rowguid uniqueidentifier ,
    ModifiedDate datetime 
);

--DimTerritory
INSERT INTO DimTerritory(TerritoryID,Region,Country,CountryGroup,rowguid,ModifiedDate)
SELECT S.TerritoryID as TerritoryID, S.Name as Region, R.Name as Country, S.[Group] as CountryGroup
,S.rowguid as rowguid, S.ModifiedDate as ModifiedDate
FROM AdventureWorks2019.Sales.SalesTerritory S, AdventureWorks2019.Person.CountryRegion R	
WHERE S.CountryRegionCode = R.CountryRegionCode;

----------------------------------------------------------------------------

CREATE TABLE DimVendor(
    VendorKey int IDENTITY(1,1) PRIMARY KEY,
    VendorID int NOT NULL,
    Name nvarchar(255),
    ModifiedDate datetime NOT NULL
);

--DimVendor
INSERT INTO DimVendor(VendorID,Name,ModifiedDate)
SELECT BusinessEntityID as VendorID, Name as Name,ModifiedDate as ModifiedDate
FROM AdventureWorks2019.Purchasing.Vendor;

----------------------------------------------------------------------------

CREATE TABLE FactSale(
    SaleKey int IDENTITY(1,1) PRIMARY KEY not null,
    DateKey int ,
    CustomerKey int ,
    ShipKey int ,
    ProductKey int ,
    ProductCategoryKey int,
    ProductSubcategoryKey int,
    CurrencyKey int,
    TerritoryKey int ,
    SalesQty int ,
    UnitPrice money,
    TotalDue  money
);


--SELECT FACT TABLE
INSERT INTO FactSale(DateKey,CustomerKey,ShipKey,ProductKey,ProductCategoryKey,ProductSubCategoryKey,CurrencyKey,TerritoryKey,SalesQty,UnitPrice,TotalDue)
SELECT D.DateKey,
	Cs.CustomerKey as CustomerKey,
	S.ShipKey as ShipKey,
	P.ProductKey as ProductKey,
	PC.ProductCategoryKey as ProductCategoryKey,
	PSC.ProductSubcategoryKey as ProductSubcategoryKey,
	C.CurrencyKey as CurrencyKey,
	T.TerritoryKey as TerritoryKey,
	SD.OrderQty as SalesQty,
	SD.UnitPrice as UnitPrice,
	(SD.OrderQty*SD.UnitPrice) as TotalDue
FROM AdventureWorks2019.Sales.SalesOrderHeader SH 
	LEFT JOIN AdventureWorks2019.Sales.SalesOrderDetail SD
	ON SH.SalesOrderID = SD.SalesOrderID
	LEFT JOIN AdventureWorks2019DW.dbo.DimCustomer Cs ON Cs.CustomerID = SH.CustomerID
	LEFT JOIN AdventureWorks2019DW.dbo.DimProduct P ON P.ProductID = SD.ProductID
	LEFT JOIN AdventureWorks2019DW.dbo.DimProductSubCategory PSC ON PSC.ProductSubCategoryID = P.ProductSubCategoryID
	LEFT JOIN AdventureWorks2019DW.dbo.DimTerritory T ON T.TerritoryID = SH.TerritoryID
	LEFT JOIN AdventureWorks2019DW.dbo.DimShip S ON S.ShipMethodID = SH.ShipMethodID
	LEFT JOIN AdventureWorks2019DW.dbo.DimDate D ON D.DateKey = CONVERT(INT,CONVERT(VARCHAR,SH.OrderDate,112))
	LEFT JOIN AdventureWorks2019.Sales.CurrencyRate CR ON CR.CurrencyRateID = SH.CurrencyRateID
	LEFT JOIN AdventureWorks2019DW.dbo.DimCurrency C ON CR.ToCurrencyCode COLLATE Latin1_General_CS_AS = C.CurrencyCode COLLATE Latin1_General_CS_AS
	LEFT JOIN AdventureWorks2019DW.dbo.DimProductCategory PC ON PC.ProductCategoryID = P.ProductCategoryID;

----------------------------------------------------------------------------

CREATE TABLE FactPurchasing(
    PurchasingKey int IDENTITY(1,1) PRIMARY KEY NOT NUll,
    DateKey int NOT NULL,
    ShipKey int NOT NULL,
    ProductKey int NOT NULL,
    ProductCategoryKey int,
    ProductSubcategoryKey int,
	VendorKey int,
	EmployeeKey int NOT NULL,
    UnitPrice money NOT NULL,
    ReceivedQty int,
    RejectedQty int,
	StockedQty int,
	OrderQty int ,
	TotalDue money NOT NULL
 );

--FactPurchasing
INSERT INTO FactPurchasing(DateKey,ShipKey,ProductKey,ProductCategoryKey,ProductSubcategoryKey,VendorKey,EmployeeKey,UnitPrice,ReceivedQty,RejectedQty,StockedQty
,OrderQty,TotalDue)
SELECT D.DateKey,
	S.ShipKey as ShipKey,
	P.ProductKey as ProductKey,
	PC.ProductCategoryKey as ProductCategoryKey,
	PSC.ProductSubcategoryKey as ProductSubcategoryKey,
	V.VendorKey as VendorKey,
	E.EmployeeKey as EmployeeKey,
	PD.UnitPrice as UnitPrice,
	PD.ReceivedQty,
	PD.RejectedQty,
	PD.StockedQty,
	PD.OrderQty,
	(PD.StockedQty*PD.UnitPrice) as TotalDue
FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader PH 
	LEFT JOIN AdventureWorks2019.Purchasing.PurchaseOrderDetail PD
	ON PH.PurchaseOrderID = PD.PurchaseOrderID
	LEFT JOIN AdventureWorks2019DW.dbo.DimProduct P ON P.ProductID = PD.ProductID
	LEFT JOIN AdventureWorks2019DW.dbo.DimProductSubCategory PSC ON PSC.ProductSubCategoryID = P.ProductSubCategoryID
	LEFT JOIN AdventureWorks2019DW.dbo.DimShip S ON S.ShipMethodID = PH.ShipMethodID
	LEFT JOIN AdventureWorks2019DW.dbo.DimDatePurchasing D ON D.DateKey = CONVERT(INT,CONVERT(VARCHAR,PH.OrderDate,112))
	LEFT JOIN AdventureWorks2019DW.dbo.DimVendor V ON V.VendorID = PH.VendorID
	LEFT JOIN AdventureWorks2019DW.dbo.DimEmployee E ON E.EmployeeID = PH.EmployeeID
	LEFT JOIN AdventureWorks2019DW.dbo.DimProductCategory PC ON PC.ProductCategoryID = P.ProductCategoryID;


-----------------------------------------

ALTER TABLE FactSale
ADD CONSTRAINT FK_FactSale_DimProductCategory
FOREIGN KEY (ProductCategoryKey)
REFERENCES DimProductCategory(ProductCategoryKey);

ALTER TABLE FactSale
ADD CONSTRAINT FK_FactSale_DimProductSubCategory
FOREIGN KEY (ProductSubCategoryKey)
REFERENCES DimProductSubCategory(ProductSubCategoryKey);

ALTER TABLE FactSale
ADD CONSTRAINT FK_FactSale_DimCustomer
FOREIGN KEY (CustomerKey)
REFERENCES DimCustomer(CustomerKey);

ALTER TABLE FactSale
ADD CONSTRAINT FK_FactSale_DimShip
FOREIGN KEY (ShipKey)
REFERENCES DimShip(ShipKey);

ALTER TABLE FactSale
ADD CONSTRAINT FK_FactSale_DimProduct
FOREIGN KEY (ProductKey)
REFERENCES DimProduct(ProductKey);

ALTER TABLE FactSale
ADD CONSTRAINT FK_FactSale_DimCurrency
FOREIGN KEY (CurrencyKey)
REFERENCES DimCurrency(CurrencyKey);

ALTER TABLE FactSale
ADD CONSTRAINT FK_FactSale_DimTerritory
FOREIGN KEY (TerritoryKey)
REFERENCES DimTerritory(TerritoryKey);

ALTER TABLE FactSale
ADD CONSTRAINT FK_FactSale_DimDate
FOREIGN KEY (DateKey)
REFERENCES DimDate(DateKey);

------------------------------------------

ALTER TABLE FactPurchasing
ADD CONSTRAINT FK_FactPurchasing_DimDatePurchasing
FOREIGN KEY (DateKey)
REFERENCES DimDatePurchasing(DateKey);


ALTER TABLE FactPurchasing
ADD CONSTRAINT FK_FactPurchasing_DimShip
FOREIGN KEY (ShipKey)
REFERENCES DimShip(ShipKey);

ALTER TABLE FactPurchasing
ADD CONSTRAINT FK_FactPurchasing_DimProduct
FOREIGN KEY (ProductKey)
REFERENCES DimProduct(ProductKey);

ALTER TABLE FactPurchasing
ADD CONSTRAINT FK_FactPurchasing_DimProductCategory
FOREIGN KEY (ProductCategoryKey)
REFERENCES DimProductCategory(ProductCategoryKey);

ALTER TABLE FactPurchasing
ADD CONSTRAINT FK_FactPurchasing_DimProductSubCategory
FOREIGN KEY (ProductSubCategoryKey)
REFERENCES DimProductSubCategory(ProductSubCategoryKey);


ALTER TABLE FactPurchasing
ADD CONSTRAINT FK_FactPurchasing_DimVendor
FOREIGN KEY (VendorKey)
REFERENCES DimVendor(VendorKey);


ALTER TABLE FactPurchasing
ADD CONSTRAINT FK_FactPurchasing_DimEmployee
FOREIGN KEY (EmployeeKey)
REFERENCES DimEmployee(EmployeeKey);