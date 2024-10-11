require 'rails_helper'

RSpec.describe Payable, type: :model do
  # Testando as validações
  it { should validate_presence_of(:client_id) }
  it { should validate_presence_of(:client_code) }
  it { should validate_presence_of(:cost) }
  it { should validate_numericality_of(:cost).is_greater_than_or_equal_to(0) }
  it { should validate_presence_of(:due_date) }
  it { should validate_presence_of(:category_code) }
  it { should validate_presence_of(:account_code) }
  it { should validate_presence_of(:categoria) }
  it { should validate_presence_of(:codigo_lancamento_integracao) }

  # Testando associações
  it { should have_one(:reimbursement) }

  # Testando métodos personalizados
  describe '#reimbursement_existe?' do
    it 'retorna true se o reembolso existir' do
      client = create(:client) # Criar um cliente
      payable = create(:payable, client_id: client.id) # Atribuindo apenas o client

      create(:reimbursement, payable: payable, client: client) # Usar a fábrica corretamente
      expect(payable.reimbursement_existe?).to be true
    end

    it 'retorna false se o reembolso não existir' do
      client = create(:client)
      payable = create(:payable, client_id: client.id)
      expect(payable.reimbursement_existe?).to be false
    end
  end

  describe '#paid?' do
    it 'retorna true se o status for "paid"' do
      payable = create(:payable, status: 'paid')
      expect(payable.paid?).to be true
    end

    it 'retorna false se o status não for "paid"' do
      payable = create(:payable, status: 'pending')
      expect(payable.paid?).to be false
    end
  end

  describe '#failed?' do
    it 'retorna true se o status for "failed"' do
      payable = create(:payable, status: 'failed')
      expect(payable.failed?).to be true
    end

    it 'retorna false se o status não for "failed"' do
      payable = create(:payable, status: 'pending')
      expect(payable.failed?).to be false
    end
  end

  # Testando callback e validações personalizadas
  describe 'callbacks' do
    it 'define o status padrão como "pending" ao criar um novo registro' do
      payable = create(:payable, client_id: 1, client_code: '123', cost: 100, due_date: Date.tomorrow, 
                            category_code: 'code', account_code: 'code', categoria: 'D', codigo_lancamento_integracao: '180')
      expect(payable.status).to eq('pending')
    end

    it 'não permite que due_date seja no passado' do
      payable = Payable.new(client_id: 1, client_code: '123', cost: 100, due_date: Date.yesterday, 
                            category_code: 'code', account_code: 'code', categoria: 'D', codigo_lancamento_integracao: '180')
      payable.valid?
      expect(payable.errors[:due_date]).to include('não pode ser uma data no passado.')
    end
  end
end

