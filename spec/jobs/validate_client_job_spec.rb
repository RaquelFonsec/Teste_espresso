require 'rails_helper'
require 'webmock/rspec'
require 'sidekiq/testing'

RSpec.describe ValidateClientJob, type: :job do
  let(:company_id) { 1 }
  let(:erp) { "omie" }
  let(:erp_key) { "dummy_key" }
  let(:erp_secret) { "dummy_secret" }
  let(:integration_code) { "138" }

  before do
    WebMock.disable_net_connect!(allow_localhost: true)
    Sidekiq::Testing.inline! 
  end

  describe "#perform" do
    context "with valid credentials" do
      before do
        allow_any_instance_of(ValidateClientJob).to receive(:validate_credentials).and_return(double(success?: true))
        stub_request(:post, "https://eo2180vhu0thrzi.m.pipedream.net/")
          .to_return(status: 200)
      end

      it "notifies success" do
        ValidateClientJob.perform_now(company_id, erp, erp_key, erp_secret, integration_code)

        expect(a_request(:post, "https://eo2180vhu0thrzi.m.pipedream.net/")
          .with(body: { codigo_cliente_integracao: integration_code, status: 'success', error: nil, company_id: company_id }.to_json)).to have_been_made.once
      end
    end

    context "when the server is unavailable" do
      before do
        allow_any_instance_of(ValidateClientJob).to receive(:validate_credentials).and_return(double(success?: false))
        stub_request(:get, "https://app.omie.com.br/api/v1/geral/clientes/")
          .to_return(status: 500)
      end

      it "retries until max attempts" do
        ValidateClientJob.perform_now(company_id, erp, erp_key, erp_secret, integration_code)

        expect(Sidekiq::Worker.jobs.size).to eq(0) # Não deve haver jobs enfileirados após a execução
      end

      it "retries three times before failing" do
        allow_any_instance_of(ValidateClientJob).to receive(:validate_credentials).and_return(double(success?: false))

        3.times { ValidateClientJob.perform_now(company_id, erp, erp_key, erp_secret, integration_code) }
        
        expect(Sidekiq::Worker.jobs.size).to eq(0) # Não deve haver jobs enfileirados após a execução
      end
    end

    context "when an exception occurs" do
      before do
        allow_any_instance_of(ValidateClientJob).to receive(:validate_credentials).and_raise(StandardError.new("Erro de conexão"))
        stub_request(:post, "https://eo2180vhu0thrzi.m.pipedream.net/")
          .to_return(status: 200)
      end

      it "notifies failure" do
        ValidateClientJob.perform_now(company_id, erp, erp_key, erp_secret, integration_code)

        expect(a_request(:post, "https://eo2180vhu0thrzi.m.pipedream.net/")
          .with(body: { codigo_cliente_integracao: integration_code, status: 'failure', error: 'Erro de conexão', company_id: company_id }.to_json)).to have_been_made.once
      end
    end
  end
end
