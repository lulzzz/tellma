﻿CREATE PROCEDURE [bll].[Lines_Validate__State_Update]
-- @Lines and @Entries are read from the database just before calling.
	@Lines LineList READONLY,
	@Entries EntryList READONLY,
	@ToState SMALLINT,
	@Top INT = 10
AS
	DECLARE @ValidationErrors [dbo].[ValidationErrorList]

	DECLARE @FieldList StringList;
	INSERT INTO @FieldList([Id]) VALUES
	(N'CurrencyId'),(N'AgentId'),(N'ResourceId'),(N'CenterId'),(N'EntryTypeId'),
	(N'DueDate'),( N'MonetaryValue'),( N'Quantity'),( N'UnitId'),( N'Time1'),
	(N'Time2'),(N'ExternalReference'),(N'AdditionalReference'),(N'NotedAgentId'),
	(N'NotedAgentName'),(N'NotedAmount'),(N'NotedDate');
	-- The @Field is required if Line State >= RequiredState of line def column
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
	SELECT TOP (@Top)
		N'[' + CAST(E.[DocumentIndex] AS NVARCHAR (255)) + N'].Lines[' +
			CAST(E.[LineIndex] AS NVARCHAR (255)) + N'].Entries[' + CAST(E.[Index] AS NVARCHAR(255)) + N'].' + FL.[Id],
		N'Error_TheField0IsRequired',
		dbo.fn_Localize(LDC.[Label], LDC.[Label2], LDC.[Label3]) AS [FieldName]
	FROM @Entries E
	CROSS JOIN @FieldList FL
	JOIN @Lines L ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
	JOIN [dbo].[LineDefinitionColumns] LDC ON LDC.LineDefinitionId = L.DefinitionId AND LDC.[TableName] = N'Entries' AND LDC.[EntryIndex] = E.[Index] AND LDC.[ColumnName] = FL.[Id]
	--LEFT JOIN [dbo].[Lines] BEL ON L.Id = BEL.Id
	--WHERE ISNULL(BEL.[State], 0) >= LDC.[RequiredState]
	WHERE @ToState >= LDC.[RequiredState]
	AND L.[DefinitionId] <> N'ManualLine'
	AND	(
		FL.Id = N'CurrencyId'			AND E.[CurrencyId] IS NULL OR
		FL.Id = N'AgentId'				AND E.[AgentId] IS NULL OR
		FL.Id = N'ResourceId'			AND E.[ResourceId] IS NULL OR
		FL.Id = N'CenterId'				AND E.[CenterId] IS NULL OR
		FL.Id = N'EntryTypeId'			AND E.[EntryTypeId] IS NULL OR
		FL.Id = N'DueDate'				AND E.[DueDate] IS NULL OR
		FL.Id = N'MonetaryValue'		AND E.[MonetaryValue] IS NULL OR
		FL.Id = N'Quantity'				AND E.[Quantity] IS NULL OR
		FL.Id = N'UnitId'				AND E.[UnitId] IS NULL OR
		FL.Id = N'Time1'				AND E.[Time1] IS NULL OR
		FL.Id = N'Time2'				AND E.[Time2] IS NULL OR
		FL.Id = N'ExternalReference'	AND E.[ExternalReference] IS NULL OR
		FL.Id = N'AdditionalReference'	AND E.[AdditionalReference] IS NULL OR
		FL.Id = N'NotedAgentId'			AND E.[NotedAgentId] IS NULL OR
		FL.Id = N'NotedAgentName'		AND E.[NotedAgentName] IS NULL OR
		FL.Id = N'NotedAmount'			AND E.[NotedAmount] IS NULL OR
		FL.Id = N'NotedDate'			AND E.[NotedDate] IS NULL
	) ;

	-- No Null account when moving to state 4
IF @ToState = 4 -- finalized
BEGIN
	-- for smart screens, account must be guessed by now
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0],[Argument1],[Argument2],[Argument3],[Argument4])
	SELECT TOP (@Top)
		'[' + CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' + CAST(E.[Index]  AS NVARCHAR (255))+ '].AccountId',
		N'Error_LineNoAccountForEntryIndex0WithAccountType1Currency2Agent3Resource4',
		L.[Index],
		LDE.[AccountTypeParentCode],
		E.[CurrencyId],
		dbo.fn_Localize(AG.[Name], AG.[Name2], AG.[Name3]),
		dbo.fn_Localize(R.[Name], R.[Name2], R.[Name3])
	FROM @Lines L
	JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
	LEFT JOIN dbo.LineDefinitionEntries LDE ON LDE.LineDefinitionId = L.DefinitionId AND LDE.[Index] = E.[Index]
	LEFT JOIN dbo.Agents AG ON E.AgentId = AG.Id
	LEFT JOIN dbo.Resources R ON E.ResourceId = R.Id
	WHERE L.DefinitionId <> N'ManualLine' 
	AND E.AccountId IS NULL
	AND (E.[Value] <> 0 OR E.[Quantity] IS NOT NULL AND E.[Quantity] <> 0)
	-- for manual JV, account must be entered
	INSERT INTO @ValidationErrors([Key], [ErrorName])
	SELECT TOP (@Top)
		'[' + CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' + CAST(E.[Index]  AS NVARCHAR (255))+ '].AccountId',
		N'Error_AccountIsRequired'
	FROM @Lines L
	JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
	WHERE L.DefinitionId = N'ManualLine' 
	AND E.AccountId IS NULL
	-- currency is required
	INSERT INTO @ValidationErrors([Key], [ErrorName])
	SELECT TOP (@Top)
		'[' + CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' + CAST(E.[Index]  AS NVARCHAR (255))+ '].CurrencyId',
		N'Error_CurrencyIsRequired'
	FROM @Lines L
	JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
	WHERE E.CurrencyId IS NULL
	-- Center is required
	INSERT INTO @ValidationErrors([Key], [ErrorName])
	SELECT TOP (@Top)
		'[' + CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' + CAST(E.[Index]  AS NVARCHAR (255))+ '].CenterId',
		N'Error_CenterIsRequired'
	FROM @Lines L
	JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
	WHERE E.CenterId IS NULL
	-- if Account / AgentDefinition is specified, AgentId is required
	INSERT INTO @ValidationErrors([Key], [ErrorName])
	SELECT TOP (@Top)
		'[' + CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' + CAST(E.[Index]  AS NVARCHAR (255))+ '].AgentId',
		N'Error_AgentIsRequired'
	FROM @Lines L
	JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
	JOIN dbo.Accounts A ON E.AccountId = A.[Id]
	WHERE A.AgentDefinitionId IS NOT NULL AND E.AgentId IS NULL
	-- if Account / HasResource = 1, ResourceId is required
	INSERT INTO @ValidationErrors([Key], [ErrorName])
	SELECT TOP (@Top)
		'[' + CAST(L.[Index] AS NVARCHAR (255)) + '].Entries[' + CAST(E.[Index]  AS NVARCHAR (255))+ '].ResourceId',
		N'Error_ResourceIsRequired'
	FROM @Lines L
	JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
	JOIN dbo.Accounts A ON E.AccountId = A.[Id]
	WHERE A.HasResource = 1 AND E.ResourceId IS NULL
END
	-- No deprecated account, for any positive state
IF @ToState > 0
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
	SELECT TOP (@Top)
		'[' + ISNULL(CAST(L.[Index] AS NVARCHAR (255)),'') + ']', 
		N'Error_TheAccount0IsDeprecated',
		dbo.fn_Localize(A.[Name], A.[Name2], A.[Name3]) AS Account
	FROM @Lines L
	JOIN @Entries E ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
	JOIN dbo.[Accounts] A ON A.[Id] = E.[AccountId]
	WHERE (A.[IsDeprecated] = 1);
	
	---- Some Entry Definitions with some Account Types require an Entry Type
	--INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
	--SELECT TOP (@Top)
	--	'[' + CAST(E.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
	--		CAST(E.[LineIndex] AS NVARCHAR (255)) + '].Entries[' + CAST(E.[Index] AS NVARCHAR(255)) + '].EntryTypeId',
	--	N'Error_TheField0IsRequired',
	--	dbo.fn_Localize(LDC.[Label], LDC.[Label2], LDC.[Label3]) AS [EntryTypeFieldName]
	--FROM @Entries E
	--JOIN @Lines L ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
	--JOIN [dbo].[LineDefinitionEntries] LDE ON LDE.LineDefinitionId = L.DefinitionId AND LDE.[Index] = E.[Index]
	--JOIN [dbo].[LineDefinitionColumns] LDC ON LDC.LineDefinitionId = L.DefinitionId AND LDC.[TableName] = N'Entries' AND LDC.[EntryIndex] = E.[Index] AND LDC.[ColumnName] = N'EntryTypeId'
	--JOIN [dbo].[AccountTypes] [AT] ON LDE.[AccountTypeParentCode] = [AT].[Code] 
	--WHERE (E.[EntryTypeId] IS NULL) AND [AT].[EntryTypeParentId] IS NOT NULL AND L.DefinitionId <> N'ManualLine';

	/*
		-- TODO: For the cases below, add the condition that Entry Type is enforced

	
	--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
	--                 JV Validation
	--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

	-- Some Accounts of some Account Types require an Entry Type
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0])
	SELECT TOP (@Top)
		'[' + CAST(E.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
			CAST(E.[LineIndex] AS NVARCHAR (255)) + '].Entries[' + CAST(E.[Index] AS NVARCHAR(255)) + '].EntryTypeId',
		N'Error_ThePurposeIsRequiredBecauseAccountTypeIs0',
		dbo.fn_Localize([AT].[Name], [AT].[Name2], [AT].[Name3]) AS [AccountType]
	FROM @Entries [E]
	JOIN @Lines L ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
	JOIN [dbo].[Accounts] [A] ON [E].[AccountId] = [A].[Id]
	JOIN [dbo].[AccountTypes] [AT] ON A.[AccountTypeId] = [AT].[Id]
	WHERE ([E].[EntryTypeId] IS NULL)
	AND [AT].[EntryTypeParentId] IS NOT NULL
	AND L.DefinitionId = N'ManualLine';
		
	-- The Entry Type must be compatible with the Account Type
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0], [Argument1])
	SELECT TOP (@Top)
		'[' + CAST(E.[DocumentIndex] AS NVARCHAR (255)) + '].Lines[' +
			CAST(E.[LineIndex] AS NVARCHAR (255)) + '].Entries[' + CAST(E.[Index] AS NVARCHAR(255)) + '].EntryTypeId',
		N'Error_IncompatibleAccountType0AndEntryType1',
		dbo.fn_Localize([AT].[Name], [AT].[Name2], [AT].[Name3]) AS AccountType,
		dbo.fn_Localize([ETE].[Name], [ETE].[Name2], [ETE].[Name3]) AS AccountType
	FROM @Entries E
	JOIN @Lines L ON L.[Index] = E.[LineIndex] AND L.[DocumentIndex] = E.[DocumentIndex]
	JOIN dbo.Accounts A ON E.AccountId = A.Id
	JOIN dbo.[AccountTypes] [AT] ON A.[AccountTypeId] = [AT].Id
	JOIN dbo.[EntryTypes] ETE ON E.[EntryTypeId] = ETE.Id
	JOIN dbo.[EntryTypes] ETA ON [AT].[EntryTypeParentId] = ETA.[Id]
	WHERE ETE.[Node].IsDescendantOf(ETA.[Node]) = 0
	AND L.[DefinitionId] = N'ManualLine';


	*/

-- Not allowed to cause negative balance in conservative accounts
IF @ToState = 3 
BEGIN
	DECLARE @InventoriesTotal HIERARCHYID = 
		(SELECT [Node] FROM dbo.[AccountTypes] WHERE Code = N'InventoriesTotal');
	WITH
	ConservativeAccounts AS (
		SELECT [Id] FROM dbo.[Accounts] A
		WHERE A.[AccountTypeId] IN (
			SELECT [Id] FROM dbo.[AccountTypes]
			WHERE [Node].IsDescendantOf(@InventoriesTotal) = 1
		)
		AND [Id] IN (SELECT [Id] FROM @Entries)
	),
	OffendingEntries AS (
		SELECT MAX([Id]) AS [Index],
			AccountId,
			ResourceId,
			AgentId,
			DueDate,
			--[AccountIdentifier],
			--[ResourceIdentifier],
			SUM([NormalizedQuantity]) AS [Quantity]			
		FROM map.DetailsEntries() E
		WHERE AccountId IN (SELECT [Id] FROM ConservativeAccounts)
		GROUP BY
			AccountId,
			ResourceId,
			AgentId,
			DueDate--,
			--[AccountIdentifier],
			--[ResourceIdentifier]
		HAVING
			SUM([NormalizedQuantity]) < 0
	)
	INSERT INTO @ValidationErrors([Key], [ErrorName], [Argument0], [Argument1], [Argument2])
	SELECT TOP (@Top)
		'[' + ISNULL(CAST([Index] AS NVARCHAR (255)),'') + ']', 
		N'Error_TheResource0Account1Shortage2',
		dbo.fn_Localize(R.[Name], R.[Name2], R.[Name3]) AS [Resource], 
		dbo.fn_Localize(A.[Name], A.[Name2], A.[Name3]) AS [Account],
		D.[Quantity] -- 
	FROM OffendingEntries D
	JOIN dbo.[Accounts] A ON D.AccountId = A.Id
	JOIN dbo.Resources R ON A.ResourceId = R.Id
END
	SELECT TOP (@Top) * FROM @ValidationErrors;