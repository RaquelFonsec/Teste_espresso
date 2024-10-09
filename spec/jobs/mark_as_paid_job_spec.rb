# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'
require 'sidekiq/testing'

RSpec.describe MarkAsPaidJob, type: :job do
  let!(:payable) { create(:payable, status: 'pending', notification_attempts: 0, codigo_lancamento_integracao: '123') }

  before do
    setup_webmock
    allow(Rails.logger).to receive(:info)
    allow(Rails.logger).to receive(:error)
  end

  describe '#perform' do
    context 'quando a notificação do webhook falha' do
      before { setup_webhook_failure }

      context 'com 2 tentativas de pagamento' do
        it 'registra o pagamento como falho após 3 tentativas' do
          simulate_payment_attempts(2)
          expect_payment_to_fail_after_attempts
        end
      end

      context 'ao atingir o limite de tentativas' do
        before { setup_limit_reached }

        it 'não reprograma após atingir o limite de tentativas' do
          perform_payment_notification
          expect_logging_for_limit_reached
        end
      end
    end
  end

  private

  def setup_webmock
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  def setup_webhook_failure
    stub_request(:post, 'https://eo2180vhu0thrzi.m.pipedream.net/')
      .to_return(
        status: 500,
        body: { error: 'Internal Server Error' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  def setup_limit_reached
    payable.update(notification_attempts: 2)
  end

  def simulate_payment_attempts(count)
    count.times { MarkAsPaidJob.perform_now(payable.id) }
  end

  def perform_payment_notification
    MarkAsPaidJob.perform_now(payable.id)
  end

  def expect_payment_to_fail_after_attempts
    perform_payment_notification
    expect(payable.reload.notification_attempts).to eq(3)
    expect(payable.status).to eq('failed')
  end

  def expect_logging_for_limit_reached
    expect(Rails.logger).to have_received(:error)
      .with(/Limite de tentativas atingido para a conta a pagar #{payable.id}\./)
  end
end
