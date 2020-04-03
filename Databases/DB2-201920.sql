-- Create the database:
create database [BD2-201920]
go

-- Use Database
use [BD2-201920]
go

-- Create Table DimDate
create table DimDate(
	DateID Date not null,
	Year int,
	Month smallint,
	Day smallint,
	MonthName nvarchar(15),
	WeekdayName nvarchar(15),
	constraint PK_DimDate primary key (DateID)
)

-- Create Table DimProduct
create table DimProduct(
	ProductID int not null,
	Name nvarchar(50),
	ProductNumber nvarchar(25),
	ProductLine nchar(2),
	StandardPrice money,
	ListedPrice money,
	Category nvarchar(50),
	SubCategory nvarchar(50),
	constraint PK_DimProduct primary key (ProductID)
)

-- Create Table FactProductInventory
create table FactProductInventory (
	ProductInventoryID int identity (1, 1) not null,
	ProductID int not null,
	DateID date not null,
	MovementDate date not null,
	UnitCost money not null,
	UnitsIn int not null,
	UnitsOut int not null,
	UnitsBalance int not null,
	constraint PK_FactProductInventory primary key (ProductInventoryID),
	constraint FK_FactProductInventory_DimProduct foreign key (ProductID) references DimProduct (ProductID),
	constraint FK_FactProductInventory_DimDate foreign key (DateID) references DimDate (DateID)
)