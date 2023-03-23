require "rails_helper"

module Collators
  RSpec.describe OutgoingsCollator, :calls_bank_holiday do
    let(:assessment) { create :assessment, :with_everything }
    let(:person) do
      instance_double(PersonWrapper, employed?: assessment.applicant&.employed?,
                                     dependants: assessment.dependants,
                                     gross_income_summary: assessment.gross_income_summary)
    end
    let(:category_subtotal) { OpenStruct.new(all_sources: 0) }

    subject(:collator) do
      described_class.call(submission_date: assessment.submission_date,
                           person:,
                           disposable_income_summary: assessment.disposable_income_summary,
                           eligible_for_childcare: true,
                           allow_negative_net: true,
                           partner_allowance: 0,
                           gross_income_subtotals: PersonGrossIncomeSubtotals.new)
    end

    describe ".call" do
      it "calls all the collators and calculators" do
        expect(Collators::ChildcareCollator).to receive(:call).exactly(1).and_return(category_subtotal)
        expect(Collators::DependantsAllowanceCollator).to receive(:call).exactly(1).and_return(0)
        expect(Collators::MaintenanceCollator).to receive(:call).with(assessment.disposable_income_summary, assessment.gross_income_summary).exactly(1).and_return(category_subtotal)
        expect(Collators::HousingCostsCollator).to receive(:call).and_return(OpenStruct.new(net_housing_costs: 0, rent_or_mortgage_subtotals: 0, housing_costs_subtotals: 0)).exactly(1)
        expect(Collators::LegalAidCollator).to receive(:call).with(assessment.disposable_income_summary, assessment.gross_income_summary).exactly(1).and_return(category_subtotal)
        collator
      end
    end
  end
end
