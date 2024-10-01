class Payable < ApplicationRecord
  validates :account_code, presence: true
  validates :category_code, presence: true
  validates :client_code, presence: true
  validates :client_id, presence: true
  validates :cost, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :due_date, presence: true
  validates :categoria, presence: true 

  validate :due_date_cannot_be_in_the_past

  after_initialize :set_default_status, if: :new_record?

  def mark_as_paid
    update(status: 'paid')
  end

  def overdue?
    due_date < Date.today
  end

  private

  def due_date_cannot_be_in_the_past
    if due_date.present? && due_date < Date.today
      errors.add(:due_date, "não pode ser uma data no passado.")
    end
  end

  def set_default_status
    self.status ||= 'pending' # Defina o status padrão como 'pending' ao criar
  end
end
