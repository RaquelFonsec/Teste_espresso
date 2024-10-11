class AddCompanyIdToPayables < ActiveRecord::Migration[7.1]
  def change
    add_column :payables, :company_id, :integer
  end
end
