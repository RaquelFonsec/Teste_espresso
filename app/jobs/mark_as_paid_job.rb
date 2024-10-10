# frozen_string_literal: true

# This job is responsible for marking a payable as paid and sending a notification.
require 'ostruct'
class MarkAsPaidJob < ApplicationJob
  queue_as :default

  def perform(payable_id)
    payable = find_payable(payable_id)
    return unless payable

    return if skip_notification?(payable)

    Rails.logger.info("Iniciando notificação para a conta a pagar: #{payable_id}")
    handle_notification(payable)
  end

  private

  def find_payable(payable_id)
    payable = Payable.find_by(id: payable_id)
    Rails.logger.error("Conta a pagar com ID #{payable_id} não encontrada.") unless payable
    payable
  end

  def skip_notification?(payable)
    if payable.reimbursement_existe? && payable.reimbursement_pago?
      Rails.logger.info("Reembolso já registrado e pago para a conta a pagar #{payable.id}. Notificação não necessária.")
      true
    else
      false
    end
  end
  
  def payload_status(payable)
    return 'paid' if payable.status == 'paid'
    'pending'
  end
  
  

  def handle_notification(payable)
    response = send_notification(payable)
    update_payable_status(payable, response)
  end

  def update_payable_status(payable, response)
    if response.success?
      payable.update(status: 'paid')
      Rails.logger.info("Conta a pagar #{payable.id} marcada como paga.")
    else
      handle_notification_failure(payable, response)
    end
  end

  def handle_notification_failure(payable, response)
    Rails.logger.error("Falha ao notificar a conta a pagar #{payable.id}. Resposta: #{response.inspect}")
    Rails.logger.error("Detalhes do erro: #{response.response_body}")
    payable.increment!(:notification_attempts)

    if payable.notification_attempts >= 3
      Rails.logger.error("Limite de tentativas atingido para a conta a pagar #{payable.id}.")
      payable.update(status: 'failed')
    else
      requeue_notification(payable)
    end
  end

  def requeue_notification(payable)
    Rails.logger.info("Reprogramando notificação para a conta a pagar #{payable.id}. " \
                      "Tentativa: #{payable.notification_attempts}")
    self.class.set(wait: 10.minutes).perform_later(payable.id)
  end

  def send_notification(payable)
    payload = build_payload(payable)
    Rails.logger.info("Enviando notificação com o payload: #{payload.inspect}")

    send_request(payload)
  end

  def send_request(payload)
    response = HTTParty.post('https://eoz2bsfgfb26coz.m.pipedream.net',
                             body: payload.to_json,
                             headers: { 'Content-Type' => 'application/json' })

    if response.code == 200
      OpenStruct.new(success?: true, response_body: response.body)
    else
      Rails.logger.error("Erro ao enviar notificação: HTTP #{response.code}")
      OpenStruct.new(success?: false, response_body: response.body)
    end
  rescue StandardError => e
    Rails.logger.error("Erro ao enviar notificação: #{e.message}")
    OpenStruct.new(success?: false)
  end

  def build_payload(payable)
    base_payload(payable).merge(status: payload_status(payable))
  end

  def base_payload(payable)
    {
      account_code: payable.account_code,
      category_code: payable.category_code,
      client_code: payable.client_code,
      client_id: payable.client_id,
      cost: payable.cost,
      due_date: payable.due_date,
      category: payable.categoria,
      integration_code: payable.codigo_lancamento_integracao
    }
  end

  def payload_status(payable)
    payable.status == 'paid' ? 'paid' : 'pending'
  end
end
