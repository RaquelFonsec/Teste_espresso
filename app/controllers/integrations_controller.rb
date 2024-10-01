class IntegrationsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def validate_credentials
    # Recebendo os parâmetros da requisição
    company_id = params[:company_id]
    erp = params[:erp]
    erp_key = params[:erp_key]
    erp_secret = params[:erp_secret]

    # Validação das credenciais
    validation_result = validate_credentials_with_erp(erp, erp_key, erp_secret)

    # Preparando os dados para o webhook
    response_data = {
      company_id: company_id,
      valid: validation_result[:success],
      message: validation_result[:message]
    }

    # Definindo a URL do webhook
    webhook_url = "0a12-2a02-a474-b1c4-1-c97d-bd11-cecd-4945.ngrok-free.app/webhooks/subscribe"

    # Enviando a resposta de volta ao Espresso via webhook
    webhook_response = HTTParty.post(webhook_url,
                                       body: response_data.to_json,
                                       headers: { 'Content-Type' => 'application/json' })

    unless webhook_response.success?
      Rails.logger.error("Erro ao enviar webhook: #{webhook_response.body}")
    end

    if validation_result[:success]
      render json: { status: 'ok' }, status: :ok
    else
      render json: { status: 'error', message: validation_result[:message] }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error("Erro ao validar credenciais: #{e.message}")
    render json: { status: 'error', message: e.message }, status: :unprocessable_entity
  end

  private

  def validate_credentials_with_erp(erp, erp_key, erp_secret)
    # Aqui você faria a chamada ao ERP para validar as credenciais
    response = HTTParty.post("https://api.#{erp}.com/validate", {
      body: {
        key: erp_key,
        secret: erp_secret
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    })

    if response.success?
      { success: true, message: 'Credenciais válidas.' }
    else
      { success: false, message: 'Credenciais inválidas.', error: response.body }
    end
  end
end

