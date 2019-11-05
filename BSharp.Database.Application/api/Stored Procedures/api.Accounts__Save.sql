﻿CREATE PROCEDURE [api].[Accounts__Save]
	@DefinitionId NVARCHAR (255),
	@Entities [dbo].[AccountList] READONLY,
	@ReturnIds BIT = 0,
	@ValidationErrorsJson NVARCHAR(MAX) OUTPUT
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @ValidationErrors [dbo].[ValidationErrorList];
	DECLARE @FilledAccounts [dbo].[AccountList];

	INSERT INTO @FilledAccounts
	SELECT * FROM @Entities;
	--EXEC bll.Accounts__Fill
	--	@DefinitionId = @DefinitionId,
	--	@Accounts = @Accounts;

	INSERT INTO @ValidationErrors
	EXEC [bll].[Accounts_Validate__Save]
		@DefinitionId = @DefinitionId,
		@Entities = @FilledAccounts;

	SELECT @ValidationErrorsJson = 
	(
		SELECT *
		FROM @ValidationErrors
		FOR JSON PATH
	);

	IF @ValidationErrorsJson IS NOT NULL
		RETURN;

	EXEC [dal].[Accounts__Save]
		@DefinitionId = @DefinitionId,
		@Entities = @FilledAccounts,
		@ReturnIds = @ReturnIds;
END;