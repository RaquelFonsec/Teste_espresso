class Reimbursement < ApplicationRecord
  belongs_to :payable
  belongs_to :client

  validates :company_id, presence: true
  validates :value, presence: true, numericality: true
  validates :description, presence: true
  validates :due_date, presence: true
  validates :payment_method, presence: true
  validates :status, inclusion: { in: ['pendente', 'aprovado', 'rejeitado'] }
end
