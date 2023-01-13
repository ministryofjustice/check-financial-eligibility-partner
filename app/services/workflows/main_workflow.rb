module Workflows
  class MainWorkflow
    class << self
      def call(assessment)
        version_5_verification(assessment)
        result = if applicant_passported? assessment
                   PassportedWorkflow.call(assessment)
                 else
                   NonPassportedWorkflow.call(assessment)
                 end
        RemarkGenerators::Orchestrator.call(assessment)
        Assessors::MainAssessor.call(assessment)
        result
      end

    private

      def applicant_passported?(assessment)
        assessment.applicant.receives_qualifying_benefit?
      end

      def version_5_verification(assessment)
        Utilities::ProceedingTypeThresholdPopulator.call(assessment)
        Creators::EligibilitiesCreator.call(assessment)
      end
    end
  end
end
