class RegularTransactionsController < CreationController
  def create
    create_object "regular_transactions", regular_transaction_params, lambda {
      Creators::RegularTransactionsCreator.call(
        assessment_id: params[:assessment_id],
        regular_transaction_params:,
      )
    }
  end

private

  def regular_transaction_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
