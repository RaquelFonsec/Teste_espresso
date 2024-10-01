class AddSubscriptionsToWebhookEndpoints < ActiveRecord::Migration[7.1]
  def change
    add_column :webhook_endpoints, :subscriptions, :jsonb, default: ['*']
  end
end