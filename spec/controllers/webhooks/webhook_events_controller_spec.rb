require 'rails_helper'

RSpec.describe Webhooks::WebhookEventsController, type: :controller do
  # Criação de um objeto company com os atributos corretos, incluindo o name
  let(:company) do
    Company.create!(
      name: 'Company Name',         
      erp_key: 'valid_erp_key',     
      erp_secret: 'valid_erp_secret' 
    )
  end

  # Criação de um objeto client que pertence a company
  let(:client) do
    Client.create!(
      name: 'Client Name',
      company: company,
      client_code: '123456',         
      erp_key: 'client_erp_key',     
      erp_secret: 'client_erp_secret' 
    )
  end

  # Criação de um objeto erp usando os atributos corretos
  let(:erp) { Erp.create!(key: 'ERP Key', secret: 'ERP Secret') }

  # Criação do webhook_endpoint associado ao client e company
  let(:webhook_endpoint) do
    WebhookEndpoint.create!(
      url: 'https://example.com/webhook',
      client: client,
      company_id: company.id,
      subscriptions: ['order.created'],
      event_type: 'Event Type Name', 
      erp: erp.key 
    )
  end

  # Definindo atributos válidos para o webhook_event
  let(:valid_attributes) do
    {
      event: 'order.created',
      payload: { order_id: 123, amount: 100.0 }.to_json,
      webhook_endpoint_id: webhook_endpoint.id
    }
  end

  # Definindo atributos inválidos para o webhook_event
  let(:invalid_attributes) do
    {
      event: nil,
      payload: nil,
      webhook_endpoint_id: nil
    }
  end

  # Contexto para testar o método POST #create
  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new WebhookEvent' do
        expect {
          post :create, params: { webhook_event: valid_attributes }
        }.to change(WebhookEvent, :count).by(1)
      end

      it 'returns a success response' do
        post :create, params: { webhook_event: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)['message']).to eq('Evento de webhook registrado com sucesso')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new WebhookEvent' do
        expect {
          post :create, params: { webhook_event: invalid_attributes }
        }.not_to change(WebhookEvent, :count)
      end

      it 'returns an unprocessable entity response' do
        post :create, params: { webhook_event: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['errors']).to be_present
      end
    end
  end
end






