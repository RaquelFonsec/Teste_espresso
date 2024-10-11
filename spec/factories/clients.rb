
FactoryBot.define do
    factory :client do
      company
      client_code { "unique_client_code" }
      erp_key { "client_erp_key" }
      erp_secret { "client_erp_secret" }
    end
  end
  