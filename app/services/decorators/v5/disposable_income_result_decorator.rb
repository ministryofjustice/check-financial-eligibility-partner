module Decorators
  module V5
    class DisposableIncomeResultDecorator
      def initialize(summary, gross_income_summary, employment_income_subtotals, partner_present:, dependant_allowance:)
        @summary = summary
        @gross_income_summary = gross_income_summary
        @employment_income_subtotals = employment_income_subtotals
        @partner_present = partner_present
        @dependant_allowance = dependant_allowance
      end

      def as_json
        if @summary.is_a?(ApplicantDisposableIncomeSummary)
          basic_attributes.merge(proceeding_types:,
                                 combined_total_disposable_income:,
                                 combined_total_outgoings_and_allowances:,
                                 partner_allowance:)
        else
          basic_attributes
        end
      end

      def basic_attributes
        {
          dependant_allowance: @dependant_allowance.to_f,
          gross_housing_costs: @summary.gross_housing_costs.to_f,
          housing_benefit: @summary.housing_benefit.to_f,
          net_housing_costs: @summary.net_housing_costs.to_f,
          maintenance_allowance: @summary.maintenance_out_all_sources.to_f,
          total_outgoings_and_allowances: @summary.total_outgoings_and_allowances.to_f,
          total_disposable_income: @summary.total_disposable_income.to_f,
          employment_income:,
          income_contribution: @summary.income_contribution.to_f,
        }
      end

    private

      def employment_income
        {
          gross_income: @employment_income_subtotals.gross_employment_income.to_f,
          benefits_in_kind: @employment_income_subtotals.benefits_in_kind.to_f,
          tax: @employment_income_subtotals.tax.to_f,
          national_insurance: @employment_income_subtotals.national_insurance.to_f,
          fixed_employment_deduction: @employment_income_subtotals.fixed_employment_allowance.to_f,
          net_employment_income: @employment_income_subtotals.net_employment_income.to_f,
        }
      end

      def proceeding_types
        ProceedingTypesResultDecorator.new(@summary.eligibilities, @summary.assessment.proceeding_types).as_json
      end

      def partner_allowance
        return 0 unless @partner_present

        Threshold.value_for(:partner_allowance, at: @summary.assessment.submission_date)
      end

      def combined_total_disposable_income
        @summary.combined_total_disposable_income.to_f
      end

      def combined_total_outgoings_and_allowances
        @summary.combined_total_outgoings_and_allowances.to_f
      end
    end
  end
end
