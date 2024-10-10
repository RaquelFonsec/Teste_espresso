class AddSubscriptionsToWebhookEndpoints < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:webhook_endpoints, :subscriptions)
      add_column :webhook_endpoints, :subscriptions, :jsonb, default: ['*']
    end
  end
end
