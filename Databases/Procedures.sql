create procedure AddRow(@Type int, @ProductID int, @DateID date, @Quantity decimal, @UnitPrice money) as
begin
	declare @UnitsBalance int
	declare @UnitsIn int
	declare @UnitsOut int
	declare @UnitCost money
	declare @NewUnitCost money

	set nocount on

	select top 1 @UnitsBalance = UnitsBalance
	from [BD2-201920].dbo.FactProductInventory
	where ProductID = @ProductID and DateID = @DateID

	select top 1 @UnitsIn = UnitsIn, @UnitsOut = UnitsOut
	from [BD2-201920].dbo.FactProductInventory
	where ProductID = @ProductID and DateID = @DateID

	if @@ROWCOUNT = 0
	begin
		set @UnitsBalance = 0

		if @Type = 0
		begin
			insert into [BD2-201920].dbo.FactProductInventory(ProductID, DateID, MovementDate, UnitCost, UnitsIn, UnitsOut, UnitsBalance)
			values (@ProductID, @DateID, @DateID, @UnitPrice, @Quantity, 0, @Quantity)
		end
		else begin
			insert into [BD2-201920].dbo.FactProductInventory(ProductID, DateID, MovementDate, UnitCost, UnitsIn, UnitsOut, UnitsBalance)
			values (@ProductID, @DateID, @DateID, @UnitPrice, 0, @Quantity, @Quantity)
		end
	end
	else begin
		if @UnitPrice <> 0
		begin
			set @NewUnitCost = (@Quantity + @UnitsIn) / (@UnitCost + @UnitPrice)
		end

		if @Type = 0
		begin
			update [BD2-201920].dbo.FactProductInventory
			set UnitsIn = @UnitsIn + @Quantity, UnitsBalance = @UnitsBalance + @Quantity
			where ProductID = @ProductID and DateID = @DateID
		end
		else begin
			update [BD2-201920].dbo.FactProductInventory
			set UnitsOut = @UnitsOut - @Quantity, UnitsBalance = @UnitsBalance - @Quantity
			where ProductID = @ProductID and DateID = @DateID
		end
	end
end
go

create procedure AddAll(@lastDate date) as
begin
	declare myCursor cursor for
		select *
		from (
			select 0 as Type, ModifiedDate as DateID, ProductID, Quantity, 0 as UnitPrice
			from AdventureWorks2012.Production.ProductInventory
			where ModifiedDate > @lastDate and Quantity > 0
			union all
			select 0 as Type, DueDate as DateID, ProductID, StockedQty as Quantity, UnitPrice
			from AdventureWorks2012.Purchasing.PurchaseOrderDetail
			where DueDate > @lastDate and StockedQty > 0
			union all
			select 1 as Type, ModifiedDate as DateID, ProductID, OrderQty as Quantity, 0 as UnitPrice
			from AdventureWorks2012.Sales.SalesOrderDetail
			where ModifiedDate > @lastDate and OrderQty > 0
		) as AllRecords
		order by DateID

	declare @Type int
	declare @ProductID int
	declare @DateID date
	declare @Quantity int
	declare @UnitPrice money

	open myCursor
	fetch next from myCursor into @Type, @DateID, @ProductID, @Quantity, @UnitPrice

	while @@FETCH_STATUS = 0
	begin
		exec AddRow @Type, @ProductID, @DateID, @Quantity, @UnitPrice
		fetch next from myCursor into @Type, @DateID, @ProductID, @Quantity, @UnitPrice
	end

	close myCursor
	deallocate myCursor
end
go