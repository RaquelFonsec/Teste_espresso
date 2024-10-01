class Client < ApplicationRecord
  belongs_to :company
  validates :company_id, presence: true
  validates :erp, presence: true
  validates :erp_key, presence: true
  validates :erp_secret, presence: true

  has_many :webhook_endpoints
  has_many :webhook_events

  def valid_credentials?
    response = OmieApi.validate_credentials(erp_key, erp_secret)
    response.success?
  end
end
