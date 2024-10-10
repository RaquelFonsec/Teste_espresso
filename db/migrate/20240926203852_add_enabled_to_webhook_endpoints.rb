class AddEnabledToWebhookEndpoints < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:webhook_endpoints, :enabled)
      add_column :webhook_endpoints, :enabled, :boolean, default: true
    end
  end
end
