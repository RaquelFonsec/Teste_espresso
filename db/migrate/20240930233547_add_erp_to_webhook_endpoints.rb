class AddErpToWebhookEndpoints < ActiveRecord::Migration[7.1]
  def change
    add_column :webhook_endpoints, :erp, :string
  end
end
