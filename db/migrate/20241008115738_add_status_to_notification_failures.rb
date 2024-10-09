class AddStatusToNotificationFailures < ActiveRecord::Migration[7.1]
  def change
    add_column :notification_failures, :status, :string
  end
end
