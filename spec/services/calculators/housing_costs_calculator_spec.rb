require "rails_helper"

module Calculators
  RSpec.describe HousingCostsCalculator do
    subject(:calculator) do
      described_class.new(disposable_income_summary: assessment.disposable_income_summary,
                          person:,
                          submission_date: assessment.submission_date,
                          gross_housing_costs:)
    end

    let(:person) do
      instance_double(PersonWrapper, single?: true,
                                     dependants: assessment.dependants,
                                     gross_income_summary: assessment.gross_income_summary,
                                     housing_benefit_payments: assessment.gross_income_summary.housing_benefit_payments)
    end

    context "when using outgoings and state_benefits" do
      let(:assessment) { create :assessment, :with_gross_income_summary_and_records, :with_disposable_income_summary, with_child_dependants: children }

      before do
        stub_request(:get, "https://www.gov.uk/bank-holidays.json")
          .to_return(body: file_fixture("bank-holidays.json").read)
      end

      context "when applicant has no dependants" do
        let(:children) { 0 }

        context "and does not receive housing benefit" do
          context "when costs are above the cap" do
            let(:gross_housing_costs) { 750 }

            it "caps the return" do
              expect(calculator.net_housing_costs).to eq 545.00 # Cap applied
            end
          end

          context "when costs are below the cap" do
            let(:gross_housing_costs) { 500 }

            it "does not cap the return" do
              expect(calculator.net_housing_costs).to eq 500.00
            end
          end
        end

        context "and receives housing benefit as a state_benefit" do
          before { create_housing_benefit_payments(300) }

          context "with board and lodging costs that exceed the benefit amount" do
            let(:gross_housing_costs) { 400 }

            it "subtracts the benefits in its calculation" do
              expect(calculator.monthly_housing_benefit).to eq 300.00
              expect(calculator.net_housing_costs).to eq 100
            end
          end
        end
      end

      context "when applicant has dependants" do
        let(:gross_housing_costs) { 1200.00 }
        let(:children) { 1 }

        context "with no housing benefit" do
          context "board and lodging" do
            before do
              assessment.disposable_income_summary.housing_cost_outgoings.create housing_cost_type: "board_and_lodging"
            end

            it "records the full monthly housing cost" do
              expect(calculator.monthly_housing_benefit).to eq 0.0
              expect(calculator.net_housing_costs).to eq 1200
            end
          end

          context "rent" do
            before do
              assessment.disposable_income_summary.housing_cost_outgoings.create housing_cost_type: "rent"
            end

            it "records the full monthly housing costs" do
              expect(calculator.net_housing_costs).to eq 1200
            end
          end
        end

        context "with housing benefit as a state_benefit" do
          let(:housing_benefit_amount) { 500.00 }

          before { create_housing_benefit_payments(housing_benefit_amount) }

          context "board and lodging" do
            before do
              assessment.disposable_income_summary.housing_cost_outgoings.create housing_cost_type: "board_and_lodging"
            end

            it "records half the net monthly housing cost" do
              expect(calculator.monthly_housing_benefit).to eq 500.0
              expect(calculator.net_housing_costs).to eq((1200 - 500) / 2)
            end
          end

          context "rent" do
            before do
              assessment.disposable_income_summary.housing_cost_outgoings.create housing_cost_type: "rent"
            end

            it "records the full net monthly housing costs" do
              expect(calculator.net_housing_costs).to eq(1200 - 500)
            end
          end
        end
      end
    end

    def create_housing_benefit_payments(amount)
      housing_benefit_type = create :state_benefit_type, label: "housing_benefit"
      state_benefit = create :state_benefit, gross_income_summary: assessment.gross_income_summary, state_benefit_type: housing_benefit_type
      [2.months.ago, 1.month.ago, Date.current].each do |pay_date|
        create :state_benefit_payment, state_benefit:, amount:, payment_date: pay_date
      end
    end
  end
end
