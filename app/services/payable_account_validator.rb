class PayableAccountValidator
  # Definindo os campos obrigatórios e suas respectivas mensagens de erro
  REQUIRED_FIELDS = {
    client_id: 'não pode ser nulo',
    category_code: 'não pode ser nulo',
    account_code: 'não pode ser nulo',
    cost: 'não pode ser nulo ou negativo',
    codigo_lancamento_integracao: 'não pode ser nulo'
  }.freeze

  # Método principal de validação, recebe os parâmetros do cliente e a data de vencimento
  def self.validate(client_params, due_date)
    # Inicializa uma lista para armazenar erros de validação
    errors = []
    # Valida os campos obrigatórios
    validate_required_fields(client_params, errors)
    # Valida a data de vencimento
    validate_due_date(errors, due_date)
    # Retorna a lista de erros
    errors
  end

  # Valida todos os campos obrigatórios definidos em REQUIRED_FIELDS
  def self.validate_required_fields(client_params, errors)
    REQUIRED_FIELDS.each do |field, error_message|
      # Chama o método de verificação de campo para cada campo obrigatório
      check_field(client_params, field, error_message, errors)
    end
  end

  # Verifica se um campo específico do cliente atende aos critérios de validação
  def self.check_field(client_params, field, error_message, errors)
    # Verifica se o campo 'cost' é nulo ou negativo
    if field == :cost
      errors << "#{field} #{error_message}" if client_params[field].nil? || client_params[field] < 0
    else
      # Verifica se o campo é nulo ou vazio (em branco)
      errors << "#{field} #{error_message}" if client_params[field].blank?
    end
  end

  # Valida a data de vencimento
  def self.validate_due_date(errors, due_date)
    # Adiciona um erro se a data de vencimento for nula
    errors << 'due_date não pode ser nulo' if due_date.nil?
    # Adiciona um erro se a data de vencimento for uma data no passado
    if due_date && due_date < Date.today
      errors << 'due_date não pode ser uma data no passado'
    end
  end  
end
