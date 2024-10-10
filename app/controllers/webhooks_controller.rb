# app/controllers/webhooks_controller.rb
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token  # Normalmente você desabilita a verificação de CSRF para webhooks

  # Este método trata a notificação de resultado da validação de credenciais
  def client_validation
    # Parâmetros esperados no corpo da requisição
    payload = params.permit(:company_id, :status, :error, :codigo_cliente_integracao)

    Rails.logger.info("Recebendo notificação de validação do cliente #{payload[:codigo_cliente_integracao]}")

    # Buscar o cliente pelo código de integração (ou qualquer outro identificador único)
    client = Client.find_by(integration_code: payload[:codigo_cliente_integracao])

    if client
      # Atualizar o status de integração do cliente com base na notificação recebida
      if payload[:status] == 'success'
        client.update(integration_status: 'valid', validation_error: nil)
        Rails.logger.info("Cliente #{client.integration_code} validado com sucesso.")
      elsif payload[:status] == 'failure'
        client.update(integration_status: 'invalid', validation_error: payload[:error])
        Rails.logger.warn("Falha ao validar cliente #{client.integration_code}: #{payload[:error]}")
      else
        Rails.logger.error("Status desconhecido recebido para o cliente #{client.integration_code}.")
      end

      render json: { message: 'Webhook recebido com sucesso.' }, status: :ok
    else
      # Caso o cliente não seja encontrado, loga um erro e retorna um status 404
      Rails.logger.error("Cliente não encontrado para o código de integração #{payload[:codigo_cliente_integracao]}")
      render json: { error: 'Cliente não encontrado.' }, status: :not_found
    end
  rescue StandardError => e
    Rails.logger.error("Erro ao processar o webhook: #{e.message}")
    render json: { error: 'Erro interno ao processar o webhook.' }, status: :internal_server_error
  end
end
