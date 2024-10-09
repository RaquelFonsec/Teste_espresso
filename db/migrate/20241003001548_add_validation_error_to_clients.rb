class AddValidationErrorToClients < ActiveRecord::Migration[7.1]
  def change
    add_column :clients, :validation_error, :string
  end
end
