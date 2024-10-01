require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do
  let!(:payable) { create(:payable) }
  let!(:reimbursement) { create(:reimbursement, payable: payable, status: 'pending') }

  before do
    allow(HTTParty).to receive(:post).and_return(double(code: 200, body: "Webhook notification sent"))
  end

  describe 'POST #notify_payment' do
    it 'updates reimbursement status and sends webhook notification' do
      post :notify_payment, params: { payment: { id: payable.id } }

      expect(response).to have_http_status(:ok)
      expect(reimbursement.reload.status).to eq('paid')
      expect(reimbursement.payment_date).not_to be_nil
    end

    it 'returns error if reimbursement is already paid' do
      reimbursement.update!(status: 'paid')
      post :notify_payment, params: { payment: { id: payable.id } }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['error']).to eq('Reimbursement not found or already paid.')
    end

    it 'returns error if payable not found' do
      post :notify_payment, params: { payment: { id: 'invalid_id' } }

      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to eq('Payable account not found.')
    end
  end
end
