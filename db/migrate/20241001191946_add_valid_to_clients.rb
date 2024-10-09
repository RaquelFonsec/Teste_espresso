class AddValidToClients < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :valid, :boolean
  end
end
