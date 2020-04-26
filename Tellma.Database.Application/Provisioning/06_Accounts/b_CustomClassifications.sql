﻿/* Use Cases
Missing
	- Inserting
	- Updating
	- Deleting
	- Activating
	- Deactivating
*/

DECLARE @CustomClassifications dbo.CustomClassificationList;
Declare @Assets_AC INT, @CurrentAssets_AC INT, @BankAndCash_AC INT, @Debtors_AC INT, @Inventories_AC INT, @NonCurrentAssets_AC INT,
	@Liabilities_AC INT, @Equity_AC INT, @Revenue_AC INT, @Expenses_AC INT;
	   
INSERT INTO @CustomClassifications([Index],
[Name],							[Code], [ParentIndex]) VALUES
(0,	N'Assets',					N'100',	NULL),
(1, N'Current Assets',			N'110',	0),
(2, N'Bank and Cash',			N'111',	1),
(3, N'Debtors',					N'112',	1),
(4, N'Inventory',				N'113', 1),
(5, N'Non-current Assets',		N'120',	0),
(6, N'Liabilities',				N'200',	NULL),
(7, N'Current Liabilities',		N'210',	6),
(8, N'Non Current Liabilities',	N'220',	6),
(9, N'Equity',					N'300',	NULL),
(10, N'Revenue',				N'400',	NULL),
(11, N'Expenses',				N'500',	NULL);
;
EXEC [api].[CustomClassifications__Save] --  N'cash-and-cash-equivalents',
	@Entities = @CustomClassifications,
	@ValidationErrorsJson = @ValidationErrorsJson OUTPUT;

IF @ValidationErrorsJson IS NOT NULL 
BEGIN
	Print 'Inserting CustomClassifications: ' + @ValidationErrorsJson
	GOTO Err_Label;
END;

SELECT @Assets_AC = [Id] FROM dbo.[CustomClassifications] WHERE Code = N'100';
SELECT @CurrentAssets_AC = [Id] FROM dbo.[CustomClassifications] WHERE Code = N'110';
SELECT @BankAndCash_AC = [Id] FROM dbo.[CustomClassifications] WHERE Code = N'111';
SELECT @Debtors_AC = [Id] FROM dbo.[CustomClassifications] WHERE Code = N'112';
SELECT @Inventories_AC = [Id] FROM dbo.[CustomClassifications] WHERE Code = N'113';
SELECT @NonCurrentAssets_AC = [Id] FROM dbo.[CustomClassifications] WHERE Code = N'120';
SELECT @Liabilities_AC = [Id] FROM dbo.[CustomClassifications] WHERE Code = N'200';
SELECT @Equity_AC = [Id] FROM dbo.[CustomClassifications] WHERE Code = N'300';
SELECT @Revenue_AC = [Id] FROM dbo.[CustomClassifications] WHERE Code = N'400';
SELECT @Expenses_AC = [Id] FROM dbo.[CustomClassifications] WHERE Code = N'500';

IF @DebugCustomClassifications = 1
	SELECT
		AC.Id,
		SPACE(5 * (AC.[Node].GetLevel() - 1)) +  AC.[Name] As [Name],
		[Code],
		AC.[Node].ToString() As [Node],
		(SELECT COUNT(*) FROM [CustomClassifications] WHERE [ParentNode] = AC.[Node]) AS [ChildCount]
	FROM dbo.[CustomClassifications] AC