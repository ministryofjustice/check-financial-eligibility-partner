class ExplicitRemarksController < CreationController
  def create
    create_object("explicit_remarks", explicit_remarks_params, lambda {
      Creators::ExplicitRemarksCreator.call(
        assessment_id: params[:assessment_id],
        explicit_remarks_params:,
      )
    })
  end

private

  def explicit_remarks_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
