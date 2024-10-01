class WebhookSubscription < ApplicationRecord
  belongs_to :client
  belongs_to :webhook_endpoint

  validates :event, presence: true
  validates :status, inclusion: { in: %w[active inactive] }
end
