class Payable < ApplicationRecord
  has_one :reimbursement 
  belongs_to :company
  validates :client_id, presence: true
  validates :client_code, presence: true
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :due_date, presence: true
  validates :category_code, presence: true
  validates :account_code, presence: true
  validates :categoria, presence: true
  validates :codigo_lancamento_integracao, presence: true
  validates :company_id, presence: true
  validate :due_date_cannot_be_in_the_past

  after_initialize :set_default_status, if: :new_record?

  def reimbursement_existe?
    reimbursement.present?
  end

  def record_failed_notification 
    update(status: 'failed')
    Rails.logger.error("Falha ao notificar a conta a pagar #{id}.")
  end

  def paid?
    status == 'paid'
  end

  def failed?
    status == 'failed'
  end

  private

  def due_date_cannot_be_in_the_past
    return unless due_date.present? && due_date < Date.today

    errors.add(:due_date, 'não pode ser uma data no passado.')
  end

  def set_default_status
    self.status ||= 'pending'
  end
end
