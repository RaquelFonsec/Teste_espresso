require 'rails_helper'

RSpec.describe PayableAccountValidator do
  describe '.validate' do
    let(:due_date) { Date.tomorrow }

    context 'when all required fields are present' do
      it 'returns no errors' do
        client_params = {
          client_id: 5616193524,
          category_code: '2.01.04',
          account_code: 5490836016,
          cost: 100.0,
          codigo_lancamento_integracao: '180'
        }

        errors = PayableAccountValidator.validate(client_params, due_date)
        expect(errors).to be_empty
      end
    end

    context 'when required fields are missing' do
      it 'returns errors for missing fields' do
        client_params = {
          client_id: nil,
          category_code: nil,
          account_code: nil,
          cost: nil, # Alterado para nil para gerar erro de custo
          codigo_lancamento_integracao: nil
        }

        errors = PayableAccountValidator.validate(client_params, due_date)
        expect(errors).to include("client_id não pode ser nulo")
        expect(errors).to include("category_code não pode ser nulo")
        expect(errors).to include("account_code não pode ser nulo")
        expect(errors).to include("cost não pode ser nulo ou negativo")
        expect(errors).to include("codigo_lancamento_integracao não pode ser nulo")
      end
    end

    context 'when validating due date' do
      it 'returns an error if due_date is nil' do
        client_params = {
          client_id: 5616193524,
          category_code: '2.01.04',
          account_code: 5490836016,
          cost: 100.0,
          codigo_lancamento_integracao: '180'
        }

        errors = PayableAccountValidator.validate(client_params, nil)
        expect(errors).to include("due_date não pode ser nulo")
      end

      it 'returns an error if due_date is in the past' do
        past_due_date = Date.yesterday
        client_params = {
          client_id: 5616193524,
          category_code: '2.01.04',
          account_code: 5490836016,
          cost: 100.0,
          codigo_lancamento_integracao: '180'
        }

        errors = PayableAccountValidator.validate(client_params, past_due_date)
        expect(errors).to include("due_date não pode ser uma data no passado")
      end
    end
  end
end

