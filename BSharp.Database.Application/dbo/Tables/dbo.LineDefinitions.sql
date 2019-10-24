﻿CREATE TABLE [dbo].[LineDefinitions] (
	[Id]						NVARCHAR (50) PRIMARY KEY,
	[Description]				NVARCHAR (255),
	[Description2]				NVARCHAR (255),
	[Description3]				NVARCHAR (255),
	[TitleSingular]				NVARCHAR (255),
	[TitleSingular2]			NVARCHAR (255),
	[TitleSingular3]			NVARCHAR (255),
	[TitlePlural]				NVARCHAR (255),
	[TitlePlural2]				NVARCHAR (255),
	[TitlePlural3]				NVARCHAR (255),
	[CustomerLabel]				NVARCHAR (255),
	[SupplierLabel]				NVARCHAR (255),
	[EmployeeLabel]				NVARCHAR (255),
	[FromCustodyAccountLabel]	NVARCHAR (255),
	[ToCustodyAccountLabel]		NVARCHAR (255),
	-- Move to the table LineDefinitionEntries
	[EntryNumber]				TINYINT,
	[Direction]					SMALLINT,
	[AccountDefinitionList]		NVARCHAR (1024),
	[AccountTypeList]			NVARCHAR (1024),
	[EntryTypeId]				NVARCHAR (255),
	[ResourceDefinitionList]	NVARCHAR (1024),
	[ResourceTypeList]			NVARCHAR (1024),
	[LocationDefinitionList]	NVARCHAR (1024),
	
);