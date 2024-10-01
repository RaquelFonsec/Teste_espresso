# spec/controllers/integrations_controller_spec.rb
require 'rails_helper'
require 'httparty'
RSpec.describe IntegrationsController, type: :controller do
  describe 'POST #validate_credentials' do
    let(:valid_params) do
      {
        company_id: "123",
        erp: "omie",
        erp_key: "valid_key",
        erp_secret: "valid_secret"
      }
    end

    let(:invalid_params) do
      {
        company_id: "123",
        erp: "omie",
        erp_key: "invalid_key",
        erp_secret: "invalid_secret"
      }
    end

    context 'when valid credentials are provided' do
      it 'validates the credentials successfully and responds with ok' do
        # Espia a chamada para validar credenciais
        allow(HTTParty).to receive(:post).and_return(double(success?: true, body: '{}'))

        # Espia a chamada para o webhook
        expect(HTTParty).to receive(:post).with(
          "https://26b6-2a02-a474-b1c4-1-dea8-f6b0-eba8-27bd.ngrok-free.app/webhooks/subscribe",
          hash_including(body: include("valid"), headers: { 'Content-Type' => 'application/json' })
        )

        post :validate_credentials, params: valid_params

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include('status' => 'ok')
      end
    end

    context 'when invalid credentials are provided' do
        it "returns an error response with invalid credentials message" do
            allow(HTTParty).to receive(:post).and_return(double(success?: false, body: '{"error": "Invalid credentials"}'))
          
            post :validate_credentials, params: { company_id: 1, erp: 'omie', erp_key: 'invalid_key', erp_secret: 'invalid_secret' }
          
            expect(response).to have_http_status(:unprocessable_entity)
            expect(JSON.parse(response.body)).to include('status' => 'error', 'message' => 'Credenciais inválidas.')  # Mensagem corrigida aqui
          end
        end 

    context 'when an exception occurs during validation' do
      it 'returns an error response and logs the error' do
        allow(HTTParty).to receive(:post).and_raise(StandardError.new("Some error"))

        expect(Rails.logger).to receive(:error).with("Erro ao validar credenciais: Some error")

        post :validate_credentials, params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include('status' => 'error', 'message' => 'Some error')
      end
    end
  end
end
