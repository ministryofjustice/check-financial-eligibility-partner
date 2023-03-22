module Collators
  class LegalAidCollator
    class << self
      def call(disposable_income_summary:, gross_income_summary:)
        bank = Calculators::MonthlyEquivalentCalculator.call(
          assessment_errors: disposable_income_summary.assessment.assessment_errors,
          collection: disposable_income_summary.legal_aid_outgoings,
        )

        regular = Calculators::MonthlyRegularTransactionAmountCalculator.call(gross_income_summary:, operation: :debit, category: :legal_aid)

        TransactionCategorySubtotals.new(category: :legal_aid, cash: 0, bank:, regular:)
      end
    end
  end
end
