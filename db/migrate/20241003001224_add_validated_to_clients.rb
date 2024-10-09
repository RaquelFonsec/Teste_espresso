class AddValidatedToClients < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :validated, :boolean
  end
end
