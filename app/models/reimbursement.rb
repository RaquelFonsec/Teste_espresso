class Reimbursement < ApplicationRecord
  belongs_to :company
  belongs_to :client
  belongs_to :account, optional: true
  belongs_to :payable, optional: true

  validates :value, presence: true, numericality: true
  validates :description, presence: true
  validates :due_date, presence: true
  validates :payment_method, presence: true
  validates :cost, presence: true, numericality: true
  validates :status, inclusion: { in: %w[pago pendente cancelado aprovado] }

  def register_payment!
    update(status: 'pago')
  end

  def payment_registered?
    status == 'pago'
  end
end
