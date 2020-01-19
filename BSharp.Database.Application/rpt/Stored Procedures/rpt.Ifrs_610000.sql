﻿CREATE PROCEDURE [rpt].[Ifrs_610000]
--[610000] Statement of changes in equity
	@fromDate DATE, 
	@toDate DATE
AS
BEGIN
	SET NOCOUNT ON;
	
	CREATE TABLE [dbo].#IfrsDisclosureDetails (
		[RowConcept]		NVARCHAR (255)		NOT NULL,
		[ColumnConcept]		NVARCHAR (255)		NOT NULL,
		[Value]				DECIMAL
	);
	DECLARE @IfrsDisclosureId NVARCHAR (255) = N'StatementOfChangesInEquityAbstract';

	INSERT INTO #IfrsDisclosureDetails (
			[RowConcept],
			[ColumnConcept],
			[Value]
	)
	SELECT
		[AT].[Code] AS [RowConcept],
		[ET].[Code] AS [ColumnConcept],
		SUM(E.[Direction] * E.[Value]) AS [Value]
	FROM [map].[DetailsEntries] (@fromDate, @toDate, NULL, NULL, NULL) E
	JOIN dbo.[AccountTypes] [AT] ON E.[AccountTypeId] = [AT].[Id]
	LEFT JOIN dbo.EntryTypes [ET] ON [ET].[Id] = E.[EntryTypeId]
	WHERE [AT].[Code] IN (
		N'IssuedCapital',
		N'RetainedEarnings',
		N'SharePremium',
		N'TreasuryShares',
		N'OtherEquityInterest',
		N'OtherReserves'
	)
	GROUP BY [AT].[Code], [ET].[Code]
	/*
	-- We need to assign the accounts whose AccountType = OtherReserves to one of the below...
RevaluationSurplusMember
ReserveOfExchangeDifferencesOnTranslationMember
ReserveOfCashFlowHedgesMember
ReserveOfGainsAndLossesOnHedgingInstrumentsThatHedgeInvestmentsInEquityInstrumentsMember
ReserveOfChangeInValueOfTimeValueOfOptionsMember
ReserveOfChangeInValueOfForwardElementsOfForwardContractsMember
ReserveOfChangeInValueOfForeignCurrencyBasisSpreadsMember
ReserveOfGainsAndLossesOnFinancialAssetsMeasuredAtFairValueThroughOtherComprehensiveIncomeMember
ReserveOfInsuranceFinanceIncomeExpensesFromInsuranceContractsIssuedExcludedFromProfitOrLossThatWillBeReclassifiedToProfitOrLossMember
ReserveOfInsuranceFinanceIncomeExpensesFromInsuranceContractsIssuedExcludedFromProfitOrLossThatWillNotBeReclassifiedToProfitOrLossMember
ReserveOfFinanceIncomeExpensesFromReinsuranceContractsHeldExcludedFromProfitOrLossMember
ReserveOfGainsAndLossesOnRemeasuringAvailableforsaleFinancialAssetsMember
ReserveOfSharebasedPaymentsMember
ReserveOfRemeasurementsOfDefinedBenefitPlansMember
AmountRecognisedInOtherComprehensiveIncomeAndAccumulatedInEquityRelatingToNoncurrentAssetsOrDisposalGroupsHeldForSaleMember
ReserveOfGainsAndLossesFromInvestmentsInEquityInstrumentsMember
ReserveOfChangeInFairValueOfFinancialLiabilityAttributableToChangeInCreditRiskOfLiabilityMember
ReserveForCatastropheMember
ReserveForEqualisationMember
ReserveOfDiscretionaryParticipationFeaturesMember

	*/
RETURN 0
END