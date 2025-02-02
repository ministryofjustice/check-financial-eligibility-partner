require "rails_helper"

module Collators
  RSpec.describe DisposableIncomeCollator do
    let(:assessment) { disposable_income_summary.assessment }
    let(:child_care_bank) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d(Float::DIG) }
    let(:maintenance_out_bank) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d(Float::DIG) }
    let(:gross_housing) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d(Float::DIG) }
    let(:legal_aid_bank) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d(Float::DIG) }
    let(:housing_benefit) { Faker::Number.between(from: 1.25, to: gross_housing / 2).round(2) }
    let(:net_housing) { gross_housing - housing_benefit }
    let(:employment_income_deductions) { Faker::Number.decimal(l_digits: 3, r_digits: 2).to_d(Float::DIG) }
    let(:fixed_employment_allowance) { 45.0 }
    let(:dependant_allowance) { 582.98 }
    let(:partner_allowance) { 481.29 }
    let(:total_gross_income) { 0 }
    let(:gross_income_subtotals) do
      PersonGrossIncomeSubtotals.new(
        total_gross_income:,
        employment_income_subtotals: EmploymentIncomeSubtotals.new(employment_income_deductions:, fixed_employment_allowance:),
      )
    end

    let(:disposable_income_summary) do
      summary = create(:disposable_income_summary,
                       child_care_bank:,
                       maintenance_out_bank:,
                       gross_housing_costs: gross_housing,
                       rent_or_mortgage_bank: gross_housing,
                       legal_aid_bank:,
                       housing_benefit:,
                       net_housing_costs: net_housing,
                       total_outgoings_and_allowances: 0.0,
                       total_disposable_income: 0.0)
      create :disposable_income_eligibility, disposable_income_summary: summary, proceeding_type_code: "DA001"
      summary
    end

    let(:total_outgoings) do
      disposable_income_summary.child_care_cash +
        disposable_income_summary.maintenance_out_cash +
        disposable_income_summary.legal_aid_cash +
        child_care_bank +
        maintenance_out_bank +
        legal_aid_bank +
        net_housing +
        dependant_allowance -
        employment_income_deductions -
        fixed_employment_allowance +
        partner_allowance
    end

    before { create :gross_income_summary, :with_all_records, assessment: }

    describe ".call" do
      subject(:collator) do
        described_class.call(gross_income_summary: assessment.gross_income_summary,
                             disposable_income_summary: assessment.disposable_income_summary,
                             partner_allowance:,
                             gross_income_subtotals:,
                             outgoings: OutgoingsCollator::Result.new(dependant_allowance:))
      end

      context "total_monthly_outgoings" do
        before do
          collator
        end

        it "sums childcare, legal_aid, maintenance, net housing costs and allowances" do
          expect(disposable_income_summary.total_outgoings_and_allowances).to eq total_outgoings
        end
      end

      context "total disposable income" do
        let(:total_gross_income) { total_outgoings + 1_500 }

        before do
          collator
        end

        it "is populated with result of gross income minus total outgoings and allowances" do
          result = total_gross_income - disposable_income_summary.total_outgoings_and_allowances
          expect(disposable_income_summary.total_disposable_income).to eq result
        end
      end

      context "when total disposable income is negative" do
        let(:total_gross_income) { total_outgoings - 1_500 }

        before do
          collator
        end

        it "returns the correct negative amount" do
          result = total_gross_income - disposable_income_summary.total_outgoings_and_allowances
          expect(disposable_income_summary.total_disposable_income).to eq result
          expect(disposable_income_summary.total_disposable_income).to be_negative
        end
      end

      context "lower threshold" do
        it "populates the lower threshold" do
          collator
          expect(disposable_income_summary.eligibilities.first.lower_threshold).to eq 315.0
        end
      end

      context "upper threshold" do
        context "domestic abuse" do
          it "populates it with infinity" do
            collator
            expect(disposable_income_summary.eligibilities.first.upper_threshold).to eq 999_999_999_999.0
          end
        end
      end

      context "all transactions" do
        it "updates with totals for all categories based on bank and cash transactions" do
          collator
          disposable_income_summary.reload
          child_care_total = disposable_income_summary.child_care_bank + disposable_income_summary.child_care_cash
          maintenance_out_total = disposable_income_summary.maintenance_out_bank + disposable_income_summary.maintenance_out_cash
          rent_or_mortgage_total = disposable_income_summary.rent_or_mortgage_bank + disposable_income_summary.rent_or_mortgage_cash
          legal_aid_total = disposable_income_summary.legal_aid_bank + disposable_income_summary.legal_aid_cash

          expect(disposable_income_summary.child_care_all_sources).to eq child_care_total
          expect(disposable_income_summary.maintenance_out_all_sources).to eq maintenance_out_total
          expect(disposable_income_summary.rent_or_mortgage_all_sources).to eq rent_or_mortgage_total
          expect(disposable_income_summary.legal_aid_all_sources).to eq legal_aid_total
        end
      end
    end
  end
end
