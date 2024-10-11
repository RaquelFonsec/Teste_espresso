class ValidateClientJob < ApplicationJob
  queue_as :default

  MAX_RETRIES = 3 # Número máximo de tentativas de retentativa

  def perform(company_id, erp, erp_key, erp_secret, integration_code, attempt = 1)
    Rails.logger.info "Executing ValidateClientJob for #{company_id}"
    Rails.logger.info("Tentativa #{attempt} de validação das credenciais para o cliente #{integration_code}.")

    response = validate_credentials(erp, erp_key, erp_secret)

    if response.success?
      Rails.logger.info("Credenciais válidas para o cliente #{integration_code}.")
      notify_espresso(integration_code, status: 'success', company_id: company_id)
    else
      handle_validation_failure(attempt, company_id, erp, erp_key, erp_secret, integration_code)
    end
  rescue StandardError => e
    Rails.logger.error("Erro ao validar credenciais: #{e.message}")
    notify_espresso(integration_code, status: 'failure', error: e.message, company_id: company_id)
  end

  private

  def validate_credentials(erp, erp_key, erp_secret)
    response = HTTParty.get('https://app.omie.com.br/api/v1/geral/clientes/', {
      query: { erp: erp, erp_key: erp_key, erp_secret: erp_secret }
    })

    # Verificando se a resposta é bem-sucedida e se o formato é esperado
    if response.success? && response.parsed_response
      return response
    else
      # Logando detalhes da falha
      Rails.logger.error("Erro ao validar credenciais: #{response.code} - #{response.body}")
      raise "Erro ao validar credenciais: #{response.code} - #{response.body}"
    end
  end

  def handle_validation_failure(attempt, company_id, erp, erp_key, erp_secret, integration_code)
    if attempt < MAX_RETRIES
      Rails.logger.warn("Servidor indisponível ao validar credenciais para o cliente #{integration_code}. Retentativa #{attempt + 1}.")
      self.class.set(wait: (attempt + 1).minutes).perform_later(company_id, erp, erp_key, erp_secret, integration_code, attempt + 1)
    else
      Rails.logger.error("Falha ao validar credenciais para o cliente #{integration_code} após #{MAX_RETRIES} tentativas.")
      notify_espresso(integration_code, status: 'failure', error: 'Servidor indisponível após múltiplas tentativas', company_id: company_id)
    end
  end

  
 def notify_espresso(integration_code, status:, company_id:, error: nil)
  payload = {
    codigo_cliente_integracao: integration_code,
    status: status,
    error: error,
    company_id: company_id
  }

  Rails.logger.info("Notificando Espresso com: #{payload}")

  begin
    response = HTTParty.post('https://eorwcvkk5u25m7w.m.pipedream.net/', {
      body: payload.to_json,
      headers: { 'Content-Type' => 'application/json' }
    })

    if response.code == 200
      Rails.logger.info("Notificação enviada com sucesso para o Espresso: #{response.code} - #{response.body}")
    else
      # Logar mais informações detalhadas quando ocorrer erro
      Rails.logger.error("Erro ao notificar o Espresso: #{response.code} - #{response.body}")
      Rails.logger.error("Corpo da resposta: #{response.body}")
    end

  rescue StandardError => e
    Rails.logger.error("Erro ao notificar o Espresso: #{e.message}")
  end
end
end 
