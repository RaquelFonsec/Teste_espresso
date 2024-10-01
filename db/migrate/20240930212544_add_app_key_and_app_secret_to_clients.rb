class AddAppKeyAndAppSecretToClients < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :app_key, :string
    add_column :clients, :app_secret, :string
  end
end
