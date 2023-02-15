module Workflows
  class MainWorkflow < BaseWorkflowService
    def call
      version_5_verification(assessment)
      calculation_output = if applicant_receives_relevant_asylum_support?(assessment)
                             AsylumSupportedWorkflow.call(assessment)
                           elsif applicant_passported?
                             PassportedWorkflow.call(assessment)
                           else
                             NonPassportedWorkflow.call(assessment)
                           end
      RemarkGenerators::Orchestrator.call(assessment, calculation_output.capital_subtotals.combined_assessed_capital)
      Assessors::MainAssessor.call(assessment)
      calculation_output
    end

  private

    def applicant_passported?
      applicant.receives_qualifying_benefit?
    end

    def version_5_verification(assessment)
      Utilities::ProceedingTypeThresholdPopulator.call(assessment)
      Creators::EligibilitiesCreator.call(assessment)
    end

    def applicant_receives_relevant_asylum_support?(assessment)
      assessment.proceeding_types.all? { _1.ccms_code.to_sym.in?(CFEConstants::IMMIGRATION_AND_ASYLUM_PROCEEDING_TYPE_CCMS_CODES) } &&
        assessment.applicant.receives_asylum_support
    end
  end
end
