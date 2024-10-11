class AddAccountToReimbursements < ActiveRecord::Migration[7.1]
  def change
    add_reference :reimbursements, :account, foreign_key: true, null: true
  end
end
