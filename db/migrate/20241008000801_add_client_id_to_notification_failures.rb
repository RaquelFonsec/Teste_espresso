class AddClientIdToNotificationFailures < ActiveRecord::Migration[7.1]
  def change
    add_column :notification_failures, :client_id, :integer
  end
end
