class AddUrlToWebhookEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :webhook_events, :url, :string
  end
end
