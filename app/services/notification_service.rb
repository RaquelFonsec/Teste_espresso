class NotificationService
  # Método para enviar notificações a um alvo específico
  def self.send_notification(payload, target)
    # Determina a URL de destino com base no alvo fornecido
    url = case target
          when :omie
            'https://app.omie.com.br/api/v1/financas/contapagar' # URL para a API Omie
          when :pipedream
            'https://eorwcvkk5u25m7w.m.pipedream.net/' # URL para o serviço Pipedream
          else
            # Levanta um erro se o alvo não for reconhecido
            raise ArgumentError, "Alvo não reconhecido: #{target}"
          end

    begin
      # Envia uma requisição POST para a URL com o payload no formato JSON
      response = HTTParty.post(
        url,
        body: payload.to_json, # Converte o payload em JSON
        headers: { 'Content-Type' => 'application/json' } # Define o cabeçalho como JSON
      )

      # Loga a resposta da notificação
      log_notification_response(response)

    rescue StandardError => e
      # Trata erros que podem ocorrer durante o envio da notificação
      Rails.logger.error("Erro ao tentar enviar notificação: #{e.message}") # Registra o erro
      Rails.logger.error("Falha ao enviar notificação: Internal Server Error") # Mensagem padrão de falha
    end
  end

  # Método para registrar a resposta recebida após enviar uma notificação
  def self.log_notification_response(response)
    # Verifica se a resposta possui o método success? e se é bem-sucedida
    if response.respond_to?(:success?) && response.success?
      Rails.logger.info('Notificação enviada com sucesso.') # Registra o sucesso da notificação
    else
      # Registra falha com detalhes da resposta
      Rails.logger.error("Falha ao enviar notificação: #{response.code} - #{response.body}")
    end
  end
end
