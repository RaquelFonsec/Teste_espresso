class AddResponseToWebhookEvents < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:webhook_events, :response)
      add_column :webhook_events, :response, :jsonb, default: {}
    end
  end
end
