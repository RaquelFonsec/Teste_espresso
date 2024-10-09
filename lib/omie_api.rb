# lib/omie_api.rb
class OmieApi
  require 'httparty'

  BASE_URL = 'https://app.omie.com.br/api/v1'

  def self.validate_credentials(_erp, key, secret)
    response = HTTParty.post("#{BASE_URL}/financas/contapagar/",
                             body: {
                               "call": 'ValidarCredenciais',
                               "app_key": key,
                               "app_secret": secret
                             }.to_json,
                             headers: { 'Content-Type' => 'application/json' })

    if response.success?
      OpenStruct.new(success?: true)
    else
      OpenStruct.new(success?: false, error_message: response.parsed_response['message'])
    end
  rescue StandardError => e
    Rails.logger.error "Erro ao chamar API do Omie: #{e.message}"
    OpenStruct.new(success?: false, error_message: "Erro ao chamar API: #{e.message}")
  end

  def self.create_account_payable(params)
    response = HTTParty.post("#{BASE_URL}/financas/contapagar/",
                             body: {
                               "call": 'IncluirContaPagar',
                               "app_key": params[:app_key],
                               "app_secret": params[:app_secret],
                               "contapagar": {
                                 "client_id": params[:client_id],
                                 "client_code": params[:client_code],
                                 "category_code": params[:category_code],
                                 "account_code": params[:account_code],
                                 "due_date": params[:due_date],
                                 "cost": params[:cost]
                               }
                             }.to_json,
                             headers: { 'Content-Type' => 'application/json' })

    if response.success?
      OpenStruct.new(success?: true)
    else
      OpenStruct.new(success?: false, error_message: response.parsed_response['message'])
    end
  rescue StandardError => e
    Rails.logger.error "Erro ao chamar API do Omie: #{e.message}"
    OpenStruct.new(success?: false, error_message: "Erro ao chamar API: #{e.message}")
  end
end
