class ExplicitRemarksController < ApplicationController
  def create
    json_validator = JsonSwaggerValidator.new("explicit_remarks", explicit_remarks_params)
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
    @creation_service ||= Creators::ExplicitRemarksCreator.call(
      assessment_id: params[:assessment_id],
      explicit_remarks_params:,
    )
  end

  def explicit_remarks_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
