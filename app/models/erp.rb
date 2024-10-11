class Erp < ApplicationRecord
    validates :key, presence: true
    validates :secret, presence: true
  end
  