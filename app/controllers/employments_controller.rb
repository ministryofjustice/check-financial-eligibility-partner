class EmploymentsController < CreationController
  before_action :load_assessment

  def create
    create_object("employments", employments_params, lambda {
      Creators::EmploymentsCreator.call(
        employments_params:,
        employment_collection: @assessment.employments,
      )
    })
  end

private

  def employments_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
