class AddFieldsToReimbursements < ActiveRecord::Migration[7.1]
  def change
    add_column :reimbursements, :account_code, :string
    add_column :reimbursements, :category_code, :string
    add_column :reimbursements, :erp_key, :string
    add_column :reimbursements, :erp_secret, :string
    add_column :reimbursements, :client_code, :string
  end
end
