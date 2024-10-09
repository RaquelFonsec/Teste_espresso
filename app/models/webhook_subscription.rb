# frozen_string_literal: true

# Classe que representa uma assinatura de webhook associada a um cliente e a um endpoint.
class WebhookSubscription < ApplicationRecord
  belongs_to :client
  belongs_to :webhook_endpoint

  validates :event, presence: true
  validates :status, inclusion: { in: %w[active inactive] }
end
