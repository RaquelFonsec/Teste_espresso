# spec/factories/webhook_endpoints.rb
FactoryBot.define do
  factory :webhook_endpoint do
    association :client
    association :company # Assegura que uma company é criada
    url { "http://example.com/webhook" }
    subscriptions { ["*"] }
    enabled { true }
  end
end
