module Calculators
  class HousingCostsCalculator
    def initialize(disposable_income_summary:, gross_housing_costs:, submission_date:, person:)
      @disposable_income_summary = disposable_income_summary
      @submission_date = submission_date
      @person = person
      @gross_housing_costs = gross_housing_costs
    end

    def net_housing_costs
      if housing_costs_cap_apply?
        [@gross_housing_costs, gross_cost_minus_housing_benefit, single_monthly_housing_costs_cap].min
      elsif should_halve_full_cost_minus_benefits?
        gross_cost_minus_housing_benefit / 2
      else
        gross_cost_minus_housing_benefit
      end
    end

    def monthly_housing_benefit
      @monthly_housing_benefit ||= begin
        housing_benefit_payments = Calculators::MonthlyEquivalentCalculator.call(
          assessment_errors: @disposable_income_summary.assessment.assessment_errors,
          collection: housing_benefit_records,
        )
        housing_benefit_payments + monthly_housing_benefit_regular_transactions
      end
    end

    def gross_housing_costs_bank
      Calculators::MonthlyEquivalentCalculator.call(
        assessment_errors: @disposable_income_summary.assessment.assessment_errors,
        collection: @disposable_income_summary.housing_cost_outgoings,
        amount_method: :allowable_amount,
      )
    end

  private

    def monthly_housing_benefit_regular_transactions
      Calculators::MonthlyRegularTransactionAmountCalculator.call(gross_income_summary: @person.gross_income_summary, operation: :credit, category: :housing_benefit)
    end

    def gross_cost_minus_housing_benefit
      @gross_housing_costs - monthly_housing_benefit
    end

    def housing_benefit_records
      @person.housing_benefit_payments
    end

    def all_board_and_lodging?
      @disposable_income_summary.housing_cost_outgoings.present? &&
        @disposable_income_summary.housing_cost_outgoings.map(&:housing_cost_type).all?("board_and_lodging")
    end

    def should_halve_full_cost_minus_benefits?
      should_exclude_housing_benefit? && all_board_and_lodging?
    end

    def should_exclude_housing_benefit?
      receiving_housing_benefits?
    end

    def receiving_housing_benefits?
      @person.housing_benefit_payments.present? ||
        monthly_housing_benefit_regular_transactions.positive?
    end

    def single_monthly_housing_costs_cap
      Threshold.value_for(:single_monthly_housing_costs_cap, at: @submission_date)
    end

    def housing_costs_cap_apply?
      person_single? && person_has_no_dependants?
    end

    def person_single?
      @person.single?
    end

    def person_has_no_dependants?
      @person.dependants.none?
    end
  end
end
