require "rails_helper"

module Creators
  RSpec.describe IrregularIncomeCreator do
    let(:gross_income_summary) { create :gross_income_summary }
    let(:assessment) { gross_income_summary.assessment }
    let(:frequency) { "annual" }
    let(:student_loan) { "student_loan" }
    let(:irregular_income_params) { irregular_income_params }

    subject(:creator) { described_class.call(irregular_income_params:, gross_income_summary:) }

    describe ".call" do
      context "payload" do
        it "creates an irregular income payment" do
          expect { creator }.to change(IrregularIncomePayment, :count).by(1)
        end

        it "creates a student loan payment" do
          creator
          payment = IrregularIncomePayment.find_by(gross_income_summary_id: gross_income_summary.id)
          expect(payment.frequency).to eq frequency
          expect(payment.income_type).to eq student_loan
          expect(payment.amount).to eq 123_456.78
        end
      end

      context "empty payload" do
        let(:irregular_income_params) { { payments: [] } }

        it "does not create any records" do
          expect { creator }.not_to change(IrregularIncomePayment, :count)
        end
      end
    end

    def irregular_income_params
      {
        payments: [
          {
            income_type: "student_loan",
            frequency:,
            amount: 123_456.78,
          },
        ],
      }
    end
  end
end
