module Decorators
  module V5
    class GrossIncomeResultDecorator
      def initialize(summary)
        @summary = summary
      end

      def as_json
        {
          total_gross_income: summary.total_gross_income.to_f,
          proceeding_types: ProceedingTypesResultDecorator.new(summary).as_json,
        }
      end

    private

      attr_reader :summary
    end
  end
end
