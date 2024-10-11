
class Webhooks::WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:receive_webhook]
  def receive_webhook
    event_type = params.dig(:webhook_event, :event_type)

    case event_type
    when 'create_payable'
      create_payable_event(params[:webhook_event][:data])
    when 'mark_as_paid'
      mark_as_paid_event(params[:webhook_event][:data])
    else
      render json: { error: 'Evento não suportado' }, status: :unprocessable_entity
    end
  end

  private

  # Cria uma nova conta a pagar a partir dos dados do webhook
  def create_payable_event(data)
    client_params = {
      client_id: data[:client_id],
      cost: data[:cost],
      due_date: data[:due_date],
      company_id: data[:company_id],  
      category_code: data[:category_code],
      account_code: data[:account_code],
      codigo_lancamento_integracao: data[:codigo_lancamento_integracao],
      client_code: data[:client_code],  
      categoria: data[:categoria]         
    }
  
    CreatePayableAccountJob.perform_later(client_params: client_params)
    render json: { message: 'Conta a pagar em processo de criação' }, status: :accepted
  end
  

  # Marca uma conta a pagar como paga
  def mark_as_paid_event(data)
    payable_id = data[:payable_id]

    if payable_id.present?
      MarkAsPaidJob.perform_later(payable_id)
      render json: { message: 'Notificação para marcar como pago em processo' }, status: :accepted
    else
      render json: { error: 'ID da conta a pagar não fornecido' }, status: :unprocessable_entity
    end
  end
end