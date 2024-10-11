class AddPaymentIdToPayables < ActiveRecord::Migration[7.1]
  def change
    add_column :payables, :payment_id, :integer
  end
end
