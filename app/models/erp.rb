class Erp < ApplicationRecord
  has_many :webhook_endpoints
    validates :key, presence: true
    validates :secret, presence: true
  end
  