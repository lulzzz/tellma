﻿-- for account types parent code, we use the IAS 1 level. 
-- together with that, we use:
-- AccountTagId, Currency, Responsibility Center, IsCurrent, Resource.AccountType, AgentDefinitionList to figure out the account
-- 
IF @DB = N'101' -- Banan SD, USD, en
BEGIN
--ManualLine 
INSERT @LineDefinitions([Index],
[Id],			[TitleSingular], [TitlePlural]) VALUES
(0,N'ManualLine', N'Adjustment', N'Adjustments');
INSERT INTO @LineDefinitionColumns([Index], [HeaderIndex],
[SortKey],	[ColumnName],		[Label],		[IsRequiredForStateId],
												[IsReadOnlyFromStateId]) VALUES
(0,0,0,		N'Line.Memo',		N'Memo',		5,4), -- only if it appears,
(1,0,1,		N'Entry[0].Account',N'Account',		3,4),
(2,0,2,		N'Entry[0].Value',	N'Debit',		3,4), -- see special case
(3,0,3,		N'Entry[0].Value',	N'Credit',		3,4),
(4,0,5,		N'Entry[0].Dynamic',N'Properties',	3,4);
INSERT INTO @LineDefinitionStateReasons([Index],[HeaderIndex],
[StateId], [Name],					[Name2]) VALUES
(0,0,-4,	N'Duplicate Line',		N'بيانات مكررة'),
(1,0,-4,	N'Incorrect Analysis',	N'تحليل خطأ'),
(2,0,-4,	N'Other reasons',		N'أسباب أخرى');
--PurchaseInvoice
INSERT @LineDefinitions([Index],
[Id],					[TitleSingular],		[TitleSingular2],	[TitlePlural],			[TitlePlural2]) VALUES
(1,N'PurchaseInvoice',	N'Purchase Invoice',	N'فاتورة مشتريات',	N'Purchase Invoices',	N'فواتير مشتريات');
UPDATE @LineDefinitions
SET [Script] = N'
	--SET NOCOUNT ON
	--DECLARE @ProcessedWideLines WideLineList;

	--INSERT INTO @ProcessedWideLines
	--SELECT * FROM @WideLines;
	-----
	UPDATE @ProcessedWideLines
	SET
		[ResponsibilityCenterId1] = [ResponsibilityCenterId0],
		[ResponsibilityCenterId2] = [ResponsibilityCenterId0],
		[AgentId2]	= [AgentId1],
		[CurrencyId1] = [CurrencyId0],
		[CurrencyId2] = [CurrencyId0],
		[NotedAgentSource0] = [AgentId1],
		[AccountIdentifier1] = [ExternalReference0],
		[MonetaryValue1] = [NotedAmount0],
		[MonetaryValue2] = [NotedAmount0] + [MonetaryAmount0]
	-----
	--SELECT * FROM @ProcessedWideLines;'
WHERE [Index] = 1;
INSERT INTO @LineDefinitionEntries([Index], [HeaderIndex],[EntryNumber],
[Direction],[AccountTypeParentCode],	[AccountTagId], [AgentDefinitionId]) VALUES
(0,1,0,+1,	N'TradeAndOtherPayables',	N'VATX'	,		NULL),
(1,1,1,+1,	N'Accruals',				N'SACR',		N'suppliers'),
(2,1,2,-1,	N'TradeAndOtherPayables',	N'TPBL',		NULL);-- <== AgentDefinitionId is irrelevant here
INSERT INTO @LineDefinitionColumns([Index], [HeaderIndex],
[SortKey],	[ColumnName],				[Label],				[Label2],				[IsRequiredForStateId],
																						[IsReadOnlyFromStateId]) VALUES
(0,1,0,	N'Line.Memo',					N'Memo',				N'البيان',				1,5), 
(1,1,1,	N'Entry[0].NotedDate',			N'Invoice Date',		N'تاريخ الفاتورة',		3,5), 
(2,1,2,	N'Entry[0].ExternalReference',	N'Invoice #',			N'رقم الفاتورة',		3,5), 
(3,1,3,	N'Entry[1].AgentId',			N'Supplier',			N'المورد',				3,4),
(4,1,4,	N'Entry[0].CurrencyId',			N'Currency',			N'العملة',				1,4),
(5,1,5,	N'Entry[0].NotedAmount',		N'Price Excl. VAT',		N'المبلغ قبل الضريية',	1,4),
(6,1,6,	N'Entry[0].MonetaryValue',		N'VAT',					N'القيمة المضافة',		1,4),
(7,1,7,	N'Entry[2].MonetaryValue',		N'Total',				N'المبلغ بعد الضريبة',	1,1),
(8,1,8,	N'Entry[2].DueDate',			N'Due Date',			N'تاريخ الاستحقاق',		1,4),
(9,1,9,	N'Entry[0].ResponsibilityCenterId',	N'Responsibility Center',N'مركز المسؤولية',0,4);
--CashPayment
INSERT @LineDefinitions([Index],
[Id],				[TitleSingular], [TitleSingular2],	[TitlePlural], [TitlePlural2]) VALUES (
2,N'CashPayment',	N'Payment',		N'الدفعية',			N'Payments',	N'الدفعيات');
INSERT INTO @LineDefinitionEntries([Index], [HeaderIndex],[EntryNumber],
[Direction],	[AccountTypeParentCode],	[AccountTagId], [AgentDefinitionId]) VALUES
(0,2,0,	-1,		N'CashAndCashEquivalents',	NULL,			N'cash-custodians');
INSERT INTO @LineDefinitionColumns([Index], [HeaderIndex],
[SortKey],	[ColumnName],						[Label],					[Label2],					[IsRequiredForStateId],
																										[IsReadOnlyFromStateId]) VALUES
(0,2,0,		N'Line.Memo',						N'Memo',					N'البيان',					1,2),
(1,2,1,		N'Entry[0].CurrencyId',				N'Currency',				N'العملة',					1,2),
(2,2,2,		N'Entry[0].MonetaryValue',			N'Pay Amount',				N'المبلغ',					1,2),
(3,2,3,		N'Entry[0].Value',					N'Equiv Amt ($)',			N'($) المعادل',				4,4), 
(4,2,4,		N'Entry[0].NotedAgentName',			N'Beneficiary',				N'المستفيد',				3,4),
(5,2,5,		N'Entry[0].EntryTypeId',			N'Purpose',					N'الغرض',					1,4),
(6,2,6,		N'Entry[0].AgentId',				N'Bank/Cashier',			N'البنك/الخزنة',			3,4),
(7,2,7,		N'Entry[0].AccountIdentifier',		N'Account Identifier',		N'تمييز الحساب',			3,4),
(8,2,8,		N'Entry[0].ExternalReference',		N'Check #/Receipt #',		N'رقم الشيك/رقم الإيصال',	3,4),
(9,2,9,		N'Entry[0].NotedDate'	,			N'Check Date',				N'تاريخ الشيك',				3,4),
(10,2,10,	N'Entry[0].ResponsibilityCenterId',	N'Responsibility Center',	N'مركز المسؤولية',			1,4);
INSERT INTO @LineDefinitionStateReasons([Index],[HeaderIndex],
[StateId], [Name],					[Name2]) VALUES
(0,2,-3,	N'Insufficient Balance',N'الرصيد غير كاف'),
(1,2,-3,	N'Other reasons',		N'أسباب أخرى');
--PettyCashPayment
INSERT @LineDefinitions([Index],
[Id],					[TitleSingular],		[TitleSingular2],	[TitlePlural],			[TitlePlural2]) VALUES (
3,N'PettyCashPayment',	N'Petty Cash Payment',	N'دفعية نثرية',		N'Petty Cash Payments',	N'دفعيات النثرية');
INSERT INTO @LineDefinitionEntries([Index], [HeaderIndex],[EntryNumber],
[Direction],[AccountTypeParentCode],	[AccountTagId]) VALUES
(0,3,0,-1,	N'CashAndCashEquivalents',	N'CASH');
INSERT INTO @LineDefinitionColumns([Index], [HeaderIndex],
[SortKey],	[ColumnName],				[Label],					[Label2],			[IsRequiredForStateId],
																						[IsReadOnlyFromStateId]) VALUES
(0,3,0,		N'NotedDate0',				N'Date',					N'التاريخ',			1,4), 
(1,3,1,		N'Memo',					N'Memo',					N'البيان',			1,4),
(2,3,2,		N'CurrencyId0',				N'Currency',				N'العملة',			1,2), 
(3,3,3,		N'MonetaryValue0',			N'Pay Amount',				N'المبلغ',			1,2), 
(4,3,4,		N'Value0',					N'Equiv Amt ($)',			N'($) المعادل',		4,4), 
(5,3,5,		N'NotedAgentName0',			N'Beneficiary',				N'المستفيد',		1,2),
(6,3,6,		N'EntryTypeId0',			N'Purpose',					N'الغرض',			4,4),
(7,3,7,		N'AgentId0',				N'Petty Cash Custodian',	N'أمين العهدة',		3,4),
(8,3,8,		N'AccountIdentifier0',		N'Account Identifier',		N'تمييزالعهدة',	3,4),
(9,3,9,		N'ExternalReference0',		N'Receipt #',				N'رقم الإيصال',		3,4),
(10,3,10,	N'ResponsibilityCenterId0',	N'Responsibility Center',	N'مركز المسؤولية',	4,4);  
--GoodsReceiptIssue
INSERT @LineDefinitions([Index],
[Id],					[TitleSingular],		[TitleSingular2],	[TitlePlural],			[TitlePlural2]) VALUES (
6,N'GoodsReceiptIssue',	N'Goods Receipt/Issue',	N'استلام مستخدم',	N'Goods Receipt/Issue',	N'استلامات مستخدمين');
UPDATE @LineDefinitions
SET [Script] = N'
	SET NOCOUNT ON
	DECLARE @ProcessedWideLines WideLineList;

	INSERT INTO @ProcessedWideLines
	SELECT * FROM @WideLines;
	-----
	UPDATE @ProcessedWideLines
	SET
		[EntryTypeId0]				= (SELECT [Id] FROM dbo.EntryTypes WHERE [Code] = ''InventoryTransferExtension''),
		[MonetaryAmount1]			= [MonetaryAmount0],
		[ResponsibilityCenterId1]	= [ResponsibilityCenterId0],
		[CurrencyId1]				= [CurrencyId0]
	-----
	SELECT * FROM @ProcessedWideLines;'
WHERE [Index] = 6;
INSERT INTO @LineDefinitionEntries([Index], [HeaderIndex],[EntryNumber],
[Direction],	[AccountTypeParentCode],	[AgentDefinitionId], [AccountTagId]) VALUES
(0,6,0,-1,		N'TradeAndOtherPayables',	N'suppliers',		N'SACR'); -- We may need to add GRIV Inventory underneath, or instead
INSERT INTO @LineDefinitionColumns([Index], [HeaderIndex],
[SortKey],	[ColumnName],						[Label],				[Label2],				[IsRequiredForStateId],
																								[IsReadOnlyFromStateId]) VALUES
(0,6,0,		N'Line.Memo',						N'Memo',				N'البيان',				1,5), 
(1,6,1,		N'Entry[1].AgentId',				N'Supplier',			N'المورد',				3,4),
(2,6,2,		N'Entry[0].AgentId',				N'Beneficiary',			N'المستفيد',			3,4),
(3,6,3,		N'Entry[0].ResourceId',				N'Item',				N'الصنف',				1,4),
(4,6,4,		N'Entry[0].Quantity',				N'Quantity',			N'الكمية',				1,4),
(5,6,5,		N'Entry[0].UnitId',					N'Unit',				N'الوحدة',				1,4),
(6,6,6,		N'Entry[0].CurrencyId',				N'Currency',			N'العملة',				4,4),
(7,6,7,		N'Entry[0].MonetaryAmount',			N'Price Excl. VAT',		N'المبلغ قبل الضريية',	4,4),
(8,6,8,		N'Entry[0].ResponsibilityCenterId',	N'Responsibility Center',N'مركز المسؤولية',	0,4);
--DomesticSubscriptions
INSERT @LineDefinitions([Index],
[Id],						[TitleSingular],			[TitleSingular2],	[TitlePlural],				[TitlePlural2],		[AgentDefinitionList], [ResponsibilityTypeList]) VALUES (
7,N'DomesticSubscriptions',	N'Domestic Subscription',	N'اشتراك محلي',		N'Domestic Subscriptions',	N'اشتراكات محلية',	NULL,					N'Investment');
INSERT INTO @LineDefinitionEntries([Index], [HeaderIndex],[EntryNumber],
[Direction],	[AccountTypeParentCode],	[AccountTagId]) VALUES
(0,7,0,+1,		N'TradeAndOtherReceivables',N'TPBL'), 
(1,7,1,-1,		N'Revenue',					NULL);
END