class AddEnabledToWebhookEndpoints < ActiveRecord::Migration[7.1]
  def change
    add_column :webhook_endpoints, :enabled, :boolean, default: true
    add_index :webhook_endpoints, :enabled # Adiciona um índice separado
  end
end
