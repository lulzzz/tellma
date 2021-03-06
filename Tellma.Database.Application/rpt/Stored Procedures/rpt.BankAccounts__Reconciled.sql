﻿CREATE PROCEDURE [rpt].[BankAccounts__Reconciled]
	@AsOfDate DATE = NULL
AS
	SET @AsOfDate = ISNULL(@AsOfDate, CAST(GETDATE() AS DATE));
	DECLARE @ReconciliationIds IdList;

	WITH BankAccounts AS (
		SELECT [Id] FROM dbo.Accounts
		WHERE AccountTypeId IN (
			SELECT [Id] FROM dbo.AccountTypes
			WHERE [Concept] = N'BalancesWithBanks'
		)
	)
	SELECT C.[Name] AS BankAccount,
		ReconciledCount = COUNT(DISTINCT R.[Id])
	FROM dbo.Reconciliations  R
	JOIN dbo.ReconciliationExternalEntries REE ON R.[Id] = REE.ReconciliationId
	JOIN dbo.ExternalEntries EE ON REE.[ExternalEntryId] = EE.[Id]
	JOIN dbo.Custodies C ON EE.[CustodyId] = C.[Id]
	WHERE EE.[AccountId] IN (SELECT [Id] FROM BankAccounts)
	AND (@AsOfDate IS NULL OR PostingDate >= @AsOfDate)
	GROUP BY EE.[CustodyId], C.[Name];