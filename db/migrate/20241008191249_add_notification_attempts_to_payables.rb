class AddNotificationAttemptsToPayables < ActiveRecord::Migration[7.1]
  def change
    add_column :payables, :notification_attempts, :integer, default: 0
  end
end
