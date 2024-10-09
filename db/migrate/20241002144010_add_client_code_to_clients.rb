class AddClientCodeToClients < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :client_code, :string
  end
end
