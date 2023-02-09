class GrossIncomeSubtotals
  def initialize(applicant_gross_income_subtotals:, partner_gross_income_subtotals: nil, combined_monthly_gross_income: nil)
    @applicant_gross_income_subtotals = applicant_gross_income_subtotals
    @partner_gross_income_subtotals = partner_gross_income_subtotals
    @combined_monthly_gross_income = combined_monthly_gross_income
  end

  attr_reader :applicant_gross_income_subtotals, :partner_gross_income_subtotals, :combined_monthly_gross_income
end
