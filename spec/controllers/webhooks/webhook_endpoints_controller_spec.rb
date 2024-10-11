require 'rails_helper'

RSpec.describe Webhooks::WebhookEndpointsController, type: :controller do
  let(:company) { Company.create!(name: 'Example Company', erp_key: 'ERP_KEY', erp_secret: 'ERP_SECRET') }
  let(:client) { Client.create!(client_code: 'C123', erp_key: 'ERP_KEY', erp_secret: 'ERP_SECRET', company: company) }

  let(:valid_attributes) do
    {
      url: 'https://example.com/webhook',
      event_type: 'create_payable',
      client_id: client.id,
      company_id: company.id,
      subscriptions: ['all'],
      enabled: true,
      erp: 'omnie'
    }
  end

  let(:invalid_attributes) do
    {
      url: nil,
      event_type: nil,
      client_id: nil,
      company_id: nil,
      subscriptions: nil,
      enabled: nil,
      erp: nil
    }
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new WebhookEndpoint' do
        expect {
          post :create, params: { webhook_endpoint: valid_attributes }
        }.to change(WebhookEndpoint, :count).by(1)
      end

      it 'renders a JSON response with the message' do
        post :create, params: { webhook_endpoint: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('Webhook inscrito com sucesso')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new WebhookEndpoint' do
        expect {
          post :create, params: { webhook_endpoint: invalid_attributes }
        }.to change(WebhookEndpoint, :count).by(0)
      end

      it 'renders a JSON response with errors' do
        post :create, params: { webhook_endpoint: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to include(
          "Url can't be blank",
          "Event type can't be blank",
          "Client can't be blank",
          "Company can't be blank",
          "Subscriptions can't be blank",
          "Erp can't be blank"
        )
      end
    end
  end
end
