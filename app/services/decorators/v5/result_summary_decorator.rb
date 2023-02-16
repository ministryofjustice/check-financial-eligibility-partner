module Decorators
  module V5
    class ResultSummaryDecorator
      attr_reader :assessment

      delegate :capital_summary,
               :disposable_income_summary,
               :gross_income_summary,
               to: :assessment

      def initialize(assessment, calculation_output)
        @assessment = assessment
        @calculation_output = calculation_output
      end

      def as_json
        details = {
          overall_result: {
            result: @assessment.assessment_result,
            capital_contribution: @calculation_output.capital_subtotals.capital_contribution.to_f,
            income_contribution: @calculation_output.disposable_income_subtotals.monthly_income_contribution.to_f,
            proceeding_types: ProceedingTypesResultDecorator.new(assessment.eligibilities, assessment.proceeding_types).as_json,
          },
          gross_income: GrossIncomeResultDecorator.new(gross_income_summary,
                                                       @calculation_output.gross_income_subtotals.applicant_gross_income_subtotals,
                                                       @calculation_output.gross_income_subtotals.combined_monthly_gross_income.to_f).as_json,
          disposable_income:,
          capital: CapitalResultDecorator.new(capital_summary,
                                              @calculation_output.capital_subtotals.applicant_capital_subtotals,
                                              @calculation_output.capital_subtotals.capital_contribution.to_f,
                                              @calculation_output.capital_subtotals.combined_assessed_capital.to_f).as_json,
        }
        if assessment.partner
          details.merge(partner_capital:, partner_gross_income:, partner_disposable_income:)
        else
          details
        end
      end

      def partner_gross_income
        GrossIncomeResultDecorator.new(assessment.partner_gross_income_summary,
                                       @calculation_output.gross_income_subtotals.partner_gross_income_subtotals).as_json
      end

      def disposable_income
        DisposableIncomeResultDecorator.new(disposable_income_summary,
                                            @calculation_output.gross_income_subtotals.applicant_gross_income_subtotals.employment_income_subtotals,
                                            @calculation_output.disposable_income_subtotals.applicant_disposable_income_subtotals,
                                            combined_outgoings: @calculation_output.disposable_income_subtotals.combined_monthly_outgoings,
                                            combined_disposable_income: @calculation_output.disposable_income_subtotals.combined_monthly_disposable_income,
                                            income_contribution: @calculation_output.disposable_income_subtotals.monthly_income_contribution).as_json
      end

      def partner_disposable_income
        DisposableIncomeResultDecorator.new(assessment.partner_disposable_income_summary,
                                            @calculation_output.gross_income_subtotals.partner_gross_income_subtotals.employment_income_subtotals,
                                            @calculation_output.disposable_income_subtotals.partner_disposable_income_subtotals,
                                            combined_outgoings: @calculation_output.disposable_income_subtotals.combined_monthly_outgoings,
                                            combined_disposable_income: @calculation_output.disposable_income_subtotals.combined_monthly_disposable_income,
                                            income_contribution: @calculation_output.disposable_income_subtotals.monthly_income_contribution).as_json
      end

      def partner_capital
        CapitalResultDecorator.new(assessment.partner_capital_summary,
                                   @calculation_output.capital_subtotals.partner_capital_subtotals,
                                   0, 0).as_json
      end
    end
  end
end
