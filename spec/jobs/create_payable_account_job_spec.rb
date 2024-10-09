require 'rails_helper'
require 'httparty'
require 'webmock/rspec'

RSpec.describe CreatePayableAccountJob, type: :job do
  let(:client_id) { 1 }
  let(:erp_key) { 'dummy_key' }
  let(:erp_secret) { 'dummy_secret' }
  let(:category_code) { 'category_1' }
  let(:account_code) { 'account_1' }
  let(:due_date) { Date.tomorrow.to_s } # Certifique-se de que é uma string
  let(:cost) { 100.0 }
  let(:codigo_lancamento_integracao) { 'integration_code' }
  let(:client_code) { 'client_code' }
  let(:categoria) { 'category' }

  before do
    # Stub para a chamada GET de verificação de servidor
    stub_request(:get, 'https://app.omie.com.br/api/v1/financas/contapagar/')
      .to_return(status: 200)

    # Stub para o servidor de criação de conta a pagar
    stub_request(:post, 'https://app.omie.com.br/api/v1/financas/contapagar/')
      .to_return(status: 200, body: { message: 'Conta a pagar criada com sucesso.', payable_id: 1 }.to_json, headers: { 'Content-Type' => 'application/json' })

    # Stub para a notificação de sucesso
    stub_request(:post, 'https://eo2180vhu0thrzi.m.pipedream.net/')
      .to_return(status: 200)

    # Stub para a notificação de falha
    stub_request(:post, 'https://eo2180vhu0thrzi.m.pipedream.net/')
      .to_return(status: 200, body: { message: 'Notificação recebida com falha' }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  it 'cria uma conta a pagar com sucesso' do
    expect do
      CreatePayableAccountJob.perform_now(
        client_params: {
          client_id: client_id,
          erp_key: erp_key,
          erp_secret: erp_secret,
          category_code: category_code,
          account_code: account_code,
          due_date: due_date,
          cost: cost,
          codigo_lancamento_integracao: codigo_lancamento_integracao,
          client_code: client_code,
          categoria: categoria
        }
      )
    end.to change(Payable, :count).by(1)

    # Verifica se a notificação de sucesso foi enviada
    expect(WebMock).to have_requested(:post, 'https://eo2180vhu0thrzi.m.pipedream.net/').once
  end

  it 'notifica falha quando o servidor não está disponível' do
    # Simula a indisponibilidade do servidor para a chamada de verificação
    stub_request(:get, 'https://app.omie.com.br/api/v1/financas/contapagar/').to_return(status: 503)

    expect do
      CreatePayableAccountJob.perform_now(
        client_params: {
          client_id: client_id,
          erp_key: erp_key,
          erp_secret: erp_secret,
          category_code: category_code,
          account_code: account_code,
          due_date: due_date,
          cost: cost,
          codigo_lancamento_integracao: codigo_lancamento_integracao,
          client_code: client_code,
          categoria: categoria
        }
      )
    end.not_to change(Payable, :count)

    # Verifica se a notificação de falha foi enviada
    expect(WebMock).to have_requested(:post, 'https://eo2180vhu0thrzi.m.pipedream.net/').once
  end
end

  