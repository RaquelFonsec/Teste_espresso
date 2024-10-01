require 'rails_helper'
require 'webmock/rspec'

RSpec.describe ValidateCredentialsJob, type: :job do
  let(:company_id) { 123 }
  let(:erp) { "Omie" }
  let(:erp_key) { "Sua ERP Key" }
  let(:erp_secret) { "Seu ERP Secret" }
  let(:webhook_url) { 'https://26b6-2a02-a474-b1c4-1-dea8-f6b0-eba8-27bd.ngrok-free.app/webhooks/subscribe' }

  before do
    allow_any_instance_of(ValidateCredentialsJob).to receive(:find_webhook_url).with(company_id).and_return(webhook_url)
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:error)
  end

  context 'when credentials are valid' do
    before do
      stub_request(:post, "https://app.omie.com.br/api/v1/financas/contapagar/")
        .to_return(status: 200, body: "", headers: {})
      stub_request(:post, webhook_url)
        .to_return(status: 200, body: "", headers: {})
    end

    it 'logs success messages' do
      expect(Rails.logger).to receive(:info).with("Validando credenciais para a empresa #{company_id}")
      expect(Rails.logger).to receive(:info).with("Credenciais válidas para a empresa #{company_id}")
      expect(Rails.logger).to receive(:info).with("Notificação enviada com sucesso para #{webhook_url}") # Removido ponto final

      ValidateCredentialsJob.perform_now(company_id, erp, erp_key, erp_secret)
    end
  end

  context 'when credentials are invalid' do
    before do
      stub_request(:post, "https://app.omie.com.br/api/v1/financas/contapagar/")
        .to_return(status: 401, body: "", headers: {})
      stub_request(:post, webhook_url)
        .to_return(status: 429, body: "", headers: {})
    end

    it 'logs error messages' do
      expect(Rails.logger).to receive(:info).with("Validando credenciais para a empresa #{company_id}")
      expect(Rails.logger).to receive(:error).with("Credenciais inválidas para a empresa #{company_id}")
      expect(Rails.logger).to receive(:error).with(/Falha ao enviar notificação para/)

      ValidateCredentialsJob.perform_now(company_id, erp, erp_key, erp_secret)
    end
  end

  context 'when an error occurs during validation' do
    before do
      allow_any_instance_of(ValidateCredentialsJob).to receive(:valid_credentials?).and_raise(StandardError.new("Erro de rede"))
    end
  
    it 'logs the error message' do
      expect(Rails.logger).to receive(:info).with("Validando credenciais para a empresa #{company_id}")
      expect(Rails.logger).to receive(:error).with(/Erro ao validar credenciais: Erro de rede/)
  
      ValidateCredentialsJob.perform_now(company_id, erp, erp_key, erp_secret)
    end
  end
end   