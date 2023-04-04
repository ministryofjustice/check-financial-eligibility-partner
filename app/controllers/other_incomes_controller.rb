class OtherIncomesController < CreationController
  def create
    create_object("other_incomes", other_incomes_params, lambda {
      Creators::OtherIncomesCreator.call(
        assessment_id: params[:assessment_id],
        other_incomes_params:,
      )
    })
  end

private

  def other_incomes_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
