﻿CREATE TABLE [dbo].[ResourceDefinitions]
(
	[Id]								NVARCHAR (50)	NOT NULL CONSTRAINT [PK_ResourceDefinitions] PRIMARY KEY,
	[TitleSingular]						NVARCHAR (255),
	[TitleSingular2]					NVARCHAR (255),
	[TitleSingular3]					NVARCHAR (255),
	[TitlePlural]						NVARCHAR (255),
	[TitlePlural2]						NVARCHAR (255),
	[TitlePlural3]						NVARCHAR (255),
	[AssetTypeVisibility]				NVARCHAR (50) DEFAULT N'None' CHECK ([AssetTypeVisibility] IN (N'None', N'Optional', N'Required')),
	[RevenueTypeVisibility]				NVARCHAR (50) DEFAULT N'None' CHECK ([RevenueTypeVisibility] IN (N'None', N'Optional', N'Required')),
	[ExpenseTypeVisibility]				NVARCHAR (50) DEFAULT N'None' CHECK ([ExpenseTypeVisibility] IN (N'None', N'Optional', N'Required')),
	-- If null, no restriction. Otherwise, it restricts the types to those stemming from one of the nodes in the parent list
	--[CodeRegEx]							NVARCHAR (255), -- Null means manually defined
	--[NameRegEx]							NVARCHAR (255), -- Null means manually defined
	-- Resource properties
	[IdentifierLabel]					NVARCHAR (50),
	[IdentifierLabel2]					NVARCHAR (50),
	[IdentifierLabel3]					NVARCHAR (50),		
	[IdentifierVisibility]				NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([IdentifierVisibility] IN (N'None', N'Optional', N'Required')),
	[CurrencyVisibility]				NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([CurrencyVisibility] IN (N'None', N'Optional', N'Required')),
	-- [CustomsReferenceVisibility]		NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([CustomsReferenceVisibility] IN (N'None', N'Optional', N'Required')),
	-- [PreferredSupplierVisibility]	NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([PreferredSupplierVisibility] IN (N'None', N'Optional', N'Required')),
	[DescriptionVisibility]				NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([DescriptionVisibility] IN (N'None', N'Optional', N'Required')),

	[ExpenseEntryTypeVisibility]		NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([ExpenseEntryTypeVisibility] IN (N'None', N'Optional', N'Required')),
	[CenterVisibility]					NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([CenterVisibility] IN (N'None', N'Optional', N'Required')),
	[ResidualMonetaryValueVisibility]	NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([ResidualMonetaryValueVisibility] IN (N'None', N'Optional', N'Required')),
	[ResidualValueVisibility]			NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([ResidualValueVisibility] IN (N'None', N'Optional', N'Required')),

	[ReorderLevelVisibility]			NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([ReorderLevelVisibility] IN (N'None', N'Optional', N'Required')),
	[EconomicOrderQuantityVisibility]	NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([EconomicOrderQuantityVisibility] IN (N'None', N'Optional', N'Required')),
	[AvailableSinceLabel]				NVARCHAR (50),
	[AvailableSinceLabel2]				NVARCHAR (50),
	[AvailableSinceLabel3]				NVARCHAR (50),		
	[AvailableSinceVisibility]			NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([AvailableSinceVisibility] IN (N'None', N'Optional', N'Required')),
	[AvailableTillLabel]				NVARCHAR (50),
	[AvailableTillLabel2]				NVARCHAR (50),
	[AvailableTillLabel3]				NVARCHAR (50),
	[AvailableTillVisibility]			NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([AvailableTillVisibility] IN (N'None', N'Optional', N'Required')),

	[Decimal1Label]						NVARCHAR (50),
	[Decimal1Label2]					NVARCHAR (50),
	[Decimal1Label3]					NVARCHAR (50),		
	[Decimal1Visibility]				NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([Decimal1Visibility] IN (N'None', N'Optional', N'Required')),

	[Decimal2Label]						NVARCHAR (50),
	[Decimal2Label2]					NVARCHAR (50),
	[Decimal2Label3]					NVARCHAR (50),		
	[Decimal2Visibility]				NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([Decimal2Visibility] IN (N'None', N'Optional', N'Required')),

	[Int1Label]							NVARCHAR (50),
	[Int1Label2]						NVARCHAR (50),
	[Int1Label3]						NVARCHAR (50),		
	[Int1Visibility]					NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([Int1Visibility] IN (N'None', N'Optional', N'Required')),

	[Int2Label]							NVARCHAR (50),
	[Int2Label2]						NVARCHAR (50),
	[Int2Label3]						NVARCHAR (50),		
	[Int2Visibility]					NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([Int2Visibility] IN (N'None', N'Optional', N'Required')),

	[Lookup1Label]						NVARCHAR (50),
	[Lookup1Label2]						NVARCHAR (50),
	[Lookup1Label3]						NVARCHAR (50),
	[Lookup1Visibility]					NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([Lookup1Visibility] IN (N'None', N'Required', N'Optional')),
	[Lookup1DefinitionId]				NVARCHAR (50) CONSTRAINT [FK_ResourceDefinitions__Lookup1DefinitionId] REFERENCES dbo.LookupDefinitions([Id]),
	[Lookup2Label]						NVARCHAR (50),
	[Lookup2Label2]						NVARCHAR (50),
	[Lookup2Label3]						NVARCHAR (50),
	[Lookup2Visibility]					NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([Lookup2Visibility] IN (N'None', N'Optional', N'Required')),
	[Lookup2DefinitionId]				NVARCHAR (50) CONSTRAINT [FK_ResourceDefinitions__Lookup2DefinitionId] REFERENCES dbo.LookupDefinitions([Id]),
	[Lookup3Visibility]					NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([Lookup3Visibility] IN (N'None', N'Optional', N'Required')),
	[Lookup3DefinitionId]				NVARCHAR (50) CONSTRAINT [FK_ResourceDefinitions__Lookup3DefinitionId] REFERENCES dbo.LookupDefinitions([Id]),
	[Lookup3Label]						NVARCHAR (50),
	[Lookup3Label2]						NVARCHAR (50),
	[Lookup3Label3]						NVARCHAR (50),
	[Lookup4Visibility]					NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([Lookup4Visibility] IN (N'None', N'Optional', N'Required')),
	[Lookup4DefinitionId]				NVARCHAR (50) CONSTRAINT [FK_ResourceDefinitions__Lookup4DefinitionId] REFERENCES dbo.LookupDefinitions([Id]),
	[Lookup4Label]						NVARCHAR (50),
	[Lookup4Label2]						NVARCHAR (50),
	[Lookup4Label3]						NVARCHAR (50),
	--[Lookup5Visibility]					NVARCHAR (50) DEFAULT N'None' CHECK ([Lookup5Visibility] IN (N'None', N'Optional', N'Required')),
	--[Lookup5DefinitionId]				NVARCHAR (50) CONSTRAINT [FK_ResourceDefinitions__Lookup5DefinitionId] REFERENCES dbo.LookupDefinitions([Id]),
	--[Lookup5Label]						NVARCHAR (50),
	--[Lookup5Label2]						NVARCHAR (50),
	--[Lookup5Label3]						NVARCHAR (50),
	--[DueDateLabel]						NVARCHAR (50),
	--[DueDateLabel2]						NVARCHAR (50),
	--[DueDateLabel3]						NVARCHAR (50),
	--[DueDateVisibility]					NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([DueDateVisibility] IN (N'None', N'Optional', N'Required')),
	-- more properties from Resource Instances to come..
	[Text1Label]						NVARCHAR (50),
	[Text1Label2]						NVARCHAR (50),
	[Text1Label3]						NVARCHAR (50),		
	[Text1Visibility]					NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([Text1Visibility] IN (N'None', N'Optional', N'Required')),

	[Text2Label]							NVARCHAR (50),
	[Text2Label2]						NVARCHAR (50),
	[Text2Label3]						NVARCHAR (50),		
	[Text2Visibility]					NVARCHAR (50) NOT NULL DEFAULT N'None' CHECK ([Text2Visibility] IN (N'None', N'Optional', N'Required')),


	[State]								NVARCHAR (50)				DEFAULT N'Draft',	-- Deployed, Archived (Phased Out)
	[MainMenuIcon]						NVARCHAR (50),
	[MainMenuSection]					NVARCHAR (50),			-- IF Null, it does not show on the main menu
	[MainMenuSortKey]					DECIMAL (9,4),
	
	[SavedById]			INT				NOT NULL DEFAULT CONVERT(INT, SESSION_CONTEXT(N'UserId')) CONSTRAINT [FK_ResourceDefinitions__SavedById] REFERENCES [dbo].[Users] ([Id]),
	[ValidFrom]			DATETIME2		GENERATED ALWAYS AS ROW START NOT NULL,
	[ValidTo]			DATETIME2		GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
	PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.[ResourceDefinitionsHistory]));
GO;