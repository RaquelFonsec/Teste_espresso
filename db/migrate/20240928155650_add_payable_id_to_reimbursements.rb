class AddPayableIdToReimbursements < ActiveRecord::Migration[7.1]
  def change
    add_column :reimbursements, :payable_id, :integer
  end
end
