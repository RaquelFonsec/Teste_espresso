# frozen_string_literal: true

# Este job é responsável por marcar uma conta a pagar como paga e enviar uma notificação.
require 'ostruct'
class MarkAsPaidJob < ApplicationJob
  queue_as :default

  # Método principal que é executado quando o job é chamado.
  # Recebe o ID da conta a pagar como argumento.
  def perform(payable_id)
    payable = find_payable(payable_id)  # Busca a conta a pagar pelo ID fornecido.
    return unless payable  # Se a conta não for encontrada, encerra o job.

    return if skip_notification?(payable)  # Verifica se a notificação deve ser pulada.

    Rails.logger.info("Iniciando notificação para a conta a pagar: #{payable_id}")
    handle_notification(payable)  # Manipula o envio da notificação.
  end

  private

  # Busca a conta a pagar no banco de dados utilizando o ID.
  # Retorna a conta ou nil se não encontrada.
  def find_payable(payable_id)
    payable = Payable.find_by(id: payable_id)
    Rails.logger.error("Conta a pagar com ID #{payable_id} não encontrada.") unless payable
    payable
  end

  # Verifica se a notificação deve ser pulada.
  # Retorna true se já existe um reembolso pago, caso contrário, retorna false.
  def skip_notification?(payable)
    if payable.reimbursement_existe? && payable.reimbursement_pago?
      Rails.logger.info("Reembolso já registrado e pago para a conta a pagar #{payable.id}. Notificação não necessária.")
      true
    else
      false
    end
  end

  # Manipula o envio da notificação e atualiza o status da conta a pagar.
  def handle_notification(payable)
    response = send_notification(payable)  # Envia a notificação e obtém a resposta.
    update_payable_status(payable, response)  # Atualiza o status da conta com base na resposta.
  end

  # Atualiza o status da conta a pagar com base na resposta recebida.
  def update_payable_status(payable, response)
    Rails.logger.info("Resposta recebida ao tentar notificar a conta a pagar #{payable.id}: #{response.inspect}")
    if response.success?
      payable.update(status: 'paid')  # Marca a conta como paga se a notificação foi bem-sucedida.
      Rails.logger.info("Conta a pagar #{payable.id} marcada como paga.")
    else
      handle_notification_failure(payable, response)  # Lida com a falha no envio da notificação.
    end
  end

  # Lida com falhas ao notificar a conta a pagar.
  def handle_notification_failure(payable, response)
    Rails.logger.error("Falha ao notificar a conta a pagar #{payable.id}. Resposta: #{response.inspect}")
    Rails.logger.error("Detalhes do erro: #{response.response_body}")
    payable.increment!(:notification_attempts)  # Incrementa o contador de tentativas.

    if payable.notification_attempts >= 3
      Rails.logger.error("Limite de tentativas atingido para a conta a pagar #{payable.id}.")
      payable.update(status: 'failed')  # Marca a conta como falhada após 3 tentativas.
    else
      requeue_notification(payable)  # Reprograma a notificação para tentar novamente.
    end
  end

  # Reprograma a notificação para a conta a pagar, aguardando 10 minutos antes de tentar novamente.
  def requeue_notification(payable)
    Rails.logger.info("Reprogramando notificação para a conta a pagar #{payable.id}. " \
                      "Tentativa: #{payable.notification_attempts}")
    self.class.set(wait: 10.minutes).perform_later(payable.id)  # Agenda nova tentativa.
  end

  # Envia a notificação para o endpoint especificado.
  def send_notification(payable)
    payload = build_payload(payable)  # Constrói o payload da notificação.
    Rails.logger.info("Enviando notificação com o payload: #{payload.inspect}")

    send_request(payload)  # Envia a requisição HTTP.
  end

  # Envia uma requisição HTTP para o endpoint especificado com o payload.
  def send_request(payload)
    response = HTTParty.post('https://eorwcvkk5u25m7w.m.pipedream.net/',
                             body: payload.to_json,
                             headers: { 'Content-Type' => 'application/json' })

    if response.code == 200
      OpenStruct.new(success?: true, response_body: response.body)  # Retorna sucesso se a resposta for 200.
    else
      Rails.logger.error("Erro ao enviar notificação: HTTP #{response.code}")
      OpenStruct.new(success?: false, response_body: response.body)  # Retorna falha em caso de erro.
    end
  rescue StandardError => e
    Rails.logger.error("Erro ao enviar notificação: #{e.message}")
    OpenStruct.new(success?: false)  # Retorna falha se ocorrer uma exceção.
  end

  # Constrói o payload da notificação.
  def build_payload(payable)
    base_payload(payable).merge(status: payload_status(payable))  # Adiciona o status ao payload base.
  end

  # Retorna os dados básicos necessários para o payload da notificação.
  def base_payload(payable)
    {
      account_code: payable.account_code,
      category_code: payable.category_code,
      client_code: payable.client_code,
      client_id: payable.client_id,
      cost: payable.cost,
      due_date: payable.due_date,
      category: payable.categoria,
      integration_code: payable.codigo_lancamento_integracao,
      payment_id: payable.payment_id 
    }
  end
  
  # Retorna o status da conta a pagar (pago ou pendente).
  def payload_status(payable)
    payable.status == 'paid' ? 'paid' : 'pending'
  end
end
