module Collators
  class MaintenanceCollator
    class << self
      def call(disposable_income_summary)
        maintenance_out_bank = Calculators::MonthlyEquivalentCalculator.call(
          collection: disposable_income_summary.maintenance_outgoings,
        )

        # TODO: return this value instead of persisting it
        disposable_income_summary.update!(maintenance_out_bank:)
      end
    end
  end
end
