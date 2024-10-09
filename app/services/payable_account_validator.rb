# app/services/payable_account_validator.rb
class PayableAccountValidator
  REQUIRED_FIELDS = {
    client_id: 'não pode ser nulo',
    erp_key: 'não pode ser nulo',
    erp_secret: 'não pode ser nulo',
    category_code: 'não pode ser nulo',
    account_code: 'não pode ser nulo',
    cost: 'não pode ser nulo ou negativo',
    codigo_lancamento_integracao: 'não pode ser nulo'
  }.freeze

  def self.validate(client_params, due_date)
    errors = []
    validate_required_fields(client_params, errors)
    validate_due_date(errors, due_date)
    errors
  end

  def self.validate_required_fields(client_params, errors)
    REQUIRED_FIELDS.each do |field, error_message|
      check_field(client_params, field, error_message, errors)
    end
  end

  def self.check_field(client_params, field, error_message, errors)
    errors << "#{field} #{error_message}" if client_params[field].blank?
  end

  def self.validate_due_date(errors, due_date)
    errors << 'due_date não pode ser nulo' if due_date.nil?
    errors << 'due_date não pode ser uma data no passado' if due_date < Date.today
  end
end
