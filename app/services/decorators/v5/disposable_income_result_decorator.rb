module Decorators
  module V5
    class DisposableIncomeResultDecorator
      def initialize(summary, employment_income_subtotals, person_disposable_income_subtotals, combined_outgoings:, combined_disposable_income:, income_contribution:)
        @summary = summary
        @employment_income_subtotals = employment_income_subtotals
        @person_disposable_income_subtotals = person_disposable_income_subtotals
        @total_outgoings = combined_outgoings
        @combined_disposable_income = combined_disposable_income
        @income_contribution = income_contribution
      end

      def as_json
        if @summary.is_a?(ApplicantDisposableIncomeSummary)
          basic_attributes.merge(proceeding_types:,
                                 combined_total_disposable_income:,
                                 combined_total_outgoings_and_allowances:,
                                 partner_allowance: @person_disposable_income_subtotals.partner_allowance)
        else
          basic_attributes
        end
      end

      def basic_attributes
        {
          dependant_allowance: @person_disposable_income_subtotals.dependant_allowance.to_f,
          gross_housing_costs: @person_disposable_income_subtotals.housing_costs_subtotals.gross_housing_costs.to_f,
          housing_benefit: @person_disposable_income_subtotals.housing_costs_subtotals.housing_benefit.to_f,
          net_housing_costs: @person_disposable_income_subtotals.housing_costs_subtotals.net_housing_costs.to_f,
          maintenance_allowance: @person_disposable_income_subtotals.categorised_outgoings(:all_sources, :maintenance_out).to_f,
          total_outgoings_and_allowances: @person_disposable_income_subtotals.total_monthly_outgoings.to_f,
          total_disposable_income: @person_disposable_income_subtotals.total_monthly_disposable_income.to_f,
          employment_income:,
          income_contribution: @income_contribution.to_f,
        }
      end

    private

      def net_employment_income
        (@employment_income_subtotals.gross_employment_income +
          @employment_income_subtotals.employment_income_deductions +
          @employment_income_subtotals.fixed_employment_allowance).to_f
      end

      def employment_income
        {
          gross_income: @employment_income_subtotals.gross_employment_income.to_f,
          benefits_in_kind: @employment_income_subtotals.benefits_in_kind.to_f,
          tax: @employment_income_subtotals.tax.to_f,
          national_insurance: @employment_income_subtotals.national_insurance.to_f,
          fixed_employment_deduction: @employment_income_subtotals.fixed_employment_allowance.to_f,
          net_employment_income: net_employment_income.to_f,
        }
      end

      def proceeding_types
        ProceedingTypesResultDecorator.new(@summary.eligibilities, @summary.assessment.proceeding_types).as_json
      end

      def combined_total_disposable_income
        @combined_disposable_income.to_f
      end

      def combined_total_outgoings_and_allowances
        @total_outgoings.to_f
      end
    end
  end
end
