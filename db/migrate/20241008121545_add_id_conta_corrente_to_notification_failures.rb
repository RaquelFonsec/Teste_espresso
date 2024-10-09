class AddIdContaCorrenteToNotificationFailures < ActiveRecord::Migration[7.1]
  def change
    add_column :notification_failures, :id_conta_corrente, :integer
  end
end
