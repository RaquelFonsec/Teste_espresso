require 'rails_helper'

RSpec.describe Reimbursement, type: :model do
  let!(:company) { create(:company) }
  let!(:client) { create(:client, company: company) }
  let!(:account) { create(:account) }
  let!(:payable) { create(:payable) }

  let(:valid_attributes) do
    {
      company: company,
      client: client,
      account: account,
      value: 100,
      description: 'Reembolso de teste',
      due_date: Date.today,
      payment_method: 'cartão',
      cost: 50,
      status: 'pendente' # Você pode testar outros status aqui
    }
  end

  it 'is valid with valid attributes' do
    reimbursement = Reimbursement.new(valid_attributes)
    expect(reimbursement).to be_valid
  end

  # Testando as validações
  it { should validate_presence_of(:value) }
  it { should validate_numericality_of(:value) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:due_date) }
  it { should validate_presence_of(:payment_method) }
  it { should validate_presence_of(:cost) }
  it { should validate_numericality_of(:cost) }
  it { should validate_inclusion_of(:status).in_array(%w[pago pendente cancelado aprovado]) }

  # Testando associações
  it { should belong_to(:company) }
  it { should belong_to(:client) }
  it { should belong_to(:account).optional }
  it { should belong_to(:payable).optional }

  # Testando métodos personalizados
  describe '#register_payment!' do
    it 'atualiza o status para "pago"' do
      reimbursement = Reimbursement.create(valid_attributes.merge(status: 'pendente'))
      reimbursement.register_payment!
      expect(reimbursement.status).to eq('pago')
    end
  end

  describe '#payment_registered?' do
    it 'retorna true se o status for "pago"' do
      reimbursement = Reimbursement.create(valid_attributes.merge(status: 'pago'))
      expect(reimbursement.payment_registered?).to be true
    end

    it 'retorna false se o status não for "pago"' do
      reimbursement = Reimbursement.create(valid_attributes.merge(status: 'pendente'))
      expect(reimbursement.payment_registered?).to be false
    end
  end
end
