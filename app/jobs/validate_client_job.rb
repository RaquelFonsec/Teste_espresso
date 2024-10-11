class ValidateClientJob < ApplicationJob
  queue_as :default

  MAX_RETRIES = 3 # Número máximo de tentativas de retentativa

  # Método principal que é executado quando o job é chamado.
  # Recebe os detalhes da empresa e as credenciais ERP como argumentos, além do número da tentativa atual.
  def perform(company_id, erp, erp_key, erp_secret, integration_code, attempt = 1)
    Rails.logger.info "Executando ValidateClientJob para #{company_id}"
    Rails.logger.info("Tentativa #{attempt} de validação das credenciais para o cliente #{integration_code}.")

    # Valida as credenciais usando as informações fornecidas.
    response = validate_credentials(erp, erp_key, erp_secret)

    if response.success?
      # Se a validação for bem-sucedida, notifica o Espresso sobre o sucesso.
      Rails.logger.info("Credenciais válidas para o cliente #{integration_code}.")
      notify_espresso(integration_code, status: 'success', company_id: company_id)
    else
      # Se a validação falhar, lida com a falha de validação.
      handle_validation_failure(attempt, company_id, erp, erp_key, erp_secret, integration_code)
    end
  rescue StandardError => e
    # Captura e registra qualquer erro que ocorra durante o processo de validação.
    Rails.logger.error("Erro ao validar credenciais: #{e.message}")
    notify_espresso(integration_code, status: 'failure', error: e.message, company_id: company_id)
  end

  private

  # Método que realiza a validação das credenciais chamando a API do Omie.
  def validate_credentials(erp, erp_key, erp_secret)
    response = HTTParty.get('https://app.omie.com.br/api/v1/geral/clientes/', {
      query: { erp: erp, erp_key: erp_key, erp_secret: erp_secret }
    })

    # Verificando se a resposta é bem-sucedida e se o formato é esperado
    if response.success? && response.parsed_response
      return response  # Retorna a resposta se a validação for bem-sucedida.
    else
      # Logando detalhes da falha
      Rails.logger.error("Erro ao validar credenciais: #{response.code} - #{response.body}")
      raise "Erro ao validar credenciais: #{response.code} - #{response.body}"  # Lança uma exceção se a validação falhar.
    end
  end

  # Lida com falhas ao validar credenciais.
  def handle_validation_failure(attempt, company_id, erp, erp_key, erp_secret, integration_code)
    if attempt < MAX_RETRIES
      # Se o número de tentativas não exceder o máximo, reprograma o job para tentar novamente.
      Rails.logger.warn("Servidor indisponível ao validar credenciais para o cliente #{integration_code}. Retentativa #{attempt + 1}.")
      self.class.set(wait: (attempt + 1).minutes).perform_later(company_id, erp, erp_key, erp_secret, integration_code, attempt + 1)
    else
      # Se o limite de tentativas for alcançado, notifica o Espresso sobre a falha.
      Rails.logger.error("Falha ao validar credenciais para o cliente #{integration_code} após #{MAX_RETRIES} tentativas.")
      notify_espresso(integration_code, status: 'failure', error: 'Servidor indisponível após múltiplas tentativas', company_id: company_id)
    end
  end

  # Método que notifica o sistema Espresso sobre o status da validação das credenciais.
  def notify_espresso(integration_code, status:, company_id:, error: nil)
    # Cria o payload com os dados necessários para a notificação.
    payload = {
      codigo_cliente_integracao: integration_code,
      status: status,
      error: error,
      company_id: company_id
    }

    Rails.logger.info("Notificando Espresso com: #{payload}")

    begin
      # Envia uma notificação via HTTP POST para o endpoint do Espresso.
      response = HTTParty.post('https://eorwcvkk5u25m7w.m.pipedream.net/', {
        body: payload.to_json,
        headers: { 'Content-Type' => 'application/json' }
      })

      if response.code == 200
        # Registra sucesso se a notificação for enviada com sucesso.
        Rails.logger.info("Notificação enviada com sucesso para o Espresso: #{response.code} - #{response.body}")
      else
        # Registra erro se a resposta do Espresso não for 200.
        Rails.logger.error("Erro ao notificar o Espresso: #{response.code} - #{response.body}")
        Rails.logger.error("Corpo da resposta: #{response.body}")
      end

    rescue StandardError => e
      # Captura e registra qualquer erro que ocorra ao tentar notificar o Espresso.
      Rails.logger.error("Erro ao notificar o Espresso: #{e.message}")
    end
  end
end
