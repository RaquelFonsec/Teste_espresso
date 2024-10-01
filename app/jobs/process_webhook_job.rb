class ProcessWebhookJob < ApplicationJob
  queue_as :default

  def perform(webhook_params)
    event_type = webhook_params[:event_type]
    client_id = webhook_params[:client_id]

    # Verifica se o client_id está presente
    if client_id.blank?
      Rails.logger.error("Client ID is missing.")
      return
    end

    case event_type
    when 'client_validation' # Certifique-se que este valor corresponde exatamente ao enviado
      validate_client(webhook_params)
    when 'create_account'
      create_account(webhook_params)
    when 'reimbursement'
      process_reimbursement(webhook_params)
    else
      Rails.logger.warn("Unknown event type: #{event_type}")
    end
  end

  private

  def validate_client(webhook_params)
    # Chama o job de validação de cliente
    ValidateClientJob.perform_later(webhook_params[:client_id])
  end

  def create_account(webhook_params)
    # Extraindo parâmetros necessários
    account_code = webhook_params[:account_code]
    category_code = webhook_params[:category_code]
    client_code = webhook_params[:client_code]
    due_date = webhook_params[:due_date]
    cost = webhook_params[:cost]

    # Chama o job para criar a conta a pagar
    CreateAccountJob.perform_later(
      webhook_params[:client_id],
      account_code,
      category_code,
      client_code,
      due_date,
      cost
    )
  end

  def process_reimbursement(webhook_params)
    # Lógica para processar reembolsos
    reimbursement_params = {
      client_id: webhook_params[:client_id],
      amount: webhook_params[:amount],
      reason: webhook_params[:reason]
    }

    # Chama um job específico para reembolsos se necessário
    RefundJob.perform_later(reimbursement_params)
  end
end
