class ReimbursementService
    def self.create_account_payable(data)
      response = HTTParty.post("https://api.omie.com.br/api/v1/contasapagar",
        body: {
          company_id: data[:company_id],
          value: data[:value],
          description: data[:description],
          due_date: data[:due_date],
          payment_method: data[:payment_method]
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  
      if response.success?
        Rails.logger.info("Conta a pagar criada com sucesso para a empresa #{data[:company_id]}")
        track_payment_status(data[:company_id])
      else
        Rails.logger.error("Falha ao criar conta a pagar: #{response.body}")
        # Aqui você pode adicionar lógica de retry ou fallback se necessário
      end
    end
  
    def self.track_payment_status(company_id)
      response = HTTParty.get("https://api.omie.com.br/api/v1/contasapagar/#{company_id}/status")
  
      if response.success?
        status = response.parsed_response["status"]
        # Notificar o Espresso sobre o status do pagamento
        notify_espresso(company_id, status)
      else
        Rails.logger.error("Erro ao verificar o status do pagamento: #{response.body}")
      end
    end
  
    private
  
    def self.notify_espresso(company_id, status)
      response = HTTParty.post("https://api.espresso.com.br/notificacao",
        body: {
          company_id: company_id,
          payment_status: status
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  
      if response.success?
        Rails.logger.info("Notificação enviada para o Espresso sobre o pagamento da empresa #{company_id}")
      else
        Rails.logger.error("Falha ao enviar notificação para o Espresso: #{response.body}")
      end
    end
  end
  