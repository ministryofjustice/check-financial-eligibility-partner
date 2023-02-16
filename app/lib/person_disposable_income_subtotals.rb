class PersonDisposableIncomeSubtotals
  def initialize(data = Hash.new(0.0))
    @category_subtotals = data.fetch(:category_subtotals, [])
    @housing_costs_subtotals = data.fetch(:housing_costs_subtotals, HousingCostsSubtotals.new)
    @partner_allowance = data[:partner_allowance]
    @dependant_allowance = data[:dependant_allowance]
    @total_monthly_outgoings = data[:total_monthly_outgoings]
    @total_monthly_disposable_income = data[:total_monthly_disposable_income]
  end

  def categorised_outgoings(outgoing_type, outgoing_category)
    category_data = @category_subtotals.find { _1.category == outgoing_category }
    return 0 unless category_data

    category_data.send(outgoing_type)
  end

  attr_reader :dependant_allowance, :housing_costs_subtotals, :partner_allowance, :total_monthly_outgoings, :total_monthly_disposable_income
end
