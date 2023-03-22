require "rails_helper"

module Collators
  RSpec.describe OutgoingsCollator, :calls_bank_holiday do
    let(:assessment) { create :assessment, :with_everything }
    let(:person) do
      instance_double(PersonWrapper,
                      employed?: assessment.applicant&.employed?,
                      single?: true,
                      gross_income_summary: assessment.gross_income_summary,
                      housing_benefit_payments: assessment.gross_income_summary.housing_benefit_payments,
                      dependants: assessment.dependants)
    end
    let(:category_subtotal) { OpenStruct.new(all_sources: 0) }

    subject(:collator) do
      described_class.call(submission_date: assessment.submission_date,
                           person:,
                           gross_income_summary: assessment.gross_income_summary,
                           disposable_income_summary: assessment.disposable_income_summary,
                           eligible_for_childcare: true,
                           allow_negative_net: true)
    end

    describe ".call" do
      it "calls all the collators and calculators" do
        expect(Collators::ChildcareCollator).to receive(:call).exactly(1).and_call_original
        expect(Collators::DependantsAllowanceCollator).to receive(:call).exactly(1).and_call_original
        expect(Collators::MaintenanceCollator)
          .to receive(:call)
            .with(disposable_income_summary: assessment.disposable_income_summary, gross_income_summary: assessment.gross_income_summary)
                           .exactly(1).and_return(category_subtotal)
        expect(Collators::HousingCostsCollator).to receive(:call).exactly(1).and_call_original
        expect(Collators::LegalAidCollator)
          .to receive(:call)
                .with(disposable_income_summary: assessment.disposable_income_summary,
                      gross_income_summary: assessment.gross_income_summary).exactly(1).and_return(category_subtotal)
        collator
      end
    end
  end
end
