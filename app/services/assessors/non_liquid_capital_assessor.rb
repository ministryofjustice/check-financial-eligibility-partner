module Assessors
  class NonLiquidCapitalAssessor
    class << self
      def call(non_liquid_capital_items)
        total_value = 0.0
        non_liquid_capital_items.each do |item|
          total_value += item.value
        end
        total_value.round(2)
      end
    end
  end
end
