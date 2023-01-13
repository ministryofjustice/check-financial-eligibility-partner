# WARNING: This calculator assumes that the assessed value/equity of all disputed properties and vehicles
# has already been calculated. If this is not the case, it will produce inaccurate results.
module Calculators
  class SubjectMatterOfDisputeDisregardCalculator
    delegate :disputed_capital_items, :disputed_vehicles, :disputed_properties, to: :@capital_summary

    def initialize(submission_date:, capital_summary:, maximum_disregard:, disputed_vehicle_value:)
      @submission_date = submission_date
      @capital_summary = capital_summary
      @maximum_disregard = maximum_disregard
      @disputed_vehicle_value = disputed_vehicle_value
    end

    def value
      total_disputed_asset_value = disputed_capital_value +
        disputed_property_value +
        @disputed_vehicle_value

      if total_disputed_asset_value.positive? && @maximum_disregard.nil?
        raise "SMOD assets listed but no threshold data found"
      end

      [total_disputed_asset_value, @maximum_disregard].compact.min
    end

  private

    def disputed_capital_value
      disputed_capital_items.sum(:value)
    end

    def disputed_property_value
      disputed_properties.sum(:assessed_equity)
    end
  end
end
