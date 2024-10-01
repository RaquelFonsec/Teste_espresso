class AddCompanyIdToWebhookEndpoints < ActiveRecord::Migration[7.1]
  def change
    add_column :webhook_endpoints, :company_id, :string
  end
end
