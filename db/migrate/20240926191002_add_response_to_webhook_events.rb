class AddResponseToWebhookEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :webhook_events, :response, :jsonb, default: {}
  end
end
