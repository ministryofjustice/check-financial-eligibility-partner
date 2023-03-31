class DependantsController < ApplicationController
  def create
    json_validator = JsonSwaggerValidator.new("dependants", dependants_params)
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
    @creation_service ||= Creators::DependantsCreator.call(
      assessment_id: params[:assessment_id],
      dependants_params:,
    )
  end

  def dependants_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
