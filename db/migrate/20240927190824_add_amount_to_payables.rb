class AddAmountToPayables < ActiveRecord::Migration[7.1]
  def change
    add_column :payables, :amount, :decimal
  end
end
