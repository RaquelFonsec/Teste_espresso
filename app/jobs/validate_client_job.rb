class ValidateClientJob < ApplicationJob
  queue_as :default

  MAX_RETRIES = 3

  def perform(client_id)
    client = Client.find(client_id)
    
    validation_result = ClientValidationService.validate_keys(client.app_key, client.app_secret)

    # Notificar o resultado da validação
    notify_validation(client.id, validation_result)
  end

  private
  
  def notify_validation(client_id, validation_result)
    webhook_url = "https://0a12-2a02-a474-b1c4-1-c97d-bd11-cecd-4945.ngrok-free.app/webhooks/subscribe"
    return unless webhook_url
  
    HTTParty.post(webhook_url, body: {
      client_id: client_id,
      success: validation_result[:success],
      message: validation_result[:message]
    }.to_json, headers: { 'Content-Type' => 'application/json' })
  end
  
  def validate_credentials_with_erp(erp, erp_key, erp_secret)
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

  def notify_espresso(client_id, message, status)
    begin
      response = HTTParty.post("https://webhook.espresso.com/notify", body: {
        client_id: client_id,
        message: message,
        status: status
      }.to_json, headers: { 'Content-Type' => 'application/json' })

      Rails.logger.info("Notification sent to Espresso: #{response.body}") if response.success?
    rescue StandardError => e
      Rails.logger.error("Failed to notify Espresso: #{e.message}")
    end
  end
end

class ClientValidationService
  def self.validate_keys(app_key, app_secret)
    response = HTTParty.post("https://app.omie.com.br/api/v1/geral/clientescaract/", 
                              body: { app_key: app_key, app_secret: app_secret }.to_json,
                              headers: { 'Content-Type' => 'application/json' })
  
    if response.success?
      { success: true, message: 'Credenciais válidas.' }
    else
      { success: false, message: response.parsed_response['error'] }
    end
  end
end
