class AddNameToClients < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :name, :string
  end
end
