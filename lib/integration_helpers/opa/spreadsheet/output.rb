module Opa
  module Spreadsheet
    class Output
      def initialize(spreadsheet)
        @spreadsheet = spreadsheet
      end

      def expected(test_case)
        row = @spreadsheet.sheet("Test Cases").parse(
          test_case: "Test Case",
          eligibility: "the client overall eligibility",
          gross_income: "total client gross income",
          gross_housing_costs: "the gross value of housing costs",
          net_housing_costs: "the total net value of housing costs",
          gross_wage: "value of total client gross wage",
          benefits: "value of client working tax credit",
          deductions: "the total value of all income deductions",
          disposable_income: "the value of disposable income",
          capital_contribution: "the capital contribution",
          income_contribution: "the client provisional income contribution",
          employment_deduction: "the client employment expenses output",
        ).detect { |x| x.fetch(:test_case) == test_case }

        eligibility = if row.fetch(:eligibility) == "In Scope"
                        if row.fetch(:capital_contribution).zero? && row.fetch(:income_contribution).zero?
                          "eligible"
                        else
                          "contribution_required"
                        end
                      else
                        "ineligible"
                      end
        {
          overall_result: {
            result: eligibility,
            capital_contribution: row.fetch(:capital_contribution).to_f,
            income_contribution: row.fetch(:income_contribution).to_f,
          },
          gross_income: {
            total_gross_income: row.fetch(:gross_income),
            combined_total_gross_income: row.fetch(:gross_income),
          },
          disposable_income: {
            dependant_allowance: 0.0,
            gross_housing_costs: row.fetch(:gross_housing_costs),
            housing_benefit: 0.0,
            net_housing_costs: row.fetch(:net_housing_costs),
            maintenance_allowance: 0.0,
            total_outgoings_and_allowances: row.fetch(:deductions),
            total_disposable_income: row.fetch(:disposable_income),
            # this breakdown is more detailed than supplied by the OPA spreadsheet,
            # so just ignore for now. It's mostly a repeat of the employment data
            # employment_income: {
            #   gross_income: row.fetch(:gross_wage),
            #   benefits_in_kind: 0.0,
            #   tax: -216.67,
            #   national_insurance: -86.67,
            #   fixed_employment_deduction: -row.fetch(:employment_deduction),
            #   net_employment_income: 734.99,
            # },
            income_contribution: 0.0,
            combined_total_disposable_income: row.fetch(:disposable_income),
            combined_total_outgoings_and_allowances: row.fetch(:deductions),
            partner_allowance: 0,
          },
          capital: {
            pensioner_disregard_applied: 0.0,
            total_liquid: 0.0,
            total_non_liquid: 0.0,
            total_vehicle: 0.0,
            total_property: 0.0,
            total_mortgage_allowance: 999_999_999_999.0,
            total_capital: 0.0,
            subject_matter_of_dispute_disregard: 0.0,
            capital_contribution: 0.0,
            assessed_capital: 0.0,
            total_capital_with_smod: 0.0,
            disputed_non_property_disregard: 0.0,
            pensioner_capital_disregard: 0.0,
            combined_assessed_capital: 0.0,
          },
        }
      end
    end
  end
end
