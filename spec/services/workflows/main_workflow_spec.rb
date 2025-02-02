require "rails_helper"

module Workflows
  RSpec.describe ".call" do
    let(:proceedings_hash) { [%w[DA003 A], %w[SE013 I]] }
    let(:bank_holiday_response) { %w[2015-01-01 2015-04-03 2015-04-06] }
    let(:assessment) do
      create :assessment,
             :with_everything,
             proceedings: proceedings_hash,
             applicant:
    end

    before do
      allow(GovukBankHolidayRetriever).to receive(:dates).and_return(bank_holiday_response)
    end

    context "applicant is asylum_supported" do
      let(:applicant) { create :applicant, receives_asylum_support: true }

      it "calls normal workflows by default" do
        allow(PassportedWorkflow).to receive(:call).and_return(CalculationOutput.new)
        expect(Assessors::MainAssessor).to receive(:call).with(assessment)
        MainWorkflow.call(assessment)
      end

      context "for immigration/asylum proceeding types" do
        let(:proceedings_hash) { [%w[IM030 A]] }

        it "does not call a workflow" do
          expect(PassportedWorkflow).not_to receive(:call)
          expect(NonPassportedWorkflow).not_to receive(:call)
          expect(Assessors::MainAssessor).to receive(:call).with(assessment)
          MainWorkflow.call(assessment)
        end
      end
    end

    context "applicant is passported" do
      let(:applicant) { create :applicant, :with_qualifying_benefits }

      subject(:workflow_call) { MainWorkflow.call(assessment) }

      it "calls PassportedWorkflow" do
        allow(Assessors::MainAssessor).to receive(:call)
        allow(PassportedWorkflow).to receive(:call).with(assessment).and_return(CalculationOutput.new)
        workflow_call
      end

      it "calls MainAssessor" do
        allow(PassportedWorkflow).to receive(:call).and_return(CalculationOutput.new)
        expect(Assessors::MainAssessor).to receive(:call).with(assessment)
        workflow_call
      end
    end

    context "applicant is not passported" do
      let(:applicant) { create :applicant, :without_qualifying_benefits }

      subject(:workflow_call) { MainWorkflow.call(assessment) }

      it "calls NonPassportedWorkflow" do
        allow(Assessors::MainAssessor).to receive(:call)
        allow(NonPassportedWorkflow).to receive(:call).with(assessment).and_return(CalculationOutput.new)
        workflow_call
      end

      it "calls MainAssessor" do
        allow(NonPassportedWorkflow).to receive(:call).and_return(CalculationOutput.new)
        expect(Assessors::MainAssessor).to receive(:call).with(assessment)
        workflow_call
      end
    end

    context "version 5" do
      let(:assessment) do
        create :assessment,
               :with_capital_summary,
               :with_capital_summary,
               :with_gross_income_summary,
               :with_disposable_income_summary,
               proceedings: proceedings_hash,
               version: "5",
               applicant:
      end
      let(:applicant) { create :applicant, :without_qualifying_benefits }

      subject(:workflow_call) { MainWorkflow.call(assessment) }

      context "with proceeding types" do
        it "Populates proceeding types with thresholds" do
          expect(Utilities::ProceedingTypeThresholdPopulator).to receive(:call).with(assessment)

          allow(Creators::EligibilitiesCreator).to receive(:call).with(assessment)
          allow(NonPassportedWorkflow).to receive(:call).with(assessment).and_return(CalculationOutput.new)
          allow(Assessors::MainAssessor).to receive(:call).with(assessment)
          allow(RemarkGenerators::Orchestrator).to receive(:call).with(assessment, 0)

          workflow_call
        end

        it "creates the eligibility records" do
          expect(Creators::EligibilitiesCreator).to receive(:call).with(assessment)

          allow(Utilities::ProceedingTypeThresholdPopulator).to receive(:call).with(assessment)
          allow(NonPassportedWorkflow).to receive(:call).with(assessment).and_return(CalculationOutput.new)
          allow(Assessors::MainAssessor).to receive(:call).with(assessment)
          allow(RemarkGenerators::Orchestrator).to receive(:call).with(assessment, 0)

          workflow_call
        end
      end
    end
  end
end
