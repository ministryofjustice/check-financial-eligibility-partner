class PersonCapitalSubtotals
  def initialize(data = {})
    @total_vehicle = data[:total_vehicle]
    @assessed_capital = data[:assessed_capital]
    @assessment_result = data[:assessment_result]
    @capital_contribution = data[:capital_contribution]
    @total_capital = data[:total_capital]
    @total_liquid = data[:total_liquid]
    @total_mortgage_allowance = data[:total_mortgage_allowance]
    @total_non_liquid = data[:total_non_liquid]
    @total_property = data[:total_property]
  end

  attr_reader :total_vehicle,
              :assessed_capital,
              :assessment_result,
              :capital_contribution,
              :total_capital,
              :total_liquid,
              :total_mortgage_allowance,
              :total_non_liquid,
              :total_property
end
