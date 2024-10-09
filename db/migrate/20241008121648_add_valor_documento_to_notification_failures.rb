class AddValorDocumentoToNotificationFailures < ActiveRecord::Migration[7.1]
  def change
    add_column :notification_failures, :valor_documento, :decimal
  end
end
