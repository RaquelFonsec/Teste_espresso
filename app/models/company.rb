# frozen_string_literal: true

# Representa uma empresa que possui vários clientes.
class Company < ApplicationRecord
  has_many :clients

  validates :name, presence: true
  validates :erp_key, presence: true
  validates :erp_secret, presence: true
end
