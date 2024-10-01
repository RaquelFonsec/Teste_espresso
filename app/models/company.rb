class Company < ApplicationRecord
    has_many :clients  # Define a associação com Clients
  
 validates :name, presence: true
  validates :erp_key, presence: true  # Verifica se erp_key não está em branco
  validates :erp_secret, presence: true  #
    # Adicione outras validações ou métodos que você precisar
  end
  