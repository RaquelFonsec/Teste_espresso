class AddMessageToClients < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :message, :string
  end
end
