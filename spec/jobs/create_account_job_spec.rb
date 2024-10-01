require 'rails_helper'
require 'webmock/rspec'
require 'httparty'

RSpec.describe CreateAccountJob, type: :job do
  let(:client) { create(:client, erp_key: 'test_erp_key', erp_secret: 'test_erp_secret') }
  let(:client_id) { client.id }
  let(:account_code) { 'CONTA001' }
  let(:category_code) { 'CATEGORIA001' }
  let(:client_code) { 'C001' }
  let(:due_date) { '2024-10-30' }
  let(:cost) { 100.5 }
  let(:webhook_url) { 'http://example.com/webhook' }

  before do
    allow(client).to receive(:webhook_endpoints).and_return([double(url: webhook_url)])
  end

  describe '#perform' do
    context 'when the API call is successful' do
      before do
        allow(Client).to receive(:find).with(client_id).and_return(client)
        allow(HTTParty).to receive(:post).and_return(double(success?: true))
      end

      it 'creates a Payable record' do
        expect { described_class.perform_now(client_id, account_code, category_code, client_code, due_date, cost) }
          .to change { Payable.count }.by(1)
      end

      it 'notifies the webhook' do
        expect(HTTParty).to receive(:post).with(
          webhook_url,
          body: { success: true, client_id: client_id, message: "Account created successfully." }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

        described_class.perform_now(client_id, account_code, category_code, client_code, due_date, cost)
      end
    end

    context 'when the API call fails' do
      before do
        allow(Client).to receive(:find).with(client_id).and_return(client)
        allow(HTTParty).to receive(:post).and_return(double(success?: false, body: 'Error message'))
      end

      it 'does not create a Payable record' do
        expect { described_class.perform_now(client_id, account_code, category_code, client_code, due_date, cost) }
          .not_to change { Payable.count }
      end

      it 'logs and notifies the failure' do
        expect(Rails.logger).to receive(:error).with(/Notifying failure for client_id #{client_id}: Failed to create account: Error message/)
        expect(HTTParty).to receive(:post).with(
          webhook_url,
          body: { success: false, client_id: client_id, message: 'Failed to create account: Error message' }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )

        described_class.perform_now(client_id, account_code, category_code, client_code, due_date, cost)
      end
    end

    context 'when there is a StandardError' do
      before do
        allow(Client).to receive(:find).with(client_id).and_return(client)
        allow(HTTParty).to receive(:post).and_raise(StandardError.new("API error"))
      end

      it 'retries the job up to 5 times before notifying failure' do
        expect(Rails.logger).to receive(:warn).exactly(5).times
        expect(Rails.logger).to receive(:error).with(/Failed to create account after 5 attempts: API error/)
        expect(HTTParty).to receive(:post).exactly(5).times

        described_class.perform_now(client_id, account_code, category_code, client_code, due_date, cost)
      end
    end
  end
end
