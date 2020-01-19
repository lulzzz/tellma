﻿CREATE PROCEDURE [bll].[WideLines__Unpivot]
		@WideLines dbo.[WideLineList] READONLY
AS
	DECLARE @AllEntries dbo.EntryList;

	WITH LD AS (
		SELECT LineDefinitionId, COUNT(*) AS EntryCount FROM dbo.LineDefinitionEntries GROUP BY LineDefinitionId
	)
	INSERT INTO @AllEntries
	(
			[Index], [LineIndex], [DocumentIndex], [Id], [EntryNumber], [Direction], [AccountId], [EntryTypeId], [ExternalReference], [AdditionalReference])
	SELECT 3*[Index] + 1, [Index],	[DocumentIndex], [Id],		1,			[Direction1],[AccountId1],[EntryTypeId1],[ExternalReference1],[AdditionalReference1]
	FROM @WideLines WL JOIN LD ON WL.DefinitionId = LD.LineDefinitionId
	WHERE LD.EntryCount >= 1
	UNION
	SELECT 3*[Index] + 2, [Index],	[DocumentIndex], [Id],		2,			[Direction2],[AccountId2],[EntryTypeId2],[ExternalReference2],[AdditionalReference2]
	FROM @WideLines WL JOIN LD ON WL.DefinitionId = LD.LineDefinitionId
	WHERE LD.EntryCount >= 2
	UNION
	SELECT 3*[Index] + 3, [Index],	[DocumentIndex], [Id],		3,			[Direction3],[AccountId3],[EntryTypeId3],[ExternalReference3],[AdditionalReference3]
	FROM @WideLines WL JOIN LD ON WL.DefinitionId = LD.LineDefinitionId
	WHERE LD.EntryCount >= 3

	SELECT * FROM @AllEntries;