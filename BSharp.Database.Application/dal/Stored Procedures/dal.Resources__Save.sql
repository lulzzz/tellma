﻿CREATE PROCEDURE [dal].[Resources__Save]
	@Resources [dbo].[ResourceList] READONLY,
	@Picks [dbo].[ResourcePickList] READONLY,
	@ReturnIds BIT = 0
AS
SET NOCOUNT ON;
	DECLARE @IndexedIds [dbo].[IndexedIdList];
	DECLARE @Now DATETIMEOFFSET(7) = SYSDATETIMEOFFSET();
	DECLARE @UserId INT = CONVERT(INT, SESSION_CONTEXT(N'UserId'));

	INSERT INTO @IndexedIds([Index], [Id])
	SELECT x.[Index], x.[Id]
	FROM
	(
		MERGE INTO [dbo].[Resources] AS t
		USING (
			SELECT 	
				[Index], [Id], [ResourceType], [Name], [Name2], [Name3], [IsBatch], 
				[UnitId], [UnitMonetaryValue], [CurrencyId], [UnitMass], [MassUnitId], [UnitVolume], [VolumeUnitId],
				[UnitArea], [AreaUnitId], [UnitLength], [LengthUnitId], [UnitTime], [TimeUnitId], [UnitCount], [CountUnitId],
				[Code], [SystemCode], [Memo], [CustomsReference] ,[UniversalProductCode], [PreferredSupplierId],
				[ResourceLookup1Id], [ResourceLookup2Id], [ResourceLookup3Id], [ResourceLookup4Id]
			FROM @Resources 
		) AS s ON (t.Id = s.Id)
		WHEN MATCHED 
		THEN
			UPDATE SET 
				t.[ResourceType]			= s.[ResourceType],     
				t.[Name]					= s.[Name],
				t.[Name2]					= s.[Name2],
				t.[Name3]					= s.[Name3],
				t.[IsBatch]					= s.[IsBatch],
				t.[UnitId]					= s.[UnitId],
				t.[UnitMonetaryValue]		= s.[UnitMonetaryValue],
				t.[CurrencyId]				= s.[CurrencyId],
				t.[UnitMass]				= s.[UnitMass],
				t.[MassUnitId]				= s.[MassUnitId],
				t.[UnitVolume]				= s.[UnitVolume],
				t.[VolumeUnitId]			= s.[VolumeUnitId],
				t.[LengthUnitId]			= s.[LengthUnitId],
				t.[AreaUnitId]				= s.[AreaUnitId],
				t.[UnitTime]				= s.[UnitTime],
				t.[TimeUnitId]				= s.[TimeUnitId],
				t.[UnitCount]				= s.[UnitCount],
				t.[CountUnitId]				= s.[CountUnitId],
				t.[Code]					= s.[Code],
				t.[SystemCode]				= s.[SystemCode],
				t.[Memo]					= s.[Memo],      
				t.[CustomsReference]		= s.[CustomsReference],
				t.[UniversalProductCode]	= s.[UniversalProductCode],
				t.[PreferredSupplierId]		= s.[PreferredSupplierId],
				t.[ResourceLookup1Id]		= s.[ResourceLookup1Id],
				t.[ResourceLookup2Id]		= s.[ResourceLookup2Id],
				t.[ResourceLookup3Id]		= s.[ResourceLookup3Id],
				t.[ResourceLookup4Id]		= s.[ResourceLookup4Id],
				t.[ModifiedAt]				= @Now,
				t.[ModifiedById]			= @UserId
		WHEN NOT MATCHED THEN
			INSERT ([ResourceType], [Name], [Name2], [Name3], [IsBatch],
				[UnitId], [UnitMonetaryValue], [CurrencyId], [UnitMass], [MassUnitId], [UnitVolume], [VolumeUnitId],
				[UnitArea], [AreaUnitId], [UnitLength], [LengthUnitId], [UnitTime], [TimeUnitId], [UnitCount], [CountUnitId],
				[Code], [SystemCode], [Memo], [CustomsReference] ,[UniversalProductCode], [PreferredSupplierId],
				[ResourceLookup1Id], [ResourceLookup2Id], [ResourceLookup3Id], [ResourceLookup4Id])
			VALUES (s.[ResourceType], s.[Name], s.[Name2], s.[Name3], s.[IsBatch],
				s.[UnitId], s.[UnitMonetaryValue], s.[CurrencyId], s.[UnitMass], s.[MassUnitId], s.[UnitVolume], s.[VolumeUnitId],
				s.[UnitArea], s.[AreaUnitId], s.[UnitLength], s.[LengthUnitId], s.[UnitTime], s.[TimeUnitId], s.[UnitCount], s.[CountUnitId],
				s.[Code], s.[SystemCode], s.[Memo], s.[CustomsReference] ,s.[UniversalProductCode], s.[PreferredSupplierId],
				s.[ResourceLookup1Id], s.[ResourceLookup2Id], s.[ResourceLookup3Id], s.[ResourceLookup4Id])
			OUTPUT s.[Index], inserted.[Id]
	) AS x
	OPTION (RECOMPILE);

	WITH BE AS (
		SELECT * FROM dbo.[ResourcePicks]
		WHERE ResourceId IN (SELECT [Id] FROM @IndexedIds)
	)
	MERGE INTO BE AS t
	USING (
		SELECT RI.[Id], II.[Id] As ResourceId, RI.[Code], RI.[ProductionDate],
				[MoneyAmount], [Mass], [Volume], [Area], [Length], [Time]
		FROM @Picks RI
		JOIN @IndexedIds II ON RI.[ResourceIndex] = II.[Index]
	) AS s
	ON (s.[Id] = t.[Id])
	WHEN MATCHED THEN
		UPDATE SET
			t.[Code]			= s.[Code],
			t.[ProductionDate]	= s.[ProductionDate],
			t.[MoneyAmount]		= s.[MoneyAmount],
			t.[Mass]			= s.[Mass],
			t.[Volume]			= s.[Volume],
			t.[Area]			= s.[Area],
			t.[Length]			= s.[Length],
			t.[Time]			= s.[Time]
	WHEN NOT MATCHED THEN
		INSERT ([ResourceId], [ProductionDate], [Code], [MoneyAmount], [Mass], [Volume], [Area], [Length], [Time])
		VALUES(s.[ResourceId], s.[ProductionDate], s.[Code], s.[MoneyAmount], s.[Mass], s.[Volume], s.[Area], s.[Length], s.[Time])
	WHEN NOT MATCHED BY SOURCE THEN
		DELETE;

	IF @ReturnIds = 1
		SELECT * FROM @IndexedIds;
