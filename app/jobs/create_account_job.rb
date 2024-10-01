class CreateAccountJob < ApplicationJob
  queue_as :default

  MAX_RETRIES = 5

  def perform(client_id, account_code, category_code, client_code, due_date, cost)
    client = Client.find(client_id)

    retries = 0

    begin
      # Lógica para criar a conta a pagar no ERP
      response = create_account_in_erp(client, account_code, category_code, client_code, due_date, cost)

      # Verifica a resposta do ERP
      if response.success?
        # Notifica sucesso
        notify_espresso(client_id, "Account created successfully.", :success)
      else
        # Notifica falha com mensagem do ERP
        notify_espresso(client_id, "Failed to create account: #{response.parsed_response['message']}", :error)
      end
    rescue StandardError => e
      retries += 1
      if retries <= MAX_RETRIES
        Rails.logger.warn("Attempt #{retries} failed: #{e.message}. Retrying in #{5 ** retries} seconds...")
        sleep(5 ** retries)  # Atraso exponencial entre as tentativas
        retry
      else
        log_and_notify_failure(client_id, "Failed to create account after #{MAX_RETRIES} attempts: #{e.message}")
      end
    end
  end

  private

  def create_account_in_erp(client, account_code, category_code, client_code, due_date, cost)
    # Simulação de requisição ao ERP para criar a conta a pagar
    HTTParty.post("https://api.omie.com.br/api/v1/financas/contapagar/",
      body: {
        'client_id' => client.id,
        'account_code' => account_code,
        'category_code' => category_code,
        'client_code' => client_code,
        'due_date' => due_date,
        'cost' => cost
      }.to_json,
      headers: { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{client.erp_token}" } # Token de autenticação
    )
  rescue HTTParty::Error => e
    Rails.logger.error("Error connecting to ERP: #{e.message}")
    OpenStruct.new(success?: false, parsed_response: { 'message' => 'Error connecting to ERP' }) # Retorna erro
  end

  def notify_espresso(client_id, message, status)
    # Enviar notificação ao Espresso via webhook
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

  def log_and_notify_failure(client_id, message)
    Rails.logger.error("Job failed for client_id #{client_id}: #{message}")
    notify_espresso(client_id, message, :error)
  end
end
