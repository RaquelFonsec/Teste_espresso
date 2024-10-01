class AddClientIdToWebhookEndpoints < ActiveRecord::Migration[7.1]
  def change
    add_column :webhook_endpoints, :client_id, :integer
  end
end
