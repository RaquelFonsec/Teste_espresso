# frozen_string_literal: true

# Classe que representa uma assinatura de webhook associada a um cliente e a um endpoint.
class WebhookSubscription < ApplicationRecord
  belongs_to :client
  belongs_to :webhook_endpoint

  # Validações
  validates :event, presence: true
  validates :status, inclusion: { in: %w[active inactive] }
  validates :client, presence: true
  validates :webhook_endpoint, presence: true

  # Métodos para ativar ou desativar a assinatura
  def activate!
    update!(status: 'active')
  end

  def deactivate!
    update!(status: 'inactive')
  end

  # Escopos
  scope :active, -> { where(status: 'active') }
  scope :inactive, -> { where(status: 'inactive') }
end
