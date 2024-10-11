FactoryBot.define do
  factory :payable do
    client_id { 1 }
    client_code { "client_code_#{rand(1000)}" }
    cost { 100.0 }
    due_date { Date.today + 7.days }
    category_code { 'category_code' }
    account_code { 'account_code' }
    categoria { 'Some Category' }
    codigo_lancamento_integracao { '123' }
    status { 'pending' }
    notification_attempts { 0 }
    payment_id { nil }  
  end
end

