class AddErrorMessageToReimbursements < ActiveRecord::Migration[7.1]
  def change
    add_column :reimbursements, :error_message, :string
  end
end
