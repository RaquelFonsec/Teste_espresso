class EventType < ApplicationRecord
    has_many :webhook_endpoints
    validates :name, presence: true
  end
  