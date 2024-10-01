# spec/factories/clients.rb
FactoryBot.define do
  factory :client do
    name { "Nome do Cliente" }
    erp { "valid_erp" }           # Certifique-se de que este campo é preenchido
    erp_key { "valid_key" }
    erp_secret { "valid_secret" }
    
    association :company           # Se a empresa for necessária, garanta que isso esteja configurado
  end
end
