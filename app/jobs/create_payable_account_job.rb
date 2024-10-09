
class CreatePayableAccountJob < ApplicationJob
  require 'httparty'

  MAX_ATTEMPTS = 3
  RETRY_DELAY = 10 # Tempo em segundos

  def perform(client_params:, attempts: 0)
    due_date = parse_due_date(client_params[:due_date])
    return unless due_date

    Rails.logger.info("Tentando criar Payable com: #{client_params[:client_id]}, #{client_params[:cost]}, #{due_date}")

    unless server_available?
      handle_server_unavailable(client_params, attempts)
      return
    end

    validation_errors = PayableAccountValidator.validate(client_params, due_date)
    if validation_errors.any?
      notify_failure(validation_errors.join(', '))
      return
    end

    create_payable(client_params, due_date)
  end

  private

  def parse_due_date(due_date)
    return unless due_date.is_a?(String)

    Date.parse(due_date)
  rescue ArgumentError => e
    notify_failure("due_date deve ser uma data válida: #{e.message}")
    nil
  end

  def handle_server_unavailable(client_params, attempts)
    notify_failure("Servidor indisponível. Tentativa #{attempts + 1} de #{MAX_ATTEMPTS}.")
    return unless attempts < MAX_ATTEMPTS - 1

    self.class.perform_later(client_params.merge(attempts: attempts + 1))
  end

  def create_payable(client_params, due_date)
    payable_params = client_params.merge(due_date: due_date)
    payable = Payable.new(payable_params)

    Rails.logger.info("Iniciando a criação de um novo Payable: #{payable.inspect}")

    if payable.save
      Rails.logger.info("Conta a pagar criada com sucesso. ID: #{payable.id}")
      notify_success(message: 'Conta a pagar criada com sucesso.', payable_id: payable.id)
    else
      handle_creation_failure(payable)
    end
  end

  def handle_creation_failure(payable)
    Rails.logger.error("Falha ao criar Payable: #{payable.errors.full_messages.join(', ')}")
    notify_failure(payable.errors.full_messages.join(', '))
  end

  def server_available?
    response = HTTParty.get('https://app.omie.com.br/api/v1/financas/contapagar/')
    response.success?
  rescue StandardError => e
    Rails.logger.error("Erro ao verificar servidor: #{e.message}")
    false
  end

  def notify_failure(message)
    Rails.logger.error("Notificação de falha: #{message}")
    NotificationService.send_notification({ status: 'failure', message: message }, :pipedream)
  end

  def notify_success(payload)
    Rails.logger.info("Enviando notificação com o payload: #{payload.inspect}")
    NotificationService.send_notification(payload.merge(status: 'success'), :pipedream) # Adicione :pipedream aqui
  end
end
