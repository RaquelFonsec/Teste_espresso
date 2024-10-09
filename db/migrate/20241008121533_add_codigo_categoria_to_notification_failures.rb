class AddCodigoCategoriaToNotificationFailures < ActiveRecord::Migration[7.1]
  def change
    add_column :notification_failures, :codigo_categoria, :string
  end
end
