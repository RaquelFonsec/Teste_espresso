class AddPaymentDateToReimbursements < ActiveRecord::Migration[7.1]
  def change
    add_column :reimbursements, :payment_date, :datetime
  end
end
