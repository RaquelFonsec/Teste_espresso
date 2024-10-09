class AddErpTokenToClients < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :erp_token, :string
  end
end
