class AddSubscriptionsToWebhookEndpoints < ActiveRecord::Migration[7.1]
  def change
    # Check if the column exists before adding it
    if !column_exists?(:webhook_endpoints, :subscriptions)
      add_column :webhook_endpoints, :subscriptions, :jsonb, default: ['*']
    end
  end
end
