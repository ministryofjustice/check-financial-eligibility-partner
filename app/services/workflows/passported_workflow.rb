module Workflows
  class PassportedWorkflow
    class << self
      def call(assessment)
        capital_subtotals = CapitalCollatorAndAssessor.call assessment, total_monthly_disposable_income: 0
        CalculationOutput.new(capital_subtotals:)
      end
    end
  end
end
