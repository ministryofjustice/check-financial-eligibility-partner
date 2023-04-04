class PropertiesController < CreationController
  def create
    create_object("properties", properties_params, lambda {
      Creators::PropertiesCreator.call(
        assessment_id: params[:assessment_id],
        properties_params:,
      )
    })
  end

private

  def properties_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
