class NotificationService
  # Método para enviar notificações
  def self.send_notification(payload, target)
    url = case target
          when :omie
            'https://app.omie.com.br/api/v1/financas/contapagar'
          when :pipedream
            'https://eo2180vhu0thrzi.m.pipedream.net/'
          else
            raise ArgumentError, "Alvo não reconhecido: #{target}"
          end

    begin
      response = HTTParty.post(
        url,
        body: payload.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

      log_notification_response(response)

    rescue StandardError => e
      Rails.logger.error("Erro ao tentar enviar notificação: #{e.message}")
      Rails.logger.error("Falha ao enviar notificação: Internal Server Error") 
    end
  end

  def self.log_notification_response(response)
    if response.respond_to?(:success?) && response.success?
      Rails.logger.info('Notificação enviada com sucesso.')
    else
      Rails.logger.error("Falha ao enviar notificação: #{response.code} - #{response.body}")
    end
  end
end
