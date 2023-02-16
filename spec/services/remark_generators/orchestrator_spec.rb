require "rails_helper"

module RemarkGenerators
  RSpec.describe Orchestrator do
    let(:assessment) { create :assessment }
    let(:state_benefits) { assessment.gross_income_summary.state_benefits }
    let(:state_benefit_payments) { state_benefits.first.state_benefit_payments }
    let(:other_income_sources) { assessment.gross_income_summary.other_income_sources }
    let(:other_income_payments) { other_income_sources.first.other_income_payments }
    let(:childcare_outgoings) { assessment.disposable_income_summary.childcare_outgoings }
    let(:maintenance_outgoings) { assessment.disposable_income_summary.maintenance_outgoings }
    let(:housing_outgoings) { assessment.disposable_income_summary.housing_cost_outgoings }
    let(:legal_aid_outgoings) { assessment.disposable_income_summary.legal_aid_outgoings }
    let(:employment_payments) { assessment.employments.first.employment_payments }
    let(:disposable_income_subtotals) { :disposable_income_subtotals }

    before do
      create(:disposable_income_summary, :with_everything, assessment:)
      create(:gross_income_summary, :with_everything, :with_employment, assessment:)
      create :bank_holiday
    end

    it "calls the checkers with each collection" do
      expect(MultiBenefitChecker).to receive(:call).with(assessment, state_benefit_payments)
      expect(AmountVariationChecker).to receive(:call).with(assessment, state_benefit_payments)
      expect(AmountVariationChecker).to receive(:call).with(assessment, other_income_payments)
      expect(AmountVariationChecker).to receive(:call).with(assessment, childcare_outgoings, disposable_income_subtotals)
      expect(AmountVariationChecker).to receive(:call).with(assessment, maintenance_outgoings, disposable_income_subtotals)
      expect(AmountVariationChecker).to receive(:call).with(assessment, housing_outgoings, disposable_income_subtotals)
      expect(AmountVariationChecker).to receive(:call).with(assessment, legal_aid_outgoings, disposable_income_subtotals)
      expect(FrequencyChecker).to receive(:call).with(assessment, state_benefit_payments)
      expect(FrequencyChecker).to receive(:call).with(assessment, other_income_payments)
      expect(FrequencyChecker).to receive(:call).with(assessment, childcare_outgoings, disposable_income_subtotals)
      expect(FrequencyChecker).to receive(:call).with(assessment, maintenance_outgoings, disposable_income_subtotals)
      expect(FrequencyChecker).to receive(:call).with(assessment, housing_outgoings, disposable_income_subtotals)
      expect(FrequencyChecker).to receive(:call).with(assessment, legal_aid_outgoings, disposable_income_subtotals)
      expect(FrequencyChecker).to receive(:call).with(assessment, employment_payments, nil, date_attribute: :date)

      expect(ResidualBalanceChecker).to receive(:call).with(assessment, 0)

      described_class.call(assessment, 0, disposable_income_subtotals)
    end
  end
end
