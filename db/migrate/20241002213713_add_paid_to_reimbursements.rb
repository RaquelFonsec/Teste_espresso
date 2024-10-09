class AddPaidToReimbursements < ActiveRecord::Migration[7.1]
  def change
    add_column :reimbursements, :paid, :boolean
  end
end
