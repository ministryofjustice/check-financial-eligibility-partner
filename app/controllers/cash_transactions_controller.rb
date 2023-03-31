class CashTransactionsController < ApplicationController
  def create
    json_validator = JsonSwaggerValidator.new("cash_transactions", cash_transaction_params)
    if json_validator.valid?
      if creation_service.success?
        render_success
      else
        render_unprocessable(creation_service.errors)
      end
    else
      render_unprocessable(json_validator.errors)
    end
  end

private

  def creation_service
    @creation_service ||= Creators::CashTransactionsCreator.call(
      assessment_id: params[:assessment_id],
      cash_transaction_params:,
    )
  end

  def cash_transaction_params
    JSON.parse(request.raw_post, symbolize_names: true)
  end
end
