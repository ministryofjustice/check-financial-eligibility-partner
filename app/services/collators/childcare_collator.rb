module Collators
  class ChildcareCollator
    include Transactions
    include ChildcareEligibility

    class << self
      def call(submission_date:, disposable_income_summary:, gross_income_summary:, person:, all_dependants:)
        new(submission_date:, disposable_income_summary:, gross_income_summary:, person:, all_dependants:).call
      end
    end

    def initialize(submission_date:, disposable_income_summary:, gross_income_summary:, person:, all_dependants:)
      @submission_date = submission_date
      @disposable_income_summary = disposable_income_summary
      @gross_income_summary = gross_income_summary
      @person = person
      @all_dependants = all_dependants
    end

    def call
      @disposable_income_summary.calculate_monthly_childcare_amount!(eligible_for_childcare, monthly_child_care_cash)
    end

  private

    def monthly_child_care_cash
      monthly_cash_transaction_amount_by(gross_income_summary: @gross_income_summary, operation: :debit, category: :child_care)
    end

    def eligible_for_childcare
      eligible_for_childcare_costs?(@person, @submission_date, @all_dependants)
    end
  end
end
