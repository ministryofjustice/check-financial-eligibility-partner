class DisposableIncomeSubtotals
  def initialize(applicant_disposable_income_subtotals: nil, partner_disposable_income_subtotals: nil,
                 combined_monthly_outgoings: 0, combined_monthly_disposable_income: 0,
                 monthly_income_contribution: 0)
    @applicant_disposable_income_subtotals = applicant_disposable_income_subtotals || PersonDisposableIncomeSubtotals.new
    @partner_disposable_income_subtotals = partner_disposable_income_subtotals || PersonDisposableIncomeSubtotals.new
    @combined_monthly_outgoings = combined_monthly_outgoings
    @combined_monthly_disposable_income = combined_monthly_disposable_income
    @monthly_income_contribution = monthly_income_contribution
  end

  attr_reader :applicant_disposable_income_subtotals, :partner_disposable_income_subtotals,
              :combined_monthly_outgoings, :combined_monthly_disposable_income, :monthly_income_contribution
end
