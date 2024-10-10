require 'rails_helper'

RSpec.describe "Webhooks", type: :request do
  describe "GET /client_validation" do
    it "returns http success" do
      get "/webhooks/client_validation"
      expect(response).to have_http_status(:success)
    end
  end

end
