module Collators
  class MaintenanceCollator
    class << self
      def call(disposable_income_summary, gross_income_summary)
        bank = Calculators::MonthlyEquivalentCalculator.call(
          assessment_errors: disposable_income_summary.assessment.assessment_errors,
          collection: disposable_income_summary.maintenance_outgoings,
        )

        cash =  Calculators::MonthlyCashTransactionAmountCalculator.call(gross_income_summary:, operation: :debit, category: :maintenance_out)

        regular = Calculators::MonthlyRegularTransactionAmountCalculator.call(gross_income_summary:, operation: :debit, category: :maintenance_out)

        TransactionCategorySubtotals.new(category: :maintenance_out, cash:, bank:, regular:)
      end
    end
  end
end
