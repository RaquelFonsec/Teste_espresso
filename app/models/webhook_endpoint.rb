class WebhookEndpoint < ApplicationRecord
  belongs_to :client  # Relação com o modelo Client
  has_many :webhook_events, inverse_of: :webhook_endpoint

  validates :company_id, presence: true 
  validates :subscriptions, length: { minimum: 1 }, presence: true
  validates :url, presence: true
  validates :erp, presence: true  # Adicione esta linha para validar o atributo erp
  scope :enabled, -> { where(enabled: true) }

  def subscribed?(event)
    (subscriptions & ['*', event]).any?
  end

  def disable!
    update!(enabled: false)
  end
end
