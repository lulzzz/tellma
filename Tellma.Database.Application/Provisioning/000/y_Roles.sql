﻿
DECLARE @ManualJournalVoucherDDPath NVARCHAR(50) = N'documents/' + CAST(@ManualJournalVoucherDD AS NVARCHAR(50));
DECLARE @ProjectCompletionVoucherDDPath NVARCHAR(50) = N'documents/' + CAST(@ProjectCompletionVoucherDD AS NVARCHAR(50));
DECLARE @ClosingPeriodVoucherDDPath NVARCHAR(50) = N'documents/' + CAST(@ClosingPeriodVoucherDD AS NVARCHAR(50));
DECLARE @ClosingYearVoucherDDPath NVARCHAR(50) = N'documents/' + CAST(@ClosingYearVoucherDD AS NVARCHAR(50));
DECLARE @CashTransferExchangeDDPath NVARCHAR(50) = N'documents/' + CAST(@CashTransferExchangeDD AS NVARCHAR(50));
DECLARE @DepositToBankDDPath NVARCHAR(50) = N'documents/' + CAST(@DepositToBankDD AS NVARCHAR(50));
DECLARE @PaymentReceiptFromNonTradingAgentsDDPath NVARCHAR(50) = N'documents/' + CAST(@PaymentReceiptFromNonTradingAgentsDD AS NVARCHAR(50));
DECLARE @PaymentIssueToNonTradingAgentsDDPath NVARCHAR(50) = N'documents/' + CAST(@PaymentIssueToNonTradingAgentsDD AS NVARCHAR(50));
DECLARE @StockIssueToNonTradingAgentDDPath NVARCHAR(50) = N'documents/' + CAST(@StockIssueToNonTradingAgentDD AS NVARCHAR(50));
DECLARE @StockTransferDDPath NVARCHAR(50) = N'documents/' + CAST(@StockTransferDD AS NVARCHAR(50));
DECLARE @StockReceiptFromNonTradingAgentDDPath NVARCHAR(50) = N'documents/' + CAST(@StockReceiptFromNonTradingAgentDD AS NVARCHAR(50));
DECLARE @InventoryAdjustmentDDPath NVARCHAR(50) = N'documents/' + CAST(@InventoryAdjustmentDD AS NVARCHAR(50));
DECLARE @PaymentIssueToTradePayableDDPath NVARCHAR(50) = N'documents/' + CAST(@PaymentIssueToTradePayableDD AS NVARCHAR(50));
DECLARE @RefundFromTradePayableDDPath NVARCHAR(50) = N'documents/' + CAST(@RefundFromTradePayableDD AS NVARCHAR(50));
DECLARE @WithholdingTaxFromTradePayableDDPath NVARCHAR(50) = N'documents/' + CAST(@WithholdingTaxFromTradePayableDD AS NVARCHAR(50));
DECLARE @ImportFromTradePayableDDPath NVARCHAR(50) = N'documents/' + CAST(@ImportFromTradePayableDD AS NVARCHAR(50));
DECLARE @GoodReceiptFromImportDDPath NVARCHAR(50) = N'documents/' + CAST(@GoodReceiptFromImportDD AS NVARCHAR(50));
DECLARE @GoodServiceReceiptFromTradePayableDDPath NVARCHAR(50) = N'documents/' + CAST(@GoodServiceReceiptFromTradePayableDD AS NVARCHAR(50));
DECLARE @PaymentReceiptFromTradeReceivableDDPath NVARCHAR(50) = N'documents/' + CAST(@PaymentReceiptFromTradeReceivableDD AS NVARCHAR(50));
DECLARE @RefundToTradeReceivableDDPath NVARCHAR(50) = N'documents/' + CAST(@RefundToTradeReceivableDD AS NVARCHAR(50));
DECLARE @WithholdingTaxByTradeReceivableDDPath NVARCHAR(50) = N'documents/' + CAST(@WithholdingTaxByTradeReceivableDD AS NVARCHAR(50));
DECLARE @GoodIssueToExportDDPath NVARCHAR(50) = N'documents/' + CAST(@GoodIssueToExportDD AS NVARCHAR(50));
DECLARE @ExportToTradeReceivableDDPath NVARCHAR(50) = N'documents/' + CAST(@ExportToTradeReceivableDD AS NVARCHAR(50));
DECLARE @GoodServiceIssueToTradeReceivableDDPath NVARCHAR(50) = N'documents/' + CAST(@GoodServiceIssueToTradeReceivableDD AS NVARCHAR(50));
DECLARE @SteelProductionDDPath NVARCHAR(50) = N'documents/' + CAST(@SteelProductionDD AS NVARCHAR(50));
DECLARE @PlasticProductionDDPath NVARCHAR(50) = N'documents/' + CAST(@PlasticProductionDD AS NVARCHAR(50));
DECLARE @PaintProductionDDPath NVARCHAR(50) = N'documents/' + CAST(@PaintProductionDD AS NVARCHAR(50));
DECLARE @VehicleAssemblyDDPath NVARCHAR(50) = N'documents/' + CAST(@VehicleAssemblyDD AS NVARCHAR(50));
DECLARE @GrainProcessingDDPath NVARCHAR(50) = N'documents/' + CAST(@GrainProcessingDD AS NVARCHAR(50));
DECLARE @OilMillingDDPath NVARCHAR(50) = N'documents/' + CAST(@OilMillingDD AS NVARCHAR(50));
DECLARE @MaintenanceDDPath NVARCHAR(50) = N'documents/' + CAST(@MaintenanceDD AS NVARCHAR(50));
DECLARE @PaymentIssueToEmployeeDDPath NVARCHAR(50) = N'documents/' + CAST(@PaymentIssueToEmployeeDD AS NVARCHAR(50));
DECLARE @EmployeeLoanDDPath NVARCHAR(50) = N'documents/' + CAST(@EmployeeLoanDD AS NVARCHAR(50));
DECLARE @AttendanceRegisterDDPath NVARCHAR(50) = N'documents/' + CAST(@AttendanceRegisterDD AS NVARCHAR(50));
DECLARE @EmployeeOvertimeDDPath NVARCHAR(50) = N'documents/' + CAST(@EmployeeOvertimeDD AS NVARCHAR(50));
DECLARE @EmployeePenaltyDDPath NVARCHAR(50) = N'documents/' + CAST(@EmployeePenaltyDD AS NVARCHAR(50));
DECLARE @EmployeeRewardDDPath NVARCHAR(50) = N'documents/' + CAST(@EmployeeRewardDD AS NVARCHAR(50));
DECLARE @EmployeeLeaveDDPath NVARCHAR(50) = N'documents/' + CAST(@EmployeeLeaveDD AS NVARCHAR(50));
DECLARE @EmployeeLeaveAllowanceDDPath NVARCHAR(50) = N'documents/' + CAST(@EmployeeLeaveAllowanceDD AS NVARCHAR(50));
DECLARE @EmployeeTravelDDPath NVARCHAR(50) = N'documents/' + CAST(@EmployeeTravelDD AS NVARCHAR(50));
INSERT INTO @Roles([Index],[Code],[Name],[IsPublic]) VALUES
(0, N'Administrator', N'Administrator', 0),
(1, N'GeneralManager', N'General Manager', 0),
(2, N'FinanceManager', N'Finance Manager', 0),
(3, N'Comptroller', N'Comptroller', 0),
(4, N'Accountant', N'Accountant', 0),
(5, N'Cashier', N'Cashier', 0),
(6, N'InternalAuditor', N'Internal Auditor', 0),
(7, N'ExternalAuditor', N'External Auditor', 0),
(8, N'InventoryCustodian', N'Inventory Custodian', 0),
(9, N'AdminAffairs', N'Admin. Affairs', 0),
(10, N'ProductionManager', N'Production Manager', 0),
(11, N'ProjectManager', N'Project Manager', 0),
(12, N'HrManager', N'HR Manager', 0),
(13, N'SalesManager', N'Sales Manager', 0),
(14, N'SalesPerson', N'Sales Person', 0),
(15, N'AccountManager', N'Account Manager', 0),
(98, N'Reader', N'Reader', 0),
(99, N'Public', N'Public', 1);

INSERT INTO @Members([Index], [HeaderIndex], [UserId]) VALUES(0, 0, @AdminUserId);

INSERT INTO @Permissions([Index], [HeaderIndex],
--Action: N'Read', N'Update', N'Delete', N'IsActive', N'ResendInvitationEmail', N'State', N'All'))
			[Action],	[Criteria],			[View]) VALUES
 (0,0,		N'All',		NULL,				N'all'),
-- 2:GeneralManager
(10,1,		N'Read',	NULL,				N'all'),
-- 3:FinanceManager
(20,2,	N'Read',	NULL,				N'all'),
-- 11:Comptroller
(30,3,	N'All',		NULL,				@ManualJournalVoucherDDPath),
(31,3,	N'All',		NULL,				@PaymentIssueToNonTradingAgentsDDPath),
(32,3,	N'All',		NULL,				@GoodServiceIssueToTradeReceivableDDPath),
(33,3,	N'All',		NULL,				N'accounts'),
(34,3,	N'All',		NULL,				N'centers'),
(35,3,	N'All',		NULL,				N'currencies'),
-- 12:Accountant
(40,4,	N'All',		NULL,				@ManualJournalVoucherDDPath),
(41,4,	N'All',		NULL,				@PaymentIssueToNonTradingAgentsDDPath),
(42,4,	N'All',		NULL,				@GoodServiceIssueToTradeReceivableDDPath),
(43,4,	N'Read',	NULL,				N'accounts'),
(44,4,	N'Read',	NULL,				N'centers'),
-- 13:Cashier
(50,5,	N'Update',	N'Agent/UserId = Me or AssigneeId = Me',
											@PaymentReceiptFromNonTradingAgentsDDPath),
(51,5,	N'Update',	N'AssignedById = Me or AssigneeId = Me',
											@PaymentIssueToNonTradingAgentsDDPath),
-- 20:InternalAuditor
(60,6,	N'Read',	NULL,				N'all'), -- GM
-- 3:ExtenralAuditor
(70,7,	N'Read',	NULL,				N'all'), -- GM
-- Board
(980,98,		N'Read',	NULL,				N'all'),
-- 99:Public
(9901,99,	N'Read',	NULL,				N'currencies'),-- inbox public permission is hardcoded
(9903,99,	N'Read',	NULL,				N'entry-types'),
(9905,99,	N'Read',	NULL,				N'exchange-rates'),
(9907,99,	N'Read',	NULL,				N'roles'),
(9909,99,	N'Read',	NULL,				N'units'),
(9911,99,	N'Read',	NULL,				N'users');

INSERT INTO @Permissions([Index], [HeaderIndex],
--Action: N'Read', N'Update', N'Delete', N'IsActive', N'ResendInvitationEmail', N'State', N'All'))
			[Action],	[Criteria],			[View])

SELECT 9921,99,	N'Read',	NULL,				N'lookups/' + CAST(@ITEquipmentManufacturerLKD AS NVARCHAR(100)) UNION
SELECT 9922,99,	N'Read',	NULL,				N'lookups/' + CAST(@OperatingSystemLKD AS NVARCHAR(100)) UNION
SELECT 9923,99,	N'Read',	NULL,				N'lookups/' + CAST(@BodyColorLKD AS NVARCHAR(100)) UNION
SELECT 9924,99,	N'Read',	NULL,				N'lookups/' + CAST(@VehicleMakeLKD AS NVARCHAR(100)) UNION
SELECT 9925,99,	N'Read',	NULL,				N'lookups/' + CAST(@SteelThicknessLKD AS NVARCHAR(100)) UNION
SELECT 9926,99,	N'Read',	NULL,				N'lookups/' + CAST(@PaperOriginLKD AS NVARCHAR(100)) UNION
SELECT 9927,99,	N'Read',	NULL,				N'lookups/' + CAST(@PaperGroupLKD AS NVARCHAR(100)) UNION
SELECT 9928,99,	N'Read',	NULL,				N'lookups/' + CAST(@PaperTypeLKD AS NVARCHAR(100)) UNION
SELECT 9929,99,	N'Read',	NULL,				N'lookups/' + CAST(@GrainClassificationLKD AS NVARCHAR(100)) UNION
SELECT 9930,99,	N'Read',	NULL,				N'lookups/' + CAST(@GrainTypeLKD AS NVARCHAR(100)) UNION
SELECT 9931,99,	N'Read',	NULL,				N'lookups/' + CAST(@BankAccountTypeLKD AS NVARCHAR(100)) UNION

SELECT 9951,99,	N'Read',	NULL,				N'resources/' + CAST(@RevenueServiceRD AS NVARCHAR(100)) UNION
SELECT 9961,99,	N'Read',	NULL,				N'resources/' + CAST(@EmployeeBenefitRD AS NVARCHAR(100)) UNION

SELECT 9971,99,	N'Read',	NULL,				N'relations/' + CAST(@WarehouseCD AS NVARCHAR(100)) UNION

SELECT 9981,99,	N'Update',	N'CreatedById = Me',@PaymentIssueToNonTradingAgentsDDPath
--(9991,99,	N'Read',	NULL,				N'account-statement'), permission is based on detailentries
;

EXEC api.Roles__Save
	@Entities = @Roles,
	@Members = @Members,
	@Permissions = @Permissions,
	@ValidationErrorsJson = @ValidationErrorsJson OUTPUT;
DELETE FROM @Roles; DELETE FROM @Members; DELETE FROM @Permissions

IF @ValidationErrorsJson IS NOT NULL 
BEGIN
	Print 'Roles: Inserting: ' + @ValidationErrorsJson
	GOTO Err_Label;
END;

-- Declarations
DECLARE @AdministratorRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'Administrator');
DECLARE @GeneralManagerRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'GeneralManager');
DECLARE @FinanceManagerRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'FinanceManager');
DECLARE @ComptrollerRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'Comptroller');
DECLARE @AccountantRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'Accountant');
DECLARE @CashierRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'Cashier');
DECLARE @InternalAuditorRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'InternalAuditor');
DECLARE @ExternalAuditorRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'ExternalAuditor');
DECLARE @InventoryCustodianRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'InventoryCustodian');
DECLARE @AdminAffairsRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'AdminAffairs');
DECLARE @ProductionManagerRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'ProductionManager');
DECLARE @ProjectManagerRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'ProjectManager');
DECLARE @HrManagerRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'HrManager');
DECLARE @SalesManagerRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'SalesManager');
DECLARE @SalesPersonRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'SalesPerson');
DECLARE @AccountManagerRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'AccountManager');
DECLARE @ReaderRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'Reader');
DECLARE @PublicRL INT = (SELECT [Id] FROM dbo.Roles WHERE [Code] = N'Public');