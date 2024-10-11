class AddClientIdToWebhookEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :webhook_events, :client_id, :integer
  end
end
