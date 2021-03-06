﻿CREATE TYPE [dbo].[AccountList] AS TABLE ( 
	[Index]						INT				PRIMARY KEY,
	[Id]						INT				NOT NULL DEFAULT 0,
	[AccountTypeId]				INT				NOT NULL,
	[CenterId]					INT,
	[Name]						NVARCHAR (255)	NOT NULL,
	[Name2]						NVARCHAR (255),
	[Name3]						NVARCHAR (255),
	[Code]						NVARCHAR (50),
	[ClassificationId]			INT,
	[CustodianId]				INT,
	[CustodyDefinitionId]		INT,
	[CustodyId]					INT,
	[ParticipantId]				INT,
	[ResourceDefinitionId]		INT,
	[ResourceId]				INT,
	[CurrencyId]				NCHAR (3),
	[EntryTypeId]				INT
);