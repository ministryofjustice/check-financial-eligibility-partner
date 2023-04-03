class ProceedingTypesController < CreationController
  def create
    create_object("proceeding_types", proceeding_types_params, lambda {
      Creators::ProceedingTypesCreator.call(
        assessment_id: params[:assessment_id],
        proceeding_types_params:,
      )
    })
  end

private

  def proceeding_types_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
