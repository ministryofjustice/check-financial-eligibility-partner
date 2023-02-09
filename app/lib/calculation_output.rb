class CalculationOutput
  def initialize(gross_income_subtotals: nil, capital_subtotals: nil)
    @capital_subtotals = capital_subtotals || instantiate_blank_capital_subtotals
    @gross_income_subtotals = gross_income_subtotals || instantiate_blank_gross_income_subtotals
  end

  attr_reader :capital_subtotals, :gross_income_subtotals

private

  def instantiate_blank_capital_subtotals
    CapitalSubtotals.new(
      applicant_capital_subtotals: PersonCapitalSubtotals.new,
      partner_capital_subtotals: PersonCapitalSubtotals.new,
    )
  end

  def instantiate_blank_gross_income_subtotals
    GrossIncomeSubtotals.new(
      applicant_gross_income_subtotals: PersonGrossIncomeSubtotals.new,
      partner_gross_income_subtotals: PersonGrossIncomeSubtotals.new,
    )
  end
end
