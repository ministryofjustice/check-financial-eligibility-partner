module Creators
  class ApplicantCreator
    class CreationError < Creators::BaseCreator::CreationError
    end

    Result = Struct.new :errors, :applicant, keyword_init: true do
      def success?
        errors.empty?
      end
    end

    class << self
      def call(assessment:, applicant_params:)
        applicant = create_applicant(assessment:, applicant_params:)
        Result.new(errors: [], applicant:).freeze
      rescue CreationError => e
        Result.new(errors: e.errors).freeze
      end

    private

      def create_applicant(assessment:, applicant_params:)
        (raise CreationError, ["There is already an applicant for this assesssment"]) if assessment.applicant.present?
        assessment.create_applicant!(applicant_attributes(applicant_params))
      rescue ActiveRecord::RecordInvalid => e
        raise CreationError, e.record.errors.full_messages
      end

      def applicant_attributes(applicant_params)
        applicant_params[:applicant]
      end
    end
  end
end
