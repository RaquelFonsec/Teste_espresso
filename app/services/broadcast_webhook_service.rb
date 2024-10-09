# Serviço para transmitir eventos de webhook para todos os endpoints inscritos.
class BroadcastWebhookService
  attr_reader :event, :payload

  def self.call(event:, payload:)
    new(event:, payload:).call
  end

  def call
    WebhookEndpoint.find_each do |webhook_endpoint|
      next unless webhook_endpoint.subscribed?(event)

      webhook_event = WebhookEvent.create!(
        webhook_endpoint:,
        event:,
        payload:
      )

      WebhookWorker.perform_async(webhook_event.id)
    end
  end

  private

  def initialize(event:, payload:)
    @event = event
    @payload = payload
  end
end
