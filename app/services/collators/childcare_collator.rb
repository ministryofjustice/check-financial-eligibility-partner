module Collators
  class ChildcareCollator
    Result = Data.define(:cash, :bank)

    class << self
      def call(gross_income_summary:, eligible_for_childcare:, assessment_errors:, childcare_outgoings:)
        if eligible_for_childcare
          subtotals(cash: cash(gross_income_summary),
                    bank: bank(assessment_errors:, childcare_outgoings:),
                    regular: regular(gross_income_summary))
        else
          subtotals(cash: 0, bank: 0, regular: 0)
        end
      end

    private

      def subtotals(cash:, bank:, regular:)
        TransactionCategorySubtotals.new(category: :child_care, cash:, bank:, regular:).freeze
      end

      def bank(assessment_errors:, childcare_outgoings:)
        Calculators::MonthlyEquivalentCalculator.call(
          assessment_errors:,
          collection: childcare_outgoings,
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
