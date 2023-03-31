class ApplicantsController < ApplicationController
  before_action :load_assessment

  def create
    json_validator = JsonSwaggerValidator.new("applicant", applicant_params)
    if json_validator.valid?
      if creation_service.success?
        render_success
      else
        render_unprocessable(creation_service.errors)
      end
    else
      render_unprocessable(json_validator.errors)
    end
  end

private

  def creation_service
    @creation_service ||= Creators::ApplicantCreator.call(
      assessment: @assessment,
      applicant_params:,
    )
  end

  def applicant_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
