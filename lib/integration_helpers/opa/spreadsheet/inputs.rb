module Opa
  module Spreadsheet
    class Inputs
      include Enumerable

      FREQUENCIES = { "4-Weekly" => 28 }.freeze

      def initialize(spreadsheet)
        @spreadsheet = spreadsheet
        # we have to load these up-front, as Roo has bugs which prevent multiple iterators being open on the
        # same spreadsheet at the same time - so opening sheet 2 trashed the iterator for sheet 0 :-(
        @employments = @spreadsheet.sheet("the employment").parse(
          test_case: "Test Cases",
          frequency: "the client non hm forces frequency of pay for the employment",
          slips: "the client non hm forces wage slip",
        )
        @wage_slips = @spreadsheet.sheet("the client non hm forces wa...").parse(
          test_case: "Test Cases",
          gross: "the client non hm forces wage slip gross pay",
          national_insurance: "the client non hm forces wage slip ni",
          tax: "the client non hm forces wage slip paye",
          included: "the client non hm forces wage slip entry is to be included in the assessment",
          slip: "the client non hm forces wage slip",
        )
      end

      def each
        @spreadsheet.sheet(0).each(test_case: "Test Case",
                                   employed: "the client is employed",
                                   employments: "the employments",
                                   mortgage_payment: "the value of the mortgage repayment per calendar month",
                                   housing_cost_type: "the housing costs deduction",
                                   receives_wtc: "the client receives working tax credit",
                                   wtc_amount: "the amount the client receives for working tax credit",
                                   wtc_frequency: "the frequency of payment for the client's working tax credit",
                                   passported: "the client is receiving a passported benefit",
                                   date_of_birth: "the client's date of birth") do |test_case|
          next unless test_case.fetch(:test_case).to_i.positive?

          submission_date = Date.new(2022, 6, 10)

          value = {
            test_case: test_case.fetch(:test_case),
            assessment: {
              submission_date: submission_date.to_s,
            },
            applicant: {
              date_of_birth: test_case.fetch(:date_of_birth),
              has_partner_opponent: false,
              receives_qualifying_benefit: test_case.fetch(:passported),
            },
            proceeding_types: [{ ccms_code: "SE003", client_involvement_type: "A" }],
          }

          if test_case.fetch(:housing_cost_type) == "Mortgage"
            value[:outgoings] = [
              mortgage_outgoings(submission_date:, mortgage_payment: test_case.fetch(:mortgage_payment)),
            ]
          end

          if test_case.fetch(:receives_wtc)
            value[:other_incomes] = [
              working_tax_credit(amount: test_case.fetch(:wtc_amount),
                                 submission_date:,
                                 frequency: test_case.fetch(:wtc_frequency)),
            ]
          end

          if test_case.fetch(:employments).present?
            value[:employment_income] = employment_incomes(submission_date, test_case.fetch(:test_case))
          end

          yield value
        end
      end

      def mortgage_outgoings(submission_date:, mortgage_payment:)
        {
          name: "rent_or_mortgage",
          payments: 1.upto(3).map do |index|
            {
              payment_date: (submission_date - index.months).to_s,
              housing_cost_type: "mortgage",
              client_id: index.to_s,
              amount: mortgage_payment,
            }
          end,
        }
      end

      def working_tax_credit(amount:, submission_date:, frequency:)
        offset = FREQUENCIES.fetch(frequency)
        {
          source: "maintenance_in",
          payments: 0.upto(2).map do |index|
                      {
                        date: (submission_date - 1.month - (index * offset).days).to_s,
                        client_id: index.to_s,
                        amount:,
                      }
                    end,
        }
      end

      def employment_incomes(submission_date, case_number)
        employments = @employments.select { |f| f.fetch(:test_case) == case_number }
        test_case_slips = @wage_slips.select { |f| f.fetch(:test_case) == case_number }

        employments.map do |employment|
          slip_names = employment.fetch(:slips).split(", ")
          slips2 = test_case_slips.select { |f| f.fetch(:slip).in?(slip_names) }

          first_slip = slips2.find { |f| f.fetch(:included) }

          emp_offset = FREQUENCIES.fetch(employment.fetch(:frequency))

          payments = 0.upto(2).map do |index|
            {
              date: (submission_date - 1.month - (index * emp_offset).days).to_s,
              client_id: index.to_s,
              benefits_in_kind: 0,
              gross: first_slip.fetch(:gross),
              tax: -first_slip.fetch(:tax),
              national_insurance: -first_slip.fetch(:national_insurance),
            }
          end
          { name: "A", client_id: "B", payments: }
        end
      end
    end
  end
end
