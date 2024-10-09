class AddCostToReimbursements < ActiveRecord::Migration[7.1]
  def change
    add_column :reimbursements, :cost, :decimal, precision: 10, scale: 2
  end
end
