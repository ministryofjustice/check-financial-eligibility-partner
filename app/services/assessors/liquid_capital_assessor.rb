module Assessors
  class LiquidCapitalAssessor
    class << self
      def call(liquid_capital_items)
        total_liquid_capital = 0.0
        liquid_capital_items.each do |item|
          total_liquid_capital += item.value if item.value.positive?
        end
        total_liquid_capital.round(2)
      end
    end
  end
end
