class AddMessageToNotificationFailures < ActiveRecord::Migration[7.1]
  def change
    add_column :notification_failures, :message, :string
  end
end
