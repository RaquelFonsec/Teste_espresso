class AddClientIdToClients < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :client_id, :string
  end
end
