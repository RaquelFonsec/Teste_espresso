class AddDataPrevisaoToNotificationFailures < ActiveRecord::Migration[7.1]
  def change
    add_column :notification_failures, :data_previsao, :date
  end
end
