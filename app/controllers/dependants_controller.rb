class DependantsController < CreationController
  def create
    create_object("dependants", dependants_params, lambda {
      Creators::DependantsCreator.call(
        assessment_id: params[:assessment_id],
        dependants_params:,
      )
    })
  end

private

  def dependants_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
