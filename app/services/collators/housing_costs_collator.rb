module Collators
  class HousingCostsCollator
    Result = Data.define(:housing_benefit, :gross_housing_costs, :net_housing_costs, :gross_housing_costs_bank)

    class << self
      def call(disposable_income_summary:, submission_date:, person:, allow_negative_net:)
        gross_housing_costs = collate_gross_housing_costs(person.gross_income_summary, disposable_income_summary)
        housing_calculator = Calculators::HousingCostsCalculator.new(disposable_income_summary:,
                                                                     submission_date:,
                                                                     person:,
                                                                     gross_housing_costs: gross_housing_costs.all_sources)

        net_housing_costs = if allow_negative_net
                              housing_calculator.net_housing_costs
                            else
                              [housing_calculator.net_housing_costs, 0.0].max
                            end

        Result.new(
          housing_benefit: housing_calculator.monthly_housing_benefit,
          gross_housing_costs:,
          gross_housing_costs_bank: housing_calculator.gross_housing_costs_bank,
          net_housing_costs:,
        )
      end

      def collate_gross_housing_costs(gross_income_summary, disposable_income_summary)
        cash = Calculators::MonthlyCashTransactionAmountCalculator.call(gross_income_summary:, operation: :debit, category: :rent_or_mortgage)

        bank = Calculators::MonthlyEquivalentCalculator.call(
          assessment_errors: disposable_income_summary.assessment.assessment_errors,
          collection: disposable_income_summary.housing_cost_outgoings,
          amount_method: :allowable_amount,
        )

        regular = Calculators::MonthlyRegularTransactionAmountCalculator.call(gross_income_summary:, operation: :debit, category: :rent_or_mortgage)

        TransactionCategorySubtotals.new(regular:, bank:, cash:).freeze
      end
    end
  end
end
