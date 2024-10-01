require 'rails_helper'

RSpec.describe WebhooksController, type: :controller do
  include ActiveJob::TestHelper  # Inclui o módulo para testes de jobs

  let(:valid_refund_params) do
    {
      client_id: "1",
      client_code: "C001",
      category_code: "CATEGORIA001",
      account_code: "CONTA001",
      due_date: "2024-10-30",
      cost: 100.5
    }
  end

  let(:valid_subscription_params) do
    {
      webhook: {
        company_id: "1",
        erp_key: "your_erp_key",
        erp_secret: "your_erp_secret"
      }
    }
  end

  describe 'POST #subscribe' do
    context 'quando os parâmetros são válidos' do
      it 'retorna 200 OK e enfileira um job' do
        expect {
          post :subscribe, params: valid_subscription_params
        }.to have_enqueued_job(CreateAccountJob).with("1", "CONTA001", "CATEGORIA001", "C001", "2024-10-30", 100.5)

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include("message" => "Job enfileirado com sucesso")
      end
    end

    context 'quando os parâmetros são inválidos' do
      it 'retorna 422 Unprocessable Entity' do
        post :subscribe, params: { webhook: { company_id: nil } }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("error" => "Credenciais inválidas. Certifique-se de que company_id, erp_key e erp_secret estão presentes.")
      end
    end
  end

  describe 'POST #create_refund' do
  context 'quando os parâmetros são válidos' do
    it 'retorna 200 OK e enfileira um job' do
      expect {
        post :create_refund, params: valid_refund_params
      }.to have_enqueued_job(CreateAccountJob).with("1", "CONTA001", "CATEGORIA001", "C001", "2024-10-30", 100.5)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include("message" => "Job de criação de conta a pagar enfileirado com sucesso")
    end
  end

    context 'quando os parâmetros são inválidos' do
      it 'retorna 422 Unprocessable Entity' do
        post :create_refund, params: { client_id: nil }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("error" => "Parâmetros inválidos. Certifique-se de fornecer todos os campos obrigatórios.")
      end
    end
  end

  describe 'POST #notify_payment' do
    context 'quando company_id está presente' do
      it 'retorna 200 OK' do
        post :notify_payment, params: { company_id: "1", status: "paid" }
        
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to include("message" => "Notificação de pagamento processada com sucesso.")
      end
    end

    context 'quando company_id está ausente' do
      it 'retorna 422 Unprocessable Entity' do
        post :notify_payment, params: { status: "paid" }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("error" => 'company_id é obrigatório.')
      end
    end
  end

  describe 'POST #reimbursements' do
  context 'quando os parâmetros são válidos' do
    it 'retorna 202 Accepted e enfileira um job' do
      expect {
        post :reimbursements, params: valid_refund_params
      }.to have_enqueued_job(CreateAccountJob).with("1", "CONTA001", "CATEGORIA001", "C001", "2024-10-30", 100.5)

      expect(response).to have_http_status(:accepted)
      expect(JSON.parse(response.body)).to include("message" => "Reembolso recebido e está sendo processado.")
    end
  end

    context 'quando os parâmetros são inválidos' do
      it 'retorna 422 Unprocessable Entity' do
        post :reimbursements, params: { client_id: nil }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include("error" => "Parâmetros inválidos. Certifique-se de fornecer todos os campos obrigatórios.")
      end
    end
  end
end
