class StateBenefitsController < CreationController
  def create
    create_object "state_benefits", state_benefits_params, lambda {
      Creators::StateBenefitsCreator.call(
        assessment_id: params[:assessment_id],
        state_benefits_params:,
      )
    }
  end

private

  def state_benefits_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
