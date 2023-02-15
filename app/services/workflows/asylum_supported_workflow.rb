module Workflows
  class AsylumSupportedWorkflow
    class << self
      def call(_assessment)
        CalculationOutput.new
      end
    end
  end
end
