module Decorators
  module V5
    class CapitalDecorator
      def initialize(summary, result)
        @summary = summary
        @result = result
      end

      def as_json
        payload unless @summary.nil?
      end

    private

      def payload
        {
          capital_items:,
        }
      end

      def capital_items
        {
          liquid: liquid_items,
          non_liquid: non_liquid_items,
          vehicles:,
          properties:,
        }
      end

      def properties
        {
          main_home: PropertyDecorator.new(@summary.main_home)&.as_json,
          additional_properties:,
        }
      end

      def liquid_items
        @summary.liquid_capital_items.map { |i| CapitalItemDecorator.new(i).as_json }
      end

      def non_liquid_items
        @summary.non_liquid_capital_items.map { |ni| CapitalItemDecorator.new(ni).as_json }
      end

      def additional_properties
        @summary.additional_properties.map { |p| PropertyDecorator.new(p).as_json }
      end

      def vehicles
        @summary.vehicles.map do |v|
          value = Assessors::VehicleAssessor.call(
            value: v.value,
            loan_amount_outstanding: v.loan_amount_outstanding,
            date_of_purchase: v.date_of_purchase,
            in_regular_use: v.in_regular_use,
            submission_date: @summary.assessment.submission_date,
          )
          VehicleDecorator.new(v, value).as_json
        end
      end
    end
  end
end
