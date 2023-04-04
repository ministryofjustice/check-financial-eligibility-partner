class CashTransactionsController < CreationController
  def create
    create_object("cash_transactions", cash_transaction_params, lambda {
      Creators::CashTransactionsCreator.call(
        assessment_id: params[:assessment_id],
        cash_transaction_params:,
      )
    })
  end

private

  def cash_transaction_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
