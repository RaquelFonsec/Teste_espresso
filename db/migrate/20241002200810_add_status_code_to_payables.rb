class AddStatusCodeToPayables < ActiveRecord::Migration[7.1]
  def change
    add_column :payables, :status_code, :string
  end
end
