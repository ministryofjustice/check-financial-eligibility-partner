module Decorators
  module V5
    class VehicleDecorator
      def initialize(record, result)
        @record = record
        @result = result
      end

      def as_json
        {
          value: @record.value.to_f,
          loan_amount_outstanding: @record.loan_amount_outstanding.to_f,
          date_of_purchase: @record.date_of_purchase,
          in_regular_use: @record.in_regular_use,
          included_in_assessment: @result.fetch(:included_in_assessment),
          disregards_and_deductions: @record.value.to_f - assessed_value - @record.loan_amount_outstanding.to_f,
          assessed_value:,
        }
      end

    private

      def assessed_value
        @result.fetch(:value).to_f
      end
    end
  end
end
