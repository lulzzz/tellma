﻿CREATE FUNCTION [map].[Entries]()
RETURNS TABLE
AS
RETURN (
	SELECT * FROM [dbo].[Entries]
);
