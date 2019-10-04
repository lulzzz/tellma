﻿CREATE FUNCTION [dbo].[fn_UnitName__Id] (
	@Name NVARCHAR(50)
)
RETURNS INT
AS
BEGIN
	RETURN 	(
		SELECT [Id] FROM [dbo].MeasurementUnits
		WHERE [Name] = @Name
	)
END
