class AddPagarIdToReimbursements < ActiveRecord::Migration[7.1]
  def change
    add_column :reimbursements, :pagar_id, :integer
  end
end
