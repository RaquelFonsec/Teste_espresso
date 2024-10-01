class AddWebhookUrlToClients < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :webhook_url, :string
  end
end
