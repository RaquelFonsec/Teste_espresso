class AddDataVencimentoToNotificationFailures < ActiveRecord::Migration[7.1]
  def change
    add_column :notification_failures, :data_vencimento, :date
  end
end
