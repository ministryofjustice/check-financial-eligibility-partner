module Collators
  class ChildcareCollator
    class << self
      def call(disposable_income_summary:, gross_income_summary:, eligible_for_childcare:)
        if eligible_for_childcare
          subtotals(cash: cash(gross_income_summary), bank: bank(disposable_income_summary), regular: regular(gross_income_summary))
        else
          subtotals(cash: 0, bank: 0, regular: 0)
        end
      end

    private

      def subtotals(cash:, bank:, regular:)
        TransactionCategorySubtotals.new(category: :child_care, cash:, bank:, regular:).freeze
      end

      def bank(disposable_income_summary)
        Calculators::MonthlyEquivalentCalculator.call(
          assessment_errors: disposable_income_summary.assessment.assessment_errors,
          collection: disposable_income_summary.childcare_outgoings,
        )
      end

      def cash(gross_income_summary)
        Calculators::MonthlyCashTransactionAmountCalculator.call(gross_income_summary:, operation: :debit, category: :child_care)
      end

      def regular(gross_income_summary)
        Calculators::MonthlyRegularTransactionAmountCalculator.call(gross_income_summary:, operation: :debit, category: :child_care)
      end
    end
  end
end
