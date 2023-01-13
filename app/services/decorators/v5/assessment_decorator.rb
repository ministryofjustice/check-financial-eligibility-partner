module Decorators
  module V5
    class AssessmentDecorator
      def initialize(assessment, result)
        @assessment = assessment
        @result = result
      end

      def as_json
        payload
      end

    private

      attr_reader :assessment

      def payload
        {
          version: assessment.version,
          timestamp: Time.current,
          success: true,
          result_summary: ResultSummaryDecorator.new(assessment).as_json,
          assessment: assessment_details,
        }
      end

      def assessment_details
        details = {
          id: assessment.id,
          client_reference_id: assessment.client_reference_id,
          submission_date: assessment.submission_date,
          applicant: ApplicantDecorator.new(assessment.applicant).as_json,
          gross_income: GrossIncomeDecorator.new(assessment.gross_income_summary, assessment.employments).as_json,
          disposable_income: DisposableIncomeDecorator.new(assessment.disposable_income_summary).as_json,
          capital: CapitalDecorator.new(assessment.capital_summary).as_json,
          remarks: RemarksDecorator.new(assessment.remarks, assessment).as_json,
        }
        if assessment.partner
          details.merge(
            partner_gross_income: GrossIncomeDecorator.new(assessment.partner_gross_income_summary,
                                                           assessment.partner_employments).as_json,
            partner_disposable_income: DisposableIncomeDecorator.new(assessment.partner_disposable_income_summary).as_json,
            partner_capital: CapitalDecorator.new(assessment.partner_capital_summary).as_json,
          )
        else
          details
        end
      end
    end
  end
end
