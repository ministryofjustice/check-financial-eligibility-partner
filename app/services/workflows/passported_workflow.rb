module Workflows
  class PassportedWorkflow
    class << self
      def call(assessment)
        capital_collation = CapitalCollatorAndAssessor.call assessment
        CalculationOutput.new(capital_collation:)
      end
    end
  end
end
