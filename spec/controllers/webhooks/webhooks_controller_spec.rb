require 'rails_helper'

RSpec.describe Webhooks::WebhooksController, type: :controller do
  describe 'POST #receive_webhook' do
    context 'when event_type is create_payable' do
      let(:valid_create_payable_params) do
        {
          webhook_event: {
            event_type: 'create_payable',
            data: {
              client_id: 1,
              cost: 1000,
              due_date: '2024-12-31',
              company_id: 2,
              category_code: 'CAT001',
              account_code: 'ACC001',
              codigo_lancamento_integracao: 'CL123',
              client_code: 'CLIENT001',
              categoria: 'Serviços'
            }
          }
        }
      end

      it 'queues a CreatePayableAccountJob' do
        expect {
          post :receive_webhook, params: valid_create_payable_params
        }.to have_enqueued_job(CreatePayableAccountJob)
      end

      it 'returns a 202 status with a success message' do
        post :receive_webhook, params: valid_create_payable_params
        expect(response).to have_http_status(:accepted)
        expect(JSON.parse(response.body)['message']).to eq('Conta a pagar em processo de criação')
      end
    end

    context 'when event_type is mark_as_paid' do
      let(:valid_mark_as_paid_params) do
        {
          webhook_event: {
            event_type: 'mark_as_paid',
            data: {
              payable_id: 1
            }
          }
        }
      end

      it 'queues a MarkAsPaidJob' do
        expect {
          post :receive_webhook, params: valid_mark_as_paid_params
        }.to have_enqueued_job(MarkAsPaidJob)
      end

      it 'returns a 202 status with a success message' do
        post :receive_webhook, params: valid_mark_as_paid_params
        expect(response).to have_http_status(:accepted)
        expect(JSON.parse(response.body)['message']).to eq('Notificação para marcar como pago em processo')
      end
    end

    context 'when event_type is mark_as_paid but payable_id is missing' do
      let(:invalid_mark_as_paid_params) do
        {
          webhook_event: {
            event_type: 'mark_as_paid',
            data: {
              payable_id: nil
            }
          }
        }
      end

      it 'returns a 422 status with an error message' do
        post :receive_webhook, params: invalid_mark_as_paid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('ID da conta a pagar não fornecido')
      end
    end

    context 'when event_type is unsupported' do
      let(:unsupported_event_params) do
        {
          webhook_event: {
            event_type: 'unsupported_event',
            data: {}
          }
        }
      end

      it 'returns a 422 status with an error message' do
        post :receive_webhook, params: unsupported_event_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['error']).to eq('Evento não suportado')
      end
    end
  end
end
