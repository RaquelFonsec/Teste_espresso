class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:receive_webhook, :subscribe]

  def receive_webhook
    webhook_params = params.require(:webhook).permit(:client_id, :event_type, :callback_url, :erp, :erp_key, :erp_secret)

    if valid_credentials?(webhook_params)
      # Enfileirar job para processar o webhook
      ProcessWebhookJob.perform_later(webhook_params)
      render json: { status: 'accepted' }, status: :accepted
    else
      render json: { error: 'Invalid credentials' }, status: :unprocessable_entity
    end
  end

  def subscribe
    # Permitir os parâmetros relevantes
    subscription_params = params.require(:webhook).permit(:client_id, :event_type, :callback_url, :erp, :erp_key, :erp_secret)
  
    # Verificar se os parâmetros obrigatórios estão presentes
    if subscription_params.values.any?(&:blank?)
      render json: { error: 'Missing required parameters: client_id, event_type, callback_url, erp, erp_key, and erp_secret are required.' }, status: :unprocessable_entity
      return
    end
  
    # Verifique se o client_id existe
    client = Client.find_by(id: subscription_params[:client_id])
    unless client
      render json: { error: 'Client must exist' }, status: :unprocessable_entity
      return
    end
  
    webhook_endpoint = WebhookEndpoint.find_or_create_by(url: subscription_params[:callback_url]) do |we|
      we.client_id = subscription_params[:client_id]
      we.erp = subscription_params[:erp]  # Agora esta linha é válida
    end
    
    # Verifique se o webhook_endpoint foi criado com sucesso
    unless webhook_endpoint.persisted?
      render json: { error: 'Webhook endpoint must exist or failed to create.' }, status: :unprocessable_entity
      return
    end
  
    # Criar a assinatura
    subscription = WebhookSubscription.new(
      client_id: subscription_params[:client_id],
      webhook_endpoint_id: webhook_endpoint.id,
      event: subscription_params[:event_type],
      status: 'active'
    )
  
    if subscription.save
      render json: { message: 'Webhook subscription created successfully.', subscription: subscription }, status: :created
    else
      render json: { error: subscription.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def configure_client
    client_params = params.permit(:company_id, :erp, :erp_key, :erp_secret)

    client = Client.create(client_params)

    if client.valid?
      ValidateClientJob.perform_later(client.id)
      render json: { message: 'Client configuration received. Validation in progress.' }, status: :accepted
    else
      render json: { error: client.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def reimbursements
    reimbursement_params = params.permit(:client_id, :client_code, :category_code, :account_code, :due_date, :cost)

    if reimbursement_params.values.any?(&:blank?)
      render json: { error: 'Missing required parameters.' }, status: :unprocessable_entity
      return
    end

    CreateAccountJob.perform_later(reimbursement_params.to_h)
    notify_espresso(reimbursement_params[:client_id], 'Reimbursement processed successfully.', :success)

    render json: { message: 'Reimbursement processed. Account payable creation in progress.' }, status: :accepted
  end

  def create_accounts_payable
    account_params = params.permit(:client_id, :client_code, :category_code, :account_code, :due_date, :cost)

    CreateAccountJob.perform_later(account_params.to_h)
    render json: { message: 'Account payable creation received. Processing in background.' }, status: :accepted
  end

  def notify_payment
    payment_params = params.permit(:account_code)

    NotifyPaymentJob.perform_later(payment_params[:account_code])
    render json: { message: 'Payment notification received. Processing in background.' }, status: :accepted
  end

  def create_refund
    refund_params = params.permit(:client_id, :amount, :reason)

    if refund_params[:client_id].blank? || refund_params[:amount].blank?
      render json: { error: 'Missing required parameters: client_id and amount are required.' }, status: :unprocessable_entity
      return
    end

    RefundJob.perform_later(refund_params.to_h)
    render json: { message: 'Refund request received. Processing in background.' }, status: :accepted
  end

  private

  def valid_credentials?(params)
    client = Client.find_by(id: params[:client_id])
    return false unless client

    params[:erp_key] == client.erp_key && params[:erp_secret] == client.erp_secret
  end

  def notify_espresso(client_id, message, status)
    begin
      response = HTTParty.post("https://webhook.url/notify", body: { client_id: client_id, message: message }.to_json, headers: { 'Content-Type' => 'application/json' })
      Rails.logger.info("Notification sent to Espresso: #{response.body}") if response.success?
    rescue StandardError => e
      Rails.logger.error("Failed to notify Espresso: #{e.message}")
    end
  end
end
