class WebhookEvent < ApplicationRecord
  belongs_to :webhook_endpoint, inverse_of: :webhook_events

  # Validações para garantir a presença dos atributos essenciais
  validates :event, presence: true
  validates :payload, presence: true

  # Aqui você pode ajustar o método para descontruir os atributos relevantes
  def deconstruct_keys(_keys)
    {
      webhook_endpoint: { url: webhook_endpoint.url },
      event: event,
      payload: payload,
      response: response&.symbolize_keys || {}
    }
  rescue NoMethodError
    # Caso a `response` seja nula ou não possua a função `symbolize_keys`
    {}
  end
end
