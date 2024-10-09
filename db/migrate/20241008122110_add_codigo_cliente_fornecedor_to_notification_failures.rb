class AddCodigoClienteFornecedorToNotificationFailures < ActiveRecord::Migration[7.1]
  def change
    add_column :notification_failures, :codigo_cliente_fornecedor, :integer
  end
end
