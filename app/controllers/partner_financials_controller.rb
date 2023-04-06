class PartnerFinancialsController < CreationController
  def create
    create_object "partner_financials", partner_financials_params, lambda {
      Creators::PartnerFinancialsCreator.call(
        assessment_id: params[:assessment_id],
        partner_financials_params:,
      )
    }
  end

private

  def partner_financials_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
