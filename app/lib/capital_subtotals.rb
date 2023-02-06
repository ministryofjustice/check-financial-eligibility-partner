class CapitalSubtotals
  def initialize(applicant_capital_subtotals: PersonCapitalSubtotals.new, partner_capital_subtotals: PersonCapitalSubtotals.new, capital_contribution: nil)
    @applicant_capital_subtotals = applicant_capital_subtotals
    @partner_capital_subtotals = partner_capital_subtotals
    @capital_contribution = capital_contribution
  end

  attr_reader :applicant_capital_subtotals, :partner_capital_subtotals, :capital_contribution
end
