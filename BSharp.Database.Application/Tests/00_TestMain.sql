﻿SET NOCOUNT ON;
--ROLLBACK
/* Dependencies
-- Optional screens, can pre-populate table with data
	CustomAccountClassifications -- screen shows list of accounts
	IfrsDisclosures
	MeasurementUnits
	IfrsNotes
	IfrsAccounts -- screen shows list of accounts
	AgentRelationTypes
	JobTitles
	Titles, MaritalStatuses, Tribes, Regions, EducationLevels, EducationSublevels, OrganizationTypes, 
-- Critical screens for making a journal entry
	Accounts
	Agents, -- screen shows list of relations with Agents
	Resources, -- screen for each ifrs type. Detail shows ResourceInstances
	Workflows, -- screen 
	Documents, -- screen shows Lines, LineEntries, Signatures, StatesHistory(?)
*/
BEGIN -- reset Identities
DELETE FROM dbo.Accounts; DELETE FROM dbo.Resources;
IF NOT EXISTS(SELECT * FROM [dbo].[IfrsDisclosureDetails])	DBCC CHECKIDENT ('[dbo].[IfrsDisclosureDetails]', RESEED, 0) WITH NO_INFOMSGS;
	IF NOT EXISTS(SELECT * FROM [dbo].[MeasurementUnits])	DBCC CHECKIDENT ('[dbo].[MeasurementUnits]', RESEED, 0) WITH NO_INFOMSGS;
	IF NOT EXISTS(SELECT * FROM [dbo].[ProductCategories])	DBCC CHECKIDENT ('[dbo].[ProductCategories]', RESEED, 0) WITH NO_INFOMSGS;
	IF NOT EXISTS(SELECT * FROM [dbo].[ResponsibilityCenters])	DBCC CHECKIDENT ('[dbo].[ResponsibilityCenters]', RESEED, 0) WITH NO_INFOMSGS;
	IF NOT EXISTS(SELECT * FROM [dbo].[Agents])				DBCC CHECKIDENT ('[dbo].[Agents]', RESEED, 0) WITH NO_INFOMSGS;
	IF NOT EXISTS(SELECT * FROM [dbo].[Resources])			DBCC CHECKIDENT ('[dbo].[Resources]', RESEED, 0) WITH NO_INFOMSGS;
	IF NOT EXISTS(SELECT * FROM [dbo].[Accounts])			DBCC CHECKIDENT ('[dbo].[Accounts]', RESEED, 0) WITH NO_INFOMSGS;
	IF NOT EXISTS(SELECT * FROM [dbo].[DocumentLineEntries])DBCC CHECKIDENT ('[dbo].[DocumentLineEntries]', RESEED, 0) WITH NO_INFOMSGS;
	IF NOT EXISTS(SELECT * FROM [dbo].[DocumentLines])		DBCC CHECKIDENT ('[dbo].[DocumentLines]', RESEED, 0) WITH NO_INFOMSGS;
	IF NOT EXISTS(SELECT * FROM [dbo].[Documents])			DBCC CHECKIDENT ('[dbo].[Documents]', RESEED, 0) WITH NO_INFOMSGS;
	-- Just for debugging convenience. Even though we are roling the transaction, the identities are changing
	DECLARE @ValidationErrorsJson nvarchar(max), @ResultsJson nvarchar(max);
	DECLARE @DebugIfrsConcepts bit = 0, @DebugMeasurementUnits bit = 0;
	DECLARE @DebugProductCategories bit = 0, @DebugOperations bit = 1, @DebugResources bit = 0;
	DECLARE @DebugAgents bit = 0, @DebugPlaces bit = 0;
	DECLARE @LookupsSelect bit = 0;
	DECLARE @fromDate Date, @toDate Date;
	EXEC sp_set_session_context 'Debug', 1;
	DECLARE @UserId INT, @RowCount INT;

	SELECT @UserId = [Id] FROM dbo.[Users] WHERE [Email] = N'support@banan-it.com';

	EXEC sp_set_session_context 'UserId', @UserId;
	DECLARE @Now DATETIMEOFFSET(7) = SYSDATETIMEOFFSET();
END

BEGIN TRY
	BEGIN TRANSACTION
		:r .\01_IfrsConcepts.sql
		:r .\02_MeasurementUnits.sql
		--:r .\03_ProductCategories.sql
		--:r .\03_Operations.sql
		--:r .\04_Resources.sql
		--:r .\05_Agents.sql
		:r .\10_Documents.sql
	--	select * from entries;
	--SELECT @fromDate = '2017.01.01', @toDate = '2024.03.01'
	--SELECT * from dbo.[fi_Journal](@fromDate, @toDate);
	--EXEC rpt_TrialBalance @fromDate = @fromDate, @toDate = @toDate, @PrintQuery = 0;


	--SELECT * FROM dbo.[fi_WithholdingTaxOnPayment](default, default);
	--SELECT * FROM dbo.[fi_ERCA__VAT_Purchases](default, default);
	--DECLARE @i int = 0;
	--SELECT @fromDate = '2017.01.1'; SELECT @toDate = DATEADD(DAY, 90, @fromDate);
	--WHILE @i < 30
	--BEGIN
	--	SELECT * FROM [dbo].[fi_AssetRegister](@fromDate, @toDate);
	--	SELECT @fromDate = DATEADD(DAY, 90, @fromDate), @toDate = DATEADD(DAY, 90, @toDate);
	--	SET @i = @i + 1;
	--END
	--SELECT * FROM dbo.[fi_AssetRegister]('2017.02.01', '2018.02.01');
	--SELECT @fromDate = '2017.01.01', @toDate = '2024.01.01';
	--SELECT * FROM dbo.fi_AssetRegister(@fromDate, @toDate);
	EXEC dbo.rpt_BankAccount__Statement @CBEUSD,  @fromDate, @toDate;
	--SELECT * from dbo.fi_Account__Statement(N'DistributionCosts', @SalesDepartment, @Goff, @fromDate, @toDate) ORDER BY StartDateTime;
	--SELECT * FROM dbo.fi_ERCA__EmployeeIncomeTax('2018.02.01', '2018.03.01');
	--SELECT * FROM dbo.fi_Paysheet(default, default, '2018.02', @Basic, @Transportation);

	ROLLBACK;
END TRY
BEGIN CATCH
	ROLLBACK;
	THROW;
END CATCH

RETURN;

ERR_LABEL:
	SELECT * FROM OpenJson(@ValidationErrorsJson)
	WITH (
		[Key] NVARCHAR (255) '$.Key',
		[ErrorName] NVARCHAR (255) '$.ErrorName',
		[Argument1] NVARCHAR (255) '$.Argument1',
		[Argument2] NVARCHAR (255) '$.Argument2',
		[Argument3] NVARCHAR (255) '$.Argument3',
		[Argument4] NVARCHAR (255) '$.Argument4',
		[Argument5] NVARCHAR (255) '$.Argument5'	
	);
	ROLLBACK;
RETURN;