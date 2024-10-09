# frozen_string_literal: true

# Classe que representa um evento de webhook associado a um endpoint.
class WebhookEvent < ApplicationRecord
  belongs_to :webhook_endpoint, inverse_of: :webhook_events

  validates :event, presence: true
  validates :payload, presence: true

  def deconstruct_keys(_keys)
    {
      webhook_endpoint: { url: webhook_endpoint.url },
      event:,
      payload:,
      response: response&.symbolize_keys || {}
    }
  end
end
