# spec/factories/companies.rb
FactoryBot.define do
  factory :company do
    name { "Nome da Empresa" }
    erp_key { "valid_erp_key" }         # Atribua um valor para erp_key
    erp_secret { "valid_erp_secret" }    # Atribua um valor para erp_secret
  end
end
