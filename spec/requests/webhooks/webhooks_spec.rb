require 'rails_helper'

RSpec.describe "Webhooks::Webhooks", type: :request do
  describe "GET /receive_webhook" do
    it "returns http success" do
      get "/webhooks/webhooks/receive_webhook"
      expect(response).to have_http_status(:success)
    end
  end

end
