require 'rails_helper'

RSpec.describe Payable, type: :model do
  # Simulando a resposta da API antes dos testes
  before do
    response = double("Response", success?: true, parsed_response: { success: true })
    allow(HTTParty).to receive(:post).and_return(response)
  end

  let(:valid_attributes) do
    {
      account_code: "789",
      category_code: "456",
      client_code: "123",
      client_id: 1,
      cost: 100.0,
      due_date: Date.tomorrow  # Usar uma data futura para ser válida
    }
  end

  it 'is valid with valid attributes' do
    payable = Payable.new(valid_attributes)
    expect(payable).to be_valid
  end

  it 'is not valid without an account_code' do
    payable = Payable.new(valid_attributes.merge(account_code: nil))
    expect(payable).not_to be_valid
  end

  it 'is not valid without a category_code' do
    payable = Payable.new(valid_attributes.merge(category_code: nil))
    expect(payable).not_to be_valid
  end

  it 'is not valid without a client_code' do
    payable = Payable.new(valid_attributes.merge(client_code: nil))
    expect(payable).not_to be_valid
  end

  it 'is not valid without a client_id' do
    payable = Payable.new(valid_attributes.merge(client_id: nil))
    expect(payable).not_to be_valid
  end

  it 'is not valid without a cost' do
    payable = Payable.new(valid_attributes.merge(cost: nil))
    expect(payable).not_to be_valid
  end

  it 'is not valid with a negative cost' do
    payable = Payable.new(valid_attributes.merge(cost: -1))
    expect(payable).not_to be_valid
  end

  it 'is not valid with a past due date' do
    payable = Payable.new(valid_attributes.merge(due_date: Date.yesterday))
    expect(payable).not_to be_valid
  end

  it 'is valid with a future due date' do
    payable = Payable.new(valid_attributes.merge(due_date: Date.tomorrow))
    expect(payable).to be_valid
  end
end
