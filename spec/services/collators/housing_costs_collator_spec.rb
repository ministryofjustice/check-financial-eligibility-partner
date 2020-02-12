require 'rails_helper'

module Collators
  RSpec.describe HousingCostsCollator do
    describe '.call' do
      let(:assessment) { create :assessment, :with_disposable_income_summary, :with_gross_income_summary, with_child_dependants: children }
      let(:disposable_income_summary) { assessment.disposable_income_summary }
      let(:gross_income_summary) { assessment.gross_income_summary }
      let(:children) { 0 }

      subject { described_class.call(assessment) }

      context 'no housing cost outgoings' do
        it 'should record zero' do
          subject
          expect(disposable_income_summary.gross_housing_costs).to eq 0.0
          expect(disposable_income_summary.housing_benefit).to eq 0.0
          expect(disposable_income_summary.net_housing_costs).to eq 0.0
        end
      end

      context 'when applicant has no dependants' do
        context 'housing cost outgoings' do
          let(:housing_cost_amount) { 1200.00 }
          before do
            [Date.today, 1.month.ago, 2.months.ago].each do |pay_date|
              create :housing_cost_outgoing,
                     disposable_income_summary: disposable_income_summary,
                     amount: housing_cost_amount,
                     payment_date: pay_date,
                     housing_cost_type: housing_cost_type
            end
          end

          context 'no housing benefit' do
            context 'board and lodging' do
              let(:housing_cost_type) { 'board_and_lodging' }
              let(:housing_cost_amount) { 1500.00 }
              it 'should record half the monthly housing cost' do
                subject
                expect(disposable_income_summary.gross_housing_costs).to eq 750.00
                expect(disposable_income_summary.housing_benefit).to eq 0.0
                expect(disposable_income_summary.net_housing_costs).to eq 545.00
              end
            end

            context 'rent' do
              let(:housing_cost_type) { 'rent' }
              it 'should record the full monthly housing costs' do
                subject
                expect(disposable_income_summary.gross_housing_costs).to eq 1200.00
                expect(disposable_income_summary.housing_benefit).to eq 0.0
                expect(disposable_income_summary.net_housing_costs).to eq 545.00
              end
            end

            context 'mortgage' do
              let(:housing_cost_type) { 'mortgage' }
              it 'should record the full monthly housing costs' do
                subject
                expect(disposable_income_summary.gross_housing_costs).to eq 1200.00
                expect(disposable_income_summary.housing_benefit).to eq 0.0
                expect(disposable_income_summary.net_housing_costs).to eq 545.00
              end
            end
          end

          context 'housing benefit' do
            let(:housing_benefit_amount) { 500.00 }
            before do
              housing_benefit_type = create :state_benefit_type, label: 'housing_benefit'
              state_benefit = create :state_benefit, gross_income_summary: gross_income_summary, state_benefit_type: housing_benefit_type
              [Date.today, 1.month.ago, 2.months.ago].each do |pay_date|
                create :state_benefit_payment, state_benefit: state_benefit, amount: housing_benefit_amount, payment_date: pay_date
              end
            end

            context 'board and lodging' do
              let(:housing_cost_type) { 'board_and_lodging' }
              let(:housing_cost_amount) { 1500.00 }
              let(:housing_benefit_amount) { 100.00 }

              it 'should record half the housing cost less the housing benefit' do
                subject
                expect(disposable_income_summary.gross_housing_costs).to eq 750.00
                expect(disposable_income_summary.housing_benefit).to eq 100.00
                expect(disposable_income_summary.net_housing_costs).to eq 545.00 # Cap applied
              end
            end

            context 'rent' do
              let(:housing_cost_type) { 'rent' }

              it 'should record the full monthly housing costs' do
                subject
                expect(disposable_income_summary.gross_housing_costs).to eq 1200.00
                expect(disposable_income_summary.housing_benefit).to eq 500.0
                expect(disposable_income_summary.net_housing_costs).to eq 545.00 # Cap applied
              end
            end

            context 'mortgage' do
              let(:housing_cost_type) { 'mortgage' }

              it 'should record the full housing costs less the housing benefit' do
                subject
                expect(disposable_income_summary.gross_housing_costs).to eq 1200.00
                expect(disposable_income_summary.housing_benefit).to eq 500.00
                expect(disposable_income_summary.net_housing_costs).to eq 545.00 # Cap applied
              end
            end
          end
        end
      end
    end
  end
end
