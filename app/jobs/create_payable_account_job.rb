class CreatePayableAccountJob < ApplicationJob
  require 'httparty' # Inclui a biblioteca HTTParty para realizar requisições HTTP

  MAX_ATTEMPTS = 3 # Número máximo de tentativas para criar uma conta a pagar
  RETRY_DELAY = 10 # Tempo em segundos entre as tentativas de retentativa

  # Método principal que executa a criação da conta a pagar
  def perform(client_params:, attempts: 0)
    # Tenta analisar a data de vencimento a partir dos parâmetros do cliente
    due_date = parse_due_date(client_params[:due_date])
    return unless due_date # Retorna se a data de vencimento não for válida

    Rails.logger.info("Tentando criar Payable com: #{client_params[:client_id]}, #{client_params[:cost]}, #{due_date}")

    # Verifica se o servidor está disponível antes de prosseguir
    unless server_available?
      handle_server_unavailable(client_params, attempts) # Lida com a indisponibilidade do servidor
      return
    end

    # Valida os parâmetros do cliente antes de criar a conta a pagar
    validation_errors = PayableAccountValidator.validate(client_params, due_date)
    if validation_errors.any?
      notify_failure(validation_errors.join(', ')) # Notifica falha se houver erros de validação
      return
    end

    create_payable(client_params, due_date) # Tenta criar a conta a pagar
  end

  private

  # Método que tenta analisar a data de vencimento
  def parse_due_date(due_date)
    return unless due_date.is_a?(String) # Verifica se a data é uma string

    Date.parse(due_date) # Tenta converter a string em um objeto Date
  rescue ArgumentError => e
    # Notifica falha se ocorrer um erro ao analisar a data
    notify_failure("due_date deve ser uma data válida: #{e.message}")
    nil # Retorna nil se a data não for válida
  end

  # Lida com a situação em que o servidor está indisponível
  def handle_server_unavailable(client_params, attempts)
    notify_failure("Servidor indisponível. Tentativa #{attempts + 1} de #{MAX_ATTEMPTS}.") # Notifica falha
    return unless attempts < MAX_ATTEMPTS - 1 # Verifica se ainda há tentativas restantes

    # Reprograma o job para tentar novamente após o número de tentativas
    self.class.perform_later(client_params.merge(attempts: attempts + 1))
  end

  # Método que cria a conta a pagar com os parâmetros fornecidos
  def create_payable(client_params, due_date)
    payable_params = client_params.merge(due_date: due_date) # Adiciona a data de vencimento aos parâmetros
    payable = Payable.new(payable_params) # Cria uma nova instância de Payable

    Rails.logger.info("Iniciando a criação de um novo Payable: #{payable.inspect}")

    # Tenta salvar a conta a pagar no banco de dados
    if payable.save
      Rails.logger.info("Conta a pagar criada com sucesso. ID: #{payable.id}")
      notify_success(message: 'Conta a pagar criada com sucesso.', payable_id: payable.id)
    else
      Rails.logger.error("Falha ao criar Payable: #{payable.errors.full_messages.join(', ')}")
      notify_failure(payable.errors.full_messages.join(', '))
    end
  end     

  # Lida com falhas ao criar a conta a pagar
  def handle_creation_failure(payable)
    Rails.logger.error("Falha ao criar Payable: #{payable.errors.full_messages.join(', ')}") # Registra os erros
    notify_failure(payable.errors.full_messages.join(', ')) # Notifica a falha
  end

  # Verifica se o servidor está disponível para receber requisições
  def server_available?
    response = HTTParty.get('https://app.omie.com.br/api/v1/financas/contapagar/')
    response.success? # Retorna true se a resposta for bem-sucedida
  rescue StandardError => e
    Rails.logger.error("Erro ao verificar servidor: #{e.message}") # Registra qualquer erro ao verificar o servidor
    false # Retorna false se ocorrer um erro
  end

  # Notifica falhas no processo de criação da conta a pagar
  def notify_failure(message)
    Rails.logger.error("Notificação de falha: #{message}") # Registra a falha
    NotificationService.send_notification({ status: 'failure', message: message }, :pipedream) # Envia notificação
  end

  # Notifica sucesso na criação da conta a pagar
  def notify_success(payload)
    Rails.logger.info("Enviando notificação com o payload: #{payload.inspect}") # Registra a notificação
    NotificationService.send_notification(payload.merge(status: 'success'), :pipedream) # Envia notificação de sucesso
  end
end
