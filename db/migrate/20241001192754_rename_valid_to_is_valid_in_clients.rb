class RenameValidToIsValidInClients < ActiveRecord::Migration[7.1]
  def change
    rename_column :clients, :valid, :is_valid
  end
end
