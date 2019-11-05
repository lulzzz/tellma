﻿CREATE PROCEDURE [api].[AccountClassifications__Deprecate]
	@IndexedIds [dbo].[IndexedIdList] READONLY,
	@IsDeprecated BIT,
	@ValidationErrorsJson NVARCHAR(MAX) OUTPUT
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @ValidationErrors [dbo].[ValidationErrorList], @Ids [dbo].[IdList];
	
	INSERT INTO @ValidationErrors
	EXEC [bll].[AccountClassifications_Validate__Deprecate]
		@Ids = @IndexedIds;
	
	SELECT @ValidationErrorsJson = 
	(
		SELECT *
		FROM @ValidationErrors
		FOR JSON PATH
	);

	IF @ValidationErrorsJson IS NOT NULL
		RETURN;

	INSERT INTO @Ids SELECT [Id] FROM @IndexedIds;
	EXEC [dal].[AccountClassifications__Deprecate]
		@Ids = @Ids,
		@IsDeprecated = @IsDeprecated;
END;