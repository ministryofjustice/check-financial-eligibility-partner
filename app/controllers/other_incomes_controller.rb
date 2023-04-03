class OtherIncomesController < ApplicationController
  def create
    json_validator = JsonSwaggerValidator.new("other_incomes", other_incomes_params)
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
    @creation_service ||= Creators::OtherIncomesCreator.call(
      assessment_id: params[:assessment_id],
      other_incomes_params:,
    )
  end

  def other_incomes_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
