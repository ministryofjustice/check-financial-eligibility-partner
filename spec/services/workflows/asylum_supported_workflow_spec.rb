require "rails_helper"

module Workflows
  RSpec.describe AsylumSupportedWorkflow do
    describe ".call" do
      it "always returns a calculation result" do
        expect(described_class.call(nil)).to be_a(CalculationOutput)
      end
    end
  end
end
