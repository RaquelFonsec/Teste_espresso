class AddCodeToReimbursements < ActiveRecord::Migration[7.1]
  def change
    add_column :reimbursements, :code, :string
  end
end
