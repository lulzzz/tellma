﻿CREATE PROCEDURE [bll].[AccountClassifications_Validate__DeleteWithDescendants]
	@Ids [IndexedIdList] READONLY,
	@Top INT = 10
AS
	EXEC [bll].[AccountClassifications_Validate__Delete] @Ids = @Ids, @Top = @Top;