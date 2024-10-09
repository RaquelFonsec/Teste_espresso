class AddAccountIdToClients < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :account_id, :integer
  end
end
