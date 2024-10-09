class AddPaymentIdToReimbursements < ActiveRecord::Migration[7.1]
  def change
    add_column :reimbursements, :payment_id, :integer
  end
end
