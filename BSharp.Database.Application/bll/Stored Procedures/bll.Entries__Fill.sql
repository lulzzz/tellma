﻿CREATE PROCEDURE [bll].[Entries__Fill]
	@Documents [dbo].[DocumentList] READONLY,
	@Lines [dbo].[LineList] READONLY, 
	@Entries [dbo].EntryList READONLY
AS
SET NOCOUNT ON;
DECLARE @FunctionalCurrencyId NCHAR(3) = CONVERT(NCHAR(3), SESSION_CONTEXT(N'FunctionalCurrencyId'));

DECLARE @FilledEntries [dbo].EntryList;
DECLARE @FilledLines dbo.[LineList];

INSERT INTO @FilledEntries SELECT * FROM @Entries;
INSERT INTO @FilledLines SELECT * FROM @Lines;

-- Applies to All line types
-- Copy information from documents to Lines
--UPDATE L
--SET L.AgentId = D.AgentId
--FROM @FilledLines L JOIN @Documents D ON L.DocumentIndex = D.[Index]
--WHERE 
--select 1 as step, E.* from @FilledEntries E
-- Copy information from Lines to Entries
UPDATE E 
SET E.CurrencyId = L.CurrencyId
FROM @FilledEntries E JOIN @FilledLines L ON E.LineIndex = L.[Index]
JOIN dbo.LineDefinitionEntries LDE ON L.DefinitionId = LDE.LineDefinitionId AND E.EntryNumber = LDE.EntryNumber
WHERE LDE.CurrencySource = 2 AND E.CurrencyId <> L.CurrencyId
--select 2 as step, E.* from @FilledEntries E
UPDATE E 
SET E.AgentId = L.AgentId
FROM @FilledEntries E JOIN @FilledLines L ON E.LineIndex = L.[Index]
JOIN dbo.LineDefinitionEntries LDE ON L.DefinitionId = LDE.LineDefinitionId AND E.EntryNumber = LDE.EntryNumber
WHERE LDE.AgentSource = 2 AND E.AgentId <> L.AgentId
--select 3 as step, E.* from @FilledEntries E
UPDATE E 
SET E.ResourceId = L.ResourceId
FROM @FilledEntries E JOIN @FilledLines L ON E.LineIndex = L.[Index]
JOIN dbo.LineDefinitionEntries LDE ON L.DefinitionId = LDE.LineDefinitionId AND E.EntryNumber = LDE.EntryNumber
WHERE LDE.ResourceSource = 2 AND E.ResourceId <> L.ResourceId
--select 4 as step, E.* from @FilledEntries E
-- When using manual line, Copy information from Account to entries
UPDATE E 
SET
	E.[ContractType]			= A.[ContractType],
	E.[AgentDefinitionId]		= A.[AgentDefinitionId],
	E.[ResourceClassificationId]= COALESCE(A.[ResourceClassificationId], E.[ResourceClassificationId]),
	E.[IsCurrent]				= COALESCE(A.[IsCurrent], E.[IsCurrent]),
	E.[AgentId]					= COALESCE(A.[AgentId], E.[AgentId]),
	E.[ResourceId]				= COALESCE(A.[AgentId], E.[AgentId]),
	E.[ResponsibilityCenterId]	= COALESCE(A.[ResponsibilityCenterId], E.[ResponsibilityCenterId]),
	E.[AccountDescriptorId]		= COALESCE(A.[Identifier], E.[AccountDescriptorId]),
	E.[EntryClassificationId]	= COALESCE(A.[EntryClassificationId], E.[EntryClassificationId])
FROM @FilledEntries E JOIN @FilledLines L ON E.LineIndex = L.[Index]
JOIN dbo.Accounts A ON E.AccountId = A.Id
WHERE L.DefinitionId = N'ManualLine' AND A.[IsSmart] = 1; -- Entered by user
--select 5 as step, E.* from @FilledEntries E
-- for all lines, Get currency and descriptor from Resources if available.
UPDATE E 
SET
	E.[CurrencyId]			 = 	COALESCE(R.[CurrencyId], E.[CurrencyId]),
	E.[ResourceDescriptorId] =  COALESCE(R.[Identifier], E.[ResourceDescriptorId])
FROM @FilledEntries E JOIN @FilledLines L ON E.LineIndex = L.[Index]
JOIN dbo.Resources R ON E.ResourceId = R.Id
--select 6 as step, E.* from @FilledEntries E
-- set the count to one, if singleton
UPDATE E 
SET
	E.[Count]		=	COALESCE(R.[Count], E.[Count]) -- If the Resource is a singleton, R.[Count] is one.
FROM @FilledEntries E JOIN @FilledLines L ON E.LineIndex = L.[Index]
JOIN dbo.Resources R ON E.ResourceId = R.Id
--select 7 as step, E.* from @FilledEntries E
-- set the other measures, if the rate per unit is defined
UPDATE E 
SET
	E.[MonetaryValue] = COALESCE(R.[MonetaryValue] * E.[Count], E.[MonetaryValue]),
	E.[Mass]		=	COALESCE(R.[Mass] * E.[Count], E.[Mass]),
	E.[Volume]		=	COALESCE(R.[Volume] * E.[Count], E.[Volume]),
	E.[Time]		=	COALESCE(R.[Time] * E.[Count], E.[Time])
FROM @FilledEntries E JOIN @FilledLines L ON E.LineIndex = L.[Index]
JOIN dbo.Resources R ON E.ResourceId = R.Id
--select 8 as step, E.* from @FilledEntries E
UPDATE E
SET
	E.[Direction] = COALESCE(E.[Direction], LDE.[Direction]),
	E.[AccountId] = COALESCE(E.[AccountId], LDE.[AccountId])
	-- TODO: fill with all the remaining defaults

FROM @FilledEntries E
JOIN @Lines L ON E.[LineIndex] = L.[Index]
JOIN dbo.LineDefinitionEntries LDE ON L.[DefinitionId] = LDE.[LineDefinitionId] AND E.[EntryNumber] = LDE.[EntryNumber]
--select 9 as step, E.* from @FilledEntries E
-- for financial amounts in functional currency, the value is known
UPDATE E 
SET E.[Value] = E.[MonetaryValue]
FROM @FilledEntries E
JOIN dbo.Accounts A ON E.AccountId = A.Id
JOIN @Lines L ON E.LineIndex = L.[Index]
JOIN @Documents D ON L.DocumentIndex = D.[Index]
WHERE
	E.[CurrencyId] = @FunctionalCurrencyId
	AND (E.[Value] <> E.[MonetaryValue]);
--select 10 as step, E.* from @FilledEntries E
-- for financial amounts in foreign currency, the value is manually entered or read from a web service
--UPDATE E 
--SET E.[Value] = dbo.[fn_CurrencyExchange](D.[DocumentDate], E.[CurrencyId], @FunctionalCurrencyId, E.[MonetaryValue])
--FROM @FilledEntries E
--JOIN dbo.Resources R ON E.ResourceId = R.Id
--JOIN @Lines L ON E.LineIndex = L.[Index]
--JOIN @Documents D ON L.DocumentIndex = D.[Index]
--WHERE
--	E.[CurrencyId] <> @FunctionalCurrencyId
--	AND (E.[Value] <> dbo.[fn_CurrencyExchange](D.[DocumentDate], E.[CurrencyId], @FunctionalCurrencyId, E.[MonetaryValue]));

-- if one value only is zero at the line level, set it to the sum of the rest. Otherwise, the accountant has to set it.
/*
WITH SingletonLines
AS (
	SELECT [DocumentIndex], [LineIndex] 
	FROM @FilledEntries WHERE [Value] = 0
	GROUP BY [DocumentIndex], [LineIndex] 
	HAVING COUNT(*) = 1
),
LinesBalances
AS (
	SELECT [DocumentIndex], [LineIndex], SUM([Direction] * [Value]) AS [Balance]
	FROM @FilledEntries
	GROUP BY [DocumentIndex], [LineIndex] 
)
UPDATE E
SET E.[Value] = -E.[Direction] * LB.[Balance]
FROM @FilledEntries E
JOIN SingletonLines SL ON (E.[DocumentIndex] = SL.[DocumentIndex] AND E.[LineIndex] = SL.[LineIndex])
JOIN LinesBalances LB ON (E.[DocumentIndex] = LB.[DocumentIndex] AND E.[LineIndex] = LB.[LineIndex])
WHERE E.[Value] = 0 AND E.[Value] <> -E.[Direction] * LB.[Balance];

-- if one value only is zero at the document level, set it to the sum of the rest. Otherwise, the accountant has to set it.
WITH SingletonDocs
AS (
	SELECT [DocumentIndex] 
	FROM @FilledEntries WHERE [Value] = 0
	GROUP BY [DocumentIndex]
	HAVING COUNT(*) = 1
),
DocsBalances
AS (
	SELECT [DocumentIndex], SUM([Direction] * [Value]) AS [Balance]
	FROM @FilledEntries
	GROUP BY [DocumentIndex]
)
UPDATE E
SET E.[Value] = -E.[Direction] * DB.[Balance]
FROM @FilledEntries E
JOIN SingletonDocs SD ON (E.DocumentIndex = SD.[DocumentIndex])
JOIN DocsBalances DB ON (E.DocumentIndex = DB.DocumentIndex)
WHERE E.[Value] = 0 AND E.[Value] <> -E.[Direction] * DB.[Balance];
*/
SELECT * FROM @FilledEntries;