# frozen_string_literal: true

# Classe que representa um endpoint de webhook associado a um cliente.
class WebhookEndpoint < ApplicationRecord
  belongs_to :client
  has_many :webhook_events, inverse_of: :webhook_endpoint

  # Validações
  validates :company_id, presence: true
  validates :subscriptions, presence: true, length: { minimum: 1 }
  validates :url, presence: true
  validates :erp, presence: true
  validates :client_id, presence: true
  scope :enabled, -> { where(enabled: true) }

  # Método para verificar se um evento está inscrito
  def subscribed?(event)
    (subscriptions & ['*', event]).any?
  end

  # Método para desativar o endpoint
  def disable!
    update!(enabled: false)
  end
end
