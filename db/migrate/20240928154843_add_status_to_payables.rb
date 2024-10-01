class AddStatusToPayables < ActiveRecord::Migration[7.1]
  def change
    add_column :payables, :status, :string
  end
end
