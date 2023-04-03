module Creators
  class ProceedingTypesCreator < BaseCreator
    attr_accessor :proceeding_types

    def initialize(assessment_id:, proceeding_types_params:)
      super()
      @assessment_id = assessment_id
      @proceeding_types_params = proceeding_types_params
    end

    def call
      create_records
      self
    end

  private

    attr_reader :assessment_id

    def create_records
      create_proceeding_types
    rescue CreationError => e
      errors << e.errors
    end

    def create_proceeding_types
      self.proceeding_types = assessment.proceeding_types.create!(proceeding_types_attributes)
    rescue StandardError => e
      raise CreationError, "#{e.class} - #{e.message}"
    end

    def proceeding_types_attributes
      @proceeding_types_attributes ||= @proceeding_types_params[:proceeding_types]
    end
  end
end
