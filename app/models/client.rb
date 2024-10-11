# frozen_string_literal: true

# Representa um cliente que pertence a uma empresa e gerencia suas
# assinaturas de webhook, endpoints e eventos associados.
class Client < ApplicationRecord
  belongs_to :company
  belongs_to :account, optional: true
  validates :company_id, presence: true
  validates :client_code, presence: true, uniqueness: true
  validates :erp_key, presence: true
  validates :erp_secret, presence: true

  has_many :webhook_subscriptions
  has_many :webhook_endpoints
  has_many :webhook_events

  # Método para obter o token do ERP
  def erp_token
    "#{erp_key}-#{erp_secret}"
  end

  def valid_credentials?
    response = OmieApi.validate_credentials(self)
    if response.success?
      true
    else
      Rails.logger.error("Falha na validação das credenciais")
      false
    end
  rescue StandardError => e
    Rails.logger.error("Erro ao validar credenciais: #{e.message}")
    false
  end
end   
