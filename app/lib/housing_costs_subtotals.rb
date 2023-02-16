class HousingCostsSubtotals
  def initialize(housing_benefit: 0, gross_housing_costs: 0, net_housing_costs: 0)
    @housing_benefit = housing_benefit
    @gross_housing_costs = gross_housing_costs
    @net_housing_costs = net_housing_costs
  end

  attr_reader :housing_benefit, :gross_housing_costs, :net_housing_costs
end
