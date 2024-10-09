class AddIntegrationCodeToPayables < ActiveRecord::Migration[7.1]
  def change
    add_column :payables, :integration_code, :string
  end
end
