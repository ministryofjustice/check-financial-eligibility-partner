require 'rails_helper'

RSpec.describe StateBenefitPayment do
  describe '#client id' do
    context 'when null' do
      it 'generates it from class, date and amount' do
        outgoing = create :state_benefit_payment, amount: 127.33, payment_date: Date.new(2019, 3, 2), client_id: nil
        expect(outgoing.client_id).to eq 'StateBenefitPayment:2019-03-02:127.33'
      end
    end

    context 'when populated' do
      it 'returns the value' do
        outgoing = create :state_benefit_payment, amount: 127.33, payment_date: Date.new(2019, 3, 2), client_id: '55b31f30-a198-45bd-9a43-a4e5b66fa42e'
        expect(outgoing.client_id).to eq '55b31f30-a198-45bd-9a43-a4e5b66fa42e'
      end
    end
  end
end
