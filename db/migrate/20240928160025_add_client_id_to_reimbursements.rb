class AddClientIdToReimbursements < ActiveRecord::Migration[7.1]
  def change
    add_column :reimbursements, :client_id, :integer
  end
end
