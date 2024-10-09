class AddClientIdAndEventTypeToWebhookEndpoints < ActiveRecord::Migration[7.1]
  def change
    # Adiciona a coluna apenas se ela não existir
    add_column :webhook_endpoints, :client_id, :string unless column_exists?(:webhook_endpoints, :client_id)

    add_column :webhook_endpoints, :event_type, :string unless column_exists?(:webhook_endpoints, :event_type)
  end
end
